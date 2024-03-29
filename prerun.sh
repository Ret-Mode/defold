echo "STEP0"
mkdir defold_tools_temp
ls -lRa > ./defold_tools_temp/afterStep0.txt
echo "STEP1"
./scripts/package/package_android_ndk.sh linux > ./defold_tools_temp/step1.txt
echo "STEP1 END"
ls -lRa > ./defold_tools_temp/afterStep1.txt
echo "STEP2"
./scripts/package/package_android_sdk.sh linux > ./defold_tools_temp/step2.txt
echo "STEP2 END"
ls -lRa > ./defold_tools_temp/afterStep2.txt
echo "STEP3"
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-13.0.0/clang+llvm-13.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz > ./defold_tools_temp/step3.txt
mv ./clang+llvm-13.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz ./local_sdks/
echo "STEP3 END"
ls -lRa > ./defold_tools_temp/afterStep3.txt
echo "STEP4"
wget https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip > ./defold_tools_temp/step4.txt
echo "STEP4 END"
ls -lRa > ./defold_tools_temp/afterStep4.txt
echo "STEP5"
unzip sdk-tools-linux-3859397.zip > ./defold_tools_temp/step5.txt
echo "STEP5 END"
ls -lRa > ./defold_tools_temp/afterStep5.txt
echo "STEP6"
tar -czf android-sdk-tools-linux-3859397.tar.gz tools > ./defold_tools_temp/step6.txt
cp android-sdk-tools-linux-3859397.tar.gz ./local_sdks/
echo "STEP6 END"
ls -lRa > ./defold_tools_temp/afterStep6.txt
echo "STEP7"
./scripts/package/package_emscripten.sh linux > ./defold_tools_temp/step7.txt
echo "STEP7 END"
ls -lRa > ./defold_tools_temp/afterStep7.txt
echo "STEP8"
./scripts/package/package_cctools.sh linux > ./defold_tools_temp/step8.txt
echo "STEP8 END"
ls -lRa > ./defold_tools_temp/afterStep8.txt
