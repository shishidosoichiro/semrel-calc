#!/usr/bin/env sh

apt update -y
apt upgrade -y

apt -y install upx clang make cmake git patch python3 libssl-dev liblzma-dev libxml2-dev bash zlib1g-dev
git clone https://github.com/tpoechtrager/osxcross.git
#cd osxcross && wget -nc https://s3.dockerproject.org/darwin/v2/MacOSX10.10.sdk.tar.xz
cd osxcross
wget -nc https://github.com/phracker/MacOSX-SDKs/releases/download/10.13/MacOSX10.13.sdk.tar.xz
mv MacOSX10.13.sdk.tar.xz tarballs/
UNATTENDED=yes OSX_VERSION_MIN=10.7 ./build.sh
export PATH="$PATH:./osxcross/target/bin"
