provider "scaleway" {
  region = "ams1"
}

resource "scaleway_ip" "ip" {
  server = "${scaleway_server.save-up-api.id}"
}

data "scaleway_image" "save-up-api" {
  architecture = "x86_64"
  name         = "save-up-api"
  most_recent  = true
}

resource "scaleway_server" "save-up-api" {
  name  = "save-up-api"
  image = "${data.scaleway_image.save-up-api.id}"
  type  = "START1-XS"
}

resource "scaleway_security_group" "http" {
  name        = "http"
  description = "allow HTTP and HTTPS traffic"
}

resource "scaleway_security_group_rule" "http_accept" {
  security_group = "${scaleway_security_group.http.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port      = 80
}

resource "scaleway_security_group_rule" "https_accept" {
  security_group = "${scaleway_security_group.http.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port      = 443
}
