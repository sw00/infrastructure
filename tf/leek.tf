variable cloudflare_email {}
variable cloudflare_token {}
variable LEEK_IP {}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

resource "cloudflare_record" "rancher" {
  domain = "sett.sh"
  name = "rancher"
  value = "${var.LEEK_IP}"
  type = "A"
}
