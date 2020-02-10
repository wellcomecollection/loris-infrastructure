#!/usr/bin/env bash

set -o errexit
set -o nounset

openssl aes-256-cbc -K $encrypted_0ed9b3e7612f_key -iv $encrypted_0ed9b3e7612f_iv -in secrets.zip.enc -out secrets.zip -d
unzip secrets.zip

mkdir -p ~/.aws
mv config ~/.aws/config
mv credentials ~/.aws/credentials

chmod 600 id_rsa

make "$TASK"
