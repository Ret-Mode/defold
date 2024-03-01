(ns editor.code.transpilers
  (:require [clojure.set :as set]
            [clojure.string :as string]
            [dynamo.graph :as g]
            [editor.core :as core]
            [editor.dialogs :as dialogs]
            [editor.graph-util :as gu]
            [editor.ui :as ui]
            [internal.java :as java]
            [internal.util :as util]
            [service.log :as log]
            [util.coll :refer [pair pair-map-by]])
  (:import [com.defold.extension.pipeline ILuaTranspiler]
           [com.dynamo.bob ClassLoaderScanner]))

(g/defnode TranspilerNode
  (property build-file-proj-path g/Str)
  (property source-ext g/Str)
  (property instance ILuaTranspiler)
  (input build-file-save-data g/Any)
  (input source-code-save-datas g/Any :array)
  (output transpiler-info g/Any
          (g/fnk [_node-id build-file-proj-path instance :as info]
            info))
  (output build-output g/Any :cached
          (g/fnk [instance build-file-save-data source-code-save-datas :as output]
            ;; todo: do the build...
            output)))

(g/defnode CodeTranspilersNode
  (inherits core/Scope)
  (input transpiler-infos g/Any :array)
  (input build-outputs g/Any :array)
  (output transpiler-infos g/Any (gu/passthrough transpiler-infos))
  (output build-file-proj-path->transpiler-node-id g/Any :cached
          (g/fnk [transpiler-infos]
            (case (count transpiler-infos)
              0 (constantly nil)
              1 (let [{:keys [build-file-proj-path _node-id]} (first transpiler-infos)]
                  (fn [proj-path]
                    (when (= proj-path build-file-proj-path) _node-id)))
              (pair-map-by :build-file-proj-path :_node-id transpiler-infos)))))

;; todo: implement build file connection by adding a check in project/load-node that looks
;;       up and connects the loaded node if it's a transpiler build file!!!!!

(defn- report-error! [error-message faulty-class-names]
  (ui/run-later
    (dialogs/make-info-dialog
      {:title "Unable to Load Plugin"
       :size :large
       :icon :icon/triangle-error
       :always-on-top true
       :header error-message
       :content (string/join "\n"
                             (concat
                               ["The following classes from editor plugins are not compatible with this version of the editor:"
                                ""]
                               (mapv dialogs/indent-with-bullet (sort faulty-class-names))
                               [""
                                "The project might not build without them."
                                "Please edit your project dependencies to refer to a suitable version."]))})))

(defn- initialize-lua-transpiler-classes [^ClassLoader class-loader]
  (let [{:keys [classes faulty-class-names]}
        (->> (ClassLoaderScanner/scanClassLoader class-loader "com.defold.extension.pipeline")
             (eduction
               (keep
                 (fn [^String class-name]
                   (try
                     (let [uninitialized-class (Class/forName class-name false class-loader)]
                       (when (java/public-implementation? uninitialized-class ILuaTranspiler)
                         (let [initialized-class (Class/forName class-name true class-loader)]
                           (pair :classes initialized-class))))
                     (catch Exception e
                       (log/error :msg (str "Exception in static initializer of ILuaTranspiler implementation "
                                            class-name ": " (.getMessage e))
                                  :exception e)
                       (pair :faulty-class-names class-name))))))
             (util/group-into {} #{} key val))]
    (when faulty-class-names
      (throw (ex-info "Failed to initialize Lua transpiler plugins" {:faulty-class-names faulty-class-names})))
    (or classes #{})))

(defn- create-lua-transpilers [transpiler-classes]
  (let [{:keys [transpilers faulty-class-names]}
        (->> transpiler-classes
             (eduction
               (map (fn [^Class transpiler-plugin-class]
                      (try
                        (let [^ILuaTranspiler transpiler (java/invoke-no-arg-constructor transpiler-plugin-class)
                              build-file-proj-path (.getBuildFileResourcePath transpiler)
                              source-ext (.getSourceExt transpiler)]
                          (when (or (not (string? build-file-proj-path))
                                    (not (string/starts-with? build-file-proj-path "/")))
                            (throw (Exception. (str "Invalid build file resource path: " build-file-proj-path))))
                          (when (or (not (string? source-ext))
                                    (string/starts-with? source-ext "."))
                            (throw (Exception. (str "Invalid source extension: " source-ext))))
                          (pair :transpilers {:build-file-proj-path build-file-proj-path
                                              :source-ext source-ext
                                              :instance transpiler}))
                        (catch Exception e
                          (let [class-name (.getSimpleName transpiler-plugin-class)]
                            (log/error :msg (str "Failed to initialize transpiler " class-name) :exception e)
                            (pair :faulty-class-names class-name)))))))
             (util/group-into {} [] key val))]
    (when faulty-class-names
      (throw (ex-info "Failed to create Lua transpiler plugins" {:faulty-class-names faulty-class-names})))
    transpilers))

(defn reload-lua-transpilers! [code-transpilers class-loader]
  (try
    (let [old-transpiler-class->node-id (pair-map-by
                                          #(-> % :instance class)
                                          :_node-id
                                          (g/node-value code-transpilers :transpiler-infos))
          old-transpiler-classes (set (keys old-transpiler-class->node-id))
          new-transpiler-classes (initialize-lua-transpiler-classes class-loader)]
      (when-not (= old-transpiler-classes new-transpiler-classes)
        (let [removed (set/difference old-transpiler-classes new-transpiler-classes)
              added (set/difference new-transpiler-classes old-transpiler-classes)]
          (g/transact
            (for [removed-class removed]
              (g/delete-node (old-transpiler-class->node-id removed-class)))
            (for [props (create-lua-transpilers added)]
              (g/make-nodes (g/node-id->graph-id code-transpilers)
                [transpiler TranspilerNode]
                (apply g/set-property transpiler (mapcat identity props))
                (g/connect transpiler :_node-id code-transpilers :nodes)
                (g/connect transpiler :transpiler-info code-transpilers :transpiler-infos)
                (g/connect transpiler :build-output code-transpilers :build-outputs))))))
      nil)
    (catch Exception e
      (report-error! (ex-message e) (:faulty-class-names (ex-data e))))))

(defn load-build-file-transaction-step [code-transpilers resource-node-id proj-path]
  (let [f (g/node-value code-transpilers :build-file-proj-path->transpiler-node-id)]
    (when-let [transpiler-node-id (f proj-path)]
      (g/connect resource-node-id :save-data transpiler-node-id :build-file-save-data))))

;; Damnit! I need to register code editor resource type, which depends on a workspace!
;; So the reload has to move to some other place! but maybe still not above the project,
;; so that the project can load and connect the transpiler nodes!

(comment

  (editor.defold-project/code-transpilers (dev/project))

  #__)