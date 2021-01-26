#!/bin/bash

PROVISIONER=${1:?"provisioner undefined"}

mkdir tmp
trap 'rm -rf tmp' EXIT

wget https://releases.hashicorp.com/packer/1.2.3/packer_1.2.3_linux_amd64.zip -O ./tmp/packer.zip
unzip ./tmp/packer.zip -d ./tmp

docker build . -t local/kvm
docker run -it --rm --name packer -p 5901:5901 -v $(cd $(dirname $0) && pwd):/srv local/kvm packer build ${PROVISIONER}
