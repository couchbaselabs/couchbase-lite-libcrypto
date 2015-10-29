#!/bin/bash
#
# http://wiki.openssl.org/index.php/Android
#
set -e

output_dir="libs/android"

# Clean output:
rm -rf $output_dir
mkdir $output_dir

# Clean openssl:
cd vendor/openssl
git clean -dfx && git checkout -f
cd ../../

archs=(armeabi armeabi-v7a arm64-v8a mips mips64 x86 x86_64)

openssl_config_options=$(cat config-params.txt)

for arch in ${archs[@]}; do
    xLIB="/lib"
    case ${arch} in
        "armeabi")
            _ANDROID_API="android-19"
            _ANDROID_TARGET_SELECT=arch-arm
            _ANDROID_ARCH=arch-arm
            _ANDROID_EABI=arm-linux-androideabi-4.9
            configure_platform="android" ;;
        "armeabi-v7a")
            _ANDROID_API="android-19"
            _ANDROID_TARGET_SELECT=arch-arm
            _ANDROID_ARCH=arch-arm
            _ANDROID_EABI=arm-linux-androideabi-4.9
            configure_platform="android-armv7" ;;
        "arm64-v8a")
            _ANDROID_API="android-21"
            _ANDROID_TARGET_SELECT=arch-arm64-v8a
            _ANDROID_ARCH=arch-arm64
            _ANDROID_EABI=aarch64-linux-android-4.9
            #no xLIB="/lib64"
            configure_platform="linux-generic64 -DB_ENDIAN" ;;
        "mips")
            _ANDROID_API="android-19"
            _ANDROID_TARGET_SELECT=arch-mips
            _ANDROID_ARCH=arch-mips
            _ANDROID_EABI=mipsel-linux-android-4.9
            configure_platform="android -DB_ENDIAN" ;;
        "mips64")
            _ANDROID_API="android-21"
            _ANDROID_TARGET_SELECT=arch-mips64
            _ANDROID_ARCH=arch-mips64
            _ANDROID_EABI=mips64el-linux-android-4.9
            xLIB="/lib64"
            configure_platform="linux-generic64 -DB_ENDIAN" ;;
        "x86")
            _ANDROID_API="android-19"
            _ANDROID_TARGET_SELECT=arch-x86
            _ANDROID_ARCH=arch-x86
            _ANDROID_EABI=x86-4.9
            configure_platform="android-x86" ;;
        "x86_64")
            _ANDROID_API="android-21"
            _ANDROID_TARGET_SELECT=arch-x86_64
            _ANDROID_ARCH=arch-x86_64
            _ANDROID_EABI=x86_64-4.9
            xLIB="/lib64"
            configure_platform="linux-generic64" ;;
        *)
            configure_platform="linux-elf" ;;
    esac

    mkdir "$output_dir/${arch}"

    . ./build-android-setenv.sh

    echo "CROSS COMPILE ENV : $CROSS_COMPILE"
    cd vendor/openssl

    xCFLAGS="-fPIC -I$ANDROID_DEV/include -B$ANDROID_DEV/$xLIB"

    # We do not need this as we are not going to install anything (Pasin):
    #perl -pi -e 's/install: all install_docs install_sw/install: install_docs install_sw/g' Makefile.org

    ./Configure dist
    ./Configure $openssl_config_options --openssldir=/tmp/openssl_android/ $configure_platform $xCFLAGS
    
    # We do not need to patch as we are building only static libraries (Pasin):
    # patch .SO NAME
    #perl -pi -e 's/SHLIB_EXT=\.so\.\$\(SHLIB_MAJOR\)\.\$\(SHLIB_MINOR\)/SHLIB_EXT=\.so/g' Makefile
    #perl -pi -e 's/SHARED_LIBS_LINK_EXTS=\.so\.\$\(SHLIB_MAJOR\) \.so//g' Makefile
    # quote injection for proper .SO NAME
    #perl -pi -e 's/SHLIB_MAJOR=1/SHLIB_MAJOR=`/g' Makefile
    #perl -pi -e 's/SHLIB_MINOR=0.0/SHLIB_MINOR=`/g' Makefile

    # After disabling some feature, those features are still referenced in test.
    # As a result, make depend (which also make depend on test files) has errors.
    # Couldn't find a right way to disable building test so deleting the test folder 
    # as a workaround for now (Pasin):
    rm -rf test

    make clean
    make depend
    make build_crypto

    file libcrypto.a
    cp libcrypto.a ../../$output_dir/${arch}/libcrypto.a

    # Cleanup:
    git clean -dfx && git checkout -f

    cd ../..
done
exit 0
