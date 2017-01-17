#!/bin/bash

#set -v

PROJECT_HOME=`pwd`
PATH_ORG=$PATH
OUTPUT_DIR="libs/android/clang"

# Clean output:
rm -rf $OUTPUT_DIR
mkdir $OUTPUT_DIR

build_android_clang() {

	echo ""
	echo "----- Build libcrypto for "$1" -----"
	echo ""

	ARCHITECTURE=$1
	ARCH=$2
	PLATFORM=$3
	TOOLCHAIN=$4
	CONFIGURE_PLATFORM=$5
	TOOLCHAIN_DIR="./toolchain/"$ARCH
	stl="libc++"

	# Clean openssl:
	cd vendor/openssl
	git clean -dfx  --quiet && git checkout -f
	cd ../../

	# Build toolchain
	$ANDROID_NDK_HOME/build/tools/make-standalone-toolchain.sh --verbose --stl=$stl --arch=$ARCH --install-dir=$TOOLCHAIN_DIR --platform=$PLATFORM --force

	# Set toolchain
	export TOOLCHAIN_ROOT=$PROJECT_HOME/$TOOLCHAIN_DIR
	export SYSROOT=$TOOLCHAIN_ROOT/sysroot
	export CC=$TOOLCHAIN-clang
	export CXX=$TOOLCHAIN-clang++
	export AR=$TOOLCHAIN-ar
	export AS=$TOOLCHAIN-as
	export LD=$TOOLCHAIN-ld
	export RANLIB=$TOOLCHAIN-ranlib
	export NM=$TOOLCHAIN-nm
	export STRIP=$TOOLCHAIN-strip
	export CHOST=$TOOLCHAIN
	export CXXFLAGS="-std=c++11 -fPIC"
	export CPPFLAGS="-DANDROID -fPIC"
	export PATH=$PATH_ORG:$TOOLCHAIN_ROOT/bin:$SYSROOT/usr/local/bin

	# Build libcrypto
	cd vendor/openssl
	perl -pi -w -e 's/\-mandroid//g;' ./Configure
	./Configure $CONFIGURE_PLATFORM no-asm no-shared --static
	make build_crypto -j 4
	mkdir -p ../../$OUTPUT_DIR/${ARCHITECTURE}/
	cp libcrypto.a ../../$OUTPUT_DIR/${ARCHITECTURE}/libcrypto.a
	cd ../..
}

# Build libcrypto for armeabi-v7a, x86 and arm64-v8a.
build_android_clang "armeabi-v7a" "arm"   "android-16" "arm-linux-androideabi" "android-armv7"
build_android_clang "x86"         "x86"   "android-16" "i686-linux-android"    "android-x86"
build_android_clang "arm64-v8a"   "arm64" "android-21" "aarch64-linux-android" "linux-generic64 -DB_ENDIAN"

export PATH=$PATH_ORG

exit 0