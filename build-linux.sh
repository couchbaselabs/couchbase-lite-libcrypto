#!/bin/bash

set -e

OPENSSL_CONFIG_OPTIONS=$(cat config-params.txt)

OUTPUT_DIR="libs/linux"

# Clean output:
rm -rf $OUTPUT_DIR
mkdir $OUTPUT_DIR

build_linux() {
  ARCH=$1
  echo "Building linux libcrypto.a for ${ARCH}"
  
  cd vendor/openssl
  git clean -dfx && git checkout -f
  
  # Config:
  ./Configure dist

  if [[ $ARCH == "x86_64" || $ARCH == "amd64" ]]; then
    ./config ${OPENSSL_CONFIG_OPTIONS} -fPIC
  else
    setarch i386 ./config ${OPENSSL_CONFIG_OPTIONS} -m32 -fPIC
  fi

  # Remove test
  rm -rf test

  # Make depend:
  make depend

  # Make libcrypto:
  make build_crypto

  # Copy libcrypto.a to temp output directory:
  file libcrypto.a
  mkdir ../../${OUTPUT_DIR}/${ARCH}
  cp libcrypto.a ../../${OUTPUT_DIR}/${ARCH}

  # Cleanup:
  git clean -dfx && git checkout -f
  cd ../../
}

build_linux "x86"
build_linux "x86_64"
build_linux "amd64"

