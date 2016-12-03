#!/usr/bin/env bash
set -x

HOST_IP=$1
SSH_KEY_FILE=./keys/cloudafrica_id_rsa

source './scripts/functions.sh'

main(){
    install_docker
    provision_cloudflare
    provision_certs 'rancher.sett.sh'
    configure_nginx
    run_rancher
}

main

