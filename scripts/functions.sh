#!/bin/bash

run_remote() {
  ssh \
    -i $SSH_KEY_FILE \
    -o StrictHostKeyChecking=no \
    "root@${HOST_IP}" \
    "$@"
}

copy_remote() {
  scp -i ./keys/cloudafrica_id_rsa \
    -o StrictHostKeyChecking=no \
    $1 "root@${HOST_IP}:$2"
}

install_docker() {
    run_remote 'curl -sSL https://get.docker.com/ | sh'
}

provision_cloudflare() {
    terraform apply -var-file=tf/terraform.tfvars -var "LEEK_IP=${HOST_IP}" tf
}

provision_certs() {
  # create the docker volume for letsencrypt
  run_remote 'docker volume create --name letsencrypt-data'
  # get the letsencrypt certs
  run_remote "docker run --rm -v letsencrypt-data:/etc/letsencrypt -p 443:443 sw00/certbot certonly --standalone --agree-tos -n -m sett.wai@gmail.com -d ${1}"
}

configure_nginx(){
    # create ssl directory
    run_remote 'mkdir -p /var/data/nginx/ssl'
    # copy certs to ssl directory
    run_remote 'docker run --rm -v letsencrypt-data:/etc/letsencrypt -v /var/data/nginx/ssl:/ssl --entrypoint="/bin/sh" sw00/certbot -c "cp /etc/letsencrypt/live/rancher.sett.sh/* /ssl/"'
  # generate dhparam if doesn't exist
  run_remote '[ ! -f /var/data/nginx/ssl/dhparam.pem ] && openssl dhparam -outform PEM -out /var/data/nginx/ssl/dhparam.pem 2048'

  # create conf directory
  run_remote 'mkdir -p /var/data/nginx/conf'
  # copy conf to host
  copy_remote './conf/rancher.nginx.conf' /var/data/nginx/conf
}

run_rancher() {
  run_remote 'docker create --name rancher-data rancher/server'
  run_remote 'docker run -d --restart=always --volumes-from rancher-data --name rancher-server -p 8080 rancher/server'
  run_remote 'docker run -d -v /var/data/nginx/conf/rancher.nginx.conf:/etc/nginx/conf.d/rancher.conf:ro -v /var/data/nginx/ssl:/ssl:ro --link rancher-server -p 80:80 -p 443:443 --name nginx nginx'
}


