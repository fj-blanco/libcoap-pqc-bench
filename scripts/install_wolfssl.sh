#!/bin/bash

# Version configurations
WOLFSSL_VERSION_TAG="v5.6.4-stable"
DTLS_VERSION="1.3"  # Can be "1.2" or "1.3"
DEBUG_MODE="no"

# Installing missing packages for Raspberry Pi
sudo apt-get update
sudo apt-get install -y autoconf automake libtool coreutils bsdmainutils

# Prompt user for removal of existing installation
read -p "Do you want to remove existing wolfSSL installation? (y/n): " remove_existing
if [ "$remove_existing" == "y" ]; then
    echo "Removing existing wolfSSL libraries..."
    sudo find /usr/local/lib -type f \( -name 'libwolfssl.*' \) -exec rm {} + 2>/dev/null
    sudo find /usr/lib /usr/local/lib -name 'libcoap-3-wolfssl.so*' -exec rm {} + 2>/dev/null
    sudo find /usr/lib /usr/local/lib -name 'libwolfssl.so*' -exec rm {} + 2>/dev/null
    sudo find /usr/local/include -type d -name 'wolfssl' -exec rm -rf {} + 2>/dev/null
    echo "Existing installation removed."
else
    echo "Keeping existing installation..."
fi

echo "Removing existing wolfSSL repository..."
rm -rf ./wolfssl

git clone --branch $WOLFSSL_VERSION_TAG --depth 1 https://github.com/wolfSSL/wolfssl.git
cd wolfssl
./autogen.sh

mkdir build
cd build

#WOLFSSL_FLAGS="--enable-all --enable-dtls --enable-experimental --with-liboqs --enable-kyber=ml-kem --disable-rpk"
WOLFSSL_FLAGS="--enable-all --enable-dtls --enable-experimental --with-liboqs --disable-rpk"

if [ "$DEBUG_MODE" == "yes" ]; then
    WOLFSSL_FLAGS="$WOLFSSL_FLAGS --enable-debug"
fi

if [ "$DTLS_VERSION" == "1.3" ]; then
    echo "Installing with DTLS 1.3 support"
    WOLFSSL_FLAGS="$WOLFSSL_FLAGS --enable-dtls13 --enable-dtls-frag-ch"
else
    echo "Installing with DTLS 1.2 support"
fi

../configure $WOLFSSL_FLAGS

make all
sudo make install

# Update the linker cache
sudo ldconfig