#!/bin/bash

set -e

rm -rf libs/include

cd vendor/openssl

# Clean:
git clean -dfx && git checkout -f

# Generate headers:
./Configure dist

# Copy headers:
cp -r include ../../libs

# Clean:
git clean -dfx && git checkout -f

cd ../../

exit 0
