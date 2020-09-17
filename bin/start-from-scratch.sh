#!/bin/bash

set -e
set -x

# Checkout the submodules
git submodule update --init --recursive

# Revert any outstanding modifications
make toolchain-spike-revert-patch
make toolchain-binutils-revert-patch
make toolchain-pk-revert-patch

# Apply patches
make toolchain-binutils-apply-patch
make toolchain-spike-apply-patch
make toolchain-pk-apply-patch

# Configure and build toolchain
make toolchain-configure
make toolchain-build

# Configure and build spike
make toolchain-spike-configure
make toolchain-spike-build

# Configure and build the proxy kernels
make toolchain-pk-configure
make toolchain-pk-build

# Install pycrypto
pip3 install --user -r requirements.txt

