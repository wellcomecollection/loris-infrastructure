#!/usr/bin/env bash
# Install Loris on Ubuntu

set -o errexit
set -o nounset

# Download and install the Loris code itself
echo "*** Downloading the Loris source code"
apt-get install --yes unzip wget
wget "https://github.com/$LORIS_GITHUB_USER/loris/archive/$LORIS_COMMIT.zip"
unzip "$LORIS_COMMIT.zip"
rm "$LORIS_COMMIT.zip"
apt-get remove --yes unzip wget

# Required or setup.py complains
echo "*** Creating Loris user"
useradd -d /var/www/loris -s /sbin/false loris

echo "*** Installing Loris dependencies"
pip3 install -r /requirements.txt

echo "*** Installing Loris itself"
cd "loris-$LORIS_COMMIT"
python3 setup.py install

echo "*** Setting up Loris directories"
# If we run this setup command from bin/ then it uses the installed
# version of loris rather than the source, which causes errors due to the
# way it resolves configuration files.
cp bin/setup_directories.py .
python3 setup_directories.py
rm setup_directories.py

apt-get clean
