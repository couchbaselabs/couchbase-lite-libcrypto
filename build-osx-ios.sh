#
# References: 
# https://gist.github.com/Norod/2f3ef9b6e3758dfc1433
# https://github.com/st3fan/ios-openssl
# https://github.com/x2on/OpenSSL-for-iPhone/blob/master/build-libssl.sh

set -e

# SDK version:
SDK_VERSION=$(xcodebuild -version -sdk iphoneos | grep SDKVersion | cut -f2 -d ':' | tr -d '[[:space:]]')

# Min iOS deployment target version:
MIN_IOS_VERSION="7.0"

OPENSSL_CONFIG_OPTIONS=$(cat config-params.txt)

build_osx() {
  ARCH=$1
  echo "Building osx libcrypto.a for ${ARCH}"

  cd vendor/openssl
  git clean -dfx && git checkout -f

  # define temp output directory:
  TMP_OUTPUT_DIR="/tmp/openssl-osx-${ARCH}"
  rm -rf ${TMP_OUTPUT_DIR}
  mkdir ${TMP_OUTPUT_DIR}
  
  export CC="/usr/bin/clang"

  TARGET="darwin-i386-cc"
  if [[ $ARCH == "x86_64" ]]; then
    TARGET="darwin64-x86_64-cc"
  fi

  # Config:
  ./Configure dist
  ./Configure ${TARGET} ${OPENSSL_CONFIG_OPTIONS} --openssldir="${TMP_OUTPUT_DIR} -fPIC"
  
  # Remove test:
  rm -rf test
  
  # Make depend:
  make depend

  # Make libcrypto:
  make build_crypto

  # Copy libcrypto.a to temp output directory:
  file libcrypto.a
  cp libcrypto.a ${TMP_OUTPUT_DIR}

  # Cleanup:
  git clean -dfx && git checkout -f
  cd ../../
}

build_ios() {
  ARCH=$1
  echo "Building ios libcrypto.a for ${ARCH}"

  cd vendor/openssl
  git clean -dfx && git checkout -f

  # define temp output directory:
  TMP_OUTPUT_DIR="/tmp/openssl-ios-${ARCH}"
  rm -rf ${TMP_OUTPUT_DIR}
  mkdir ${TMP_OUTPUT_DIR}

  DEVELOPER=`xcode-select -print-path`
  export BUILD_TOOLS="${DEVELOPER}"

  PLATFORM=""
  if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]]; then
    PLATFORM="iPhoneSimulator"
  else
    PLATFORM="iPhoneOS"
    sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"
  fi
  
  export $PLATFORM
  export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
  export CROSS_SDK="${PLATFORM}${SDK_VERSION}.sdk"
  export BUILD_TOOLS="${DEVELOPER}"
  export CC="${BUILD_TOOLS}/usr/bin/gcc -fembed-bitcode -mios-version-min=${MIN_IOS_VERSION} -arch ${ARCH}"

  TARGET="iphoneos-cross"
  if [[ "${ARCH}" == "x86_64" ]]; then
    TARGET="darwin64-x86_64-cc"
  fi

  # Config:
  ./Configure dist
  ./Configure ${TARGET} ${OPENSSL_CONFIG_OPTIONS} --openssldir="${output_tmp_dir} -fPIC"

  # Remove test:
  rm -rf test

  # Make depend:
  sudo make depend

  # Make libcrypto:
  make build_crypto

  # Copy libcrypto.a to temp output directory:
  file libcrypto.a
  cp libcrypto.a ${TMP_OUTPUT_DIR}

  # Cleanup:
  git clean -dfx && git checkout -f
  cd ../../
}

# Build OSX binaries:
OUTPUT_DIR="libs/osx"
rm -rf ${OUTPUT_DIR}
mkdir ${OUTPUT_DIR}

build_osx "i386"
build_osx "x86_64"

# Create fat binaries:
BASE_TMP_OUTPUT_DIR="/tmp/openssl-osx"
lipo \
    "${BASE_TMP_OUTPUT_DIR}-i386/libcrypto.a" \
    "${BASE_TMP_OUTPUT_DIR}-x86_64/libcrypto.a" \
    -create -output ${OUTPUT_DIR}/libcrypto.a

# Build iOS binaries:
OUTPUT_DIR="libs/ios"
rm -rf ${OUTPUT_DIR}
mkdir ${OUTPUT_DIR}

build_ios "armv7"
build_ios "arm64"
build_ios "x86_64"
build_ios "i386"

# Create fat binaries:
BASE_TMP_OUTPUT_DIR="/tmp/openssl-ios"
lipo \
  "${BASE_TMP_OUTPUT_DIR}-armv7/libcrypto.a" \
  "${BASE_TMP_OUTPUT_DIR}-arm64/libcrypto.a" \
  "${BASE_TMP_OUTPUT_DIR}-i386/libcrypto.a" \
  "${BASE_TMP_OUTPUT_DIR}-x86_64/libcrypto.a" \
  -create -output ${OUTPUT_DIR}/libcrypto.a
