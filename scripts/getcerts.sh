#!/bin/bash

BASE_DIR=$(dirname $0)
HOST_IP=$1
SSH_KEY_FILE=$BASE_DIR/../keys/cloudafrica_id_rsa
DOMAIN=$2

source "$BASE_DIR/functions.sh"

provision_certs "$DOMAIN"

scp -i ./keys/cloudafrica_id_rsa \
  -o StrictHostKeyChecking=no \
  -r \
  "root@${HOST_IP}:/var/lib/docker/volumes/letsencrypt-data/_data/live/${DOMAIN}/" \
  .

