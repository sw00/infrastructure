provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_droplet" "leek" {
  image = "ubuntu-14-04-x64"
  name = "leek"
  region = "lon1"
  size = "1gb"
}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

resource "cloudflare_record" "leek" {
  domain = "leek.rigmarolesoup.com"
  name = "leek"
  value = "${digitalocean_droplet.leek.ipv4_address}"
  type = "A"
}
