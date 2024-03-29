./scripts/build.py install_ems --package-path=./local_sdks
./scripts/build.py install_ext --platform=arm64-android
./scripts/build.py install_ext --platform=armv7-android
./scripts/build.py install_ext --platform=js-web
./scripts/build.py install_ext --platform=wasm-web
./scripts/build.py install_ext --platform=linux
./scripts/build.py --package-path=./local_sdks install_sdk --platform=arm64-android
./scripts/build.py --package-path=./local_sdks install_sdk --platform=armv7-android
./scripts/build.py --package-path=./local_sdks install_sdk --platform=js-web
./scripts/build.py --package-path=./local_sdks install_sdk --platform=wasm-web
./scripts/build.py --package-path=./local_sdks install_sdk --platform=linux
./scripts/build.py build_engine --platform=arm64-android
./scripts/build.py build_engine --platform=armv7-android
./scripts/build.py build_engine --platform=js-web
./scripts/build.py build_engine --platform=wasm-web
./scripts/build.py build_engine --platform=linux
./scripts/build.py build_builtins
./scripts/build.py build_docs
./scripts/build.py build_bob --skip-tests
cd ./editor
lein init
lein run
