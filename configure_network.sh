#!/bin/bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${__dir}/.env.network

RESPONSE=`/usr/lib/besu-23.4.1/bin/besu operator generate-blockchain-config --config-file=ibftConfigFile.json --to=networkFiles --private-key-file-name=key`

./copyKeys.sh

NODE_DIR="/home/ubuntu/Constructor-Besu-IBFT/"

./bootnode.sh --CONTAINER_NAME="boot_node"

sshpass -p "${NODE2_PWD}" scp -r Node-2 genesis.json .env.production "${NODE2}:${NODE_DIR}"
sshpass -p "${NODE3_PWD}" scp -r Node-3 genesis.json .env.production "${NODE3}:${NODE_DIR}"
sshpass -p "${NODE4_PWD}" scp -r Node-4 genesis.json .env.production "${NODE4}:${NODE_DIR}"

