#!/bin/bash

set -e

CONSUL_TEMPLATE_VERSION="0.18.5"
CURDIR=`pwd`

if [[ $(which consul-template >/dev/null && consul-template version | head -n 1 | cut -d ' ' -f 2) == "v$CONSUL_TEMPLATE_VERSION" ]]; then
    echo "Consul Template v$CONSUL_TEMPLATE_VERSION already installed; Skipping"
    exit
fi

echo Fetching Consul Template...
cd /tmp/
wget -q https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -O consul-template.zip
echo Installing Consul Template...
unzip consul-template.zip
sudo chmod +x consul-template
sudo mv consul-template /usr/bin/consul-template
cd ${CURDIR}
