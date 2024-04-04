echo "STEP9"
./scripts/build.py install_ems --package-path=./local_sdks > ./defold_tools_temp/step9.txt
echo "STEP9 END"
ls -lRa > ./defold_tools_temp/afterStep9.txt
echo "STEP10"
./scripts/build.py install_ext > ./defold_tools_temp/step10.txt
echo "STEP10 END"
ls -lRa > ./defold_tools_temp/afterStep10.txt
echo "STEP11"
./scripts/build.py --package-path=./local_sdks install_sdk --platform=arm64-android > ./defold_tools_temp/step11.txt
echo "STEP11 END"
ls -lRa > ./defold_tools_temp/afterStep11.txt
echo "STEP12"
./scripts/build.py --package-path=./local_sdks install_sdk --platform=armv7-android > ./defold_tools_temp/step12.txt
echo "STEP12 END"
ls -lRa > ./defold_tools_temp/afterStep12.txt
echo "STEP13"
./scripts/build.py --package-path=./local_sdks install_sdk --platform=js-web > ./defold_tools_temp/step13.txt
echo "STEP13 END"
ls -lRa > ./defold_tools_temp/afterStep13.txt
echo "STEP14"
./scripts/build.py --package-path=./local_sdks install_sdk --platform=wasm-web > ./defold_tools_temp/step14.txt
echo "STEP14 END"
ls -lRa > ./defold_tools_temp/afterStep14.txt
echo "STEP15"
./scripts/build.py --package-path=./local_sdks install_sdk --platform=x86_64-linux > ./defold_tools_temp/step15.txt
echo "STEP15 END"
ls -lRa > ./defold_tools_temp/afterStep15.txt
echo "STEP16"
./scripts/build.py build_engine --platform=arm64-android --skip-tests -- --skip-build-tests > ./defold_tools_temp/step16.txt
echo "STEP16 END"
ls -lRa > ./defold_tools_temp/afterStep16.txt
echo "STEP17"
./scripts/build.py build_engine --platform=armv7-android --skip-tests -- --skip-build-tests > ./defold_tools_temp/step17.txt
echo "STEP17 END"
ls -lRa > ./defold_tools_temp/afterStep17.txt
echo "STEP18"
./scripts/build.py build_engine --platform=js-web --skip-tests -- --skip-build-tests > ./defold_tools_temp/step18.txt
echo "STEP18 END"
ls -lRa > ./defold_tools_temp/afterStep18.txt
echo "STEP19"
./scripts/build.py build_engine --platform=wasm-web --skip-tests -- --skip-build-tests > ./defold_tools_temp/step19.txt
echo "STEP19 END"
ls -lRa > ./defold_tools_temp/afterStep19.txt
echo "STEP20"
./scripts/build.py build_engine --platform=x86_64-linux --skip-tests -- --skip-build-tests > ./defold_tools_temp/step20.txt
echo "STEP20 END"
ls -lRa > ./defold_tools_temp/afterStep20.txt
echo "STEP21"
./scripts/build.py build_builtins > ./defold_tools_temp/step21.txt
echo "STEP21 END"
ls -lRa > ./defold_tools_temp/afterStep21.txt
echo "STEP22"
./scripts/build.py build_docs > ./defold_tools_temp/step22.txt
echo "STEP22 END"
ls -lRa > ./defold_tools_temp/afterStep22.txt
echo "STEP23"
./scripts/build.py build_bob --skip-tests > ./defold_tools_temp/step23.txt
echo "STEP23 END"
ls -lRa > ./defold_tools_temp/afterStep23.txt
cd ./editor
lein init
lein run
