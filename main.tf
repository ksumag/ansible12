terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
        
    local = {
      source = "hashicorp/local"
      version = "2.1.0"
    }
  }
}
provider "local" {
  # Configuration options
}

provider "digitalocean" {
   token = var.DO_token
}
provider "aws" {
  region     = var.region
  access_key = var.my-access-key
  secret_key = var.my-secret-key
}


resource "digitalocean_ssh_key" "my_key" {
  name       = "DOMYKEY"
  
   public_key = var.my_DO_rsa
}


data "digitalocean_ssh_key" "rebrain_key" {
  name = "REBRAIN.SSH.PUB.KEY"
}
//create application servers
resource "digitalocean_droplet" "application_server" {
  image  = "ubuntu-18-04-x64"
  name   = "${element(var.apps, count.index)}"
  region = "fra1"
  size   = "s-1vcpu-1gb"
  count = local.APS_quantity
  tags   = ["devops", "dymon_ksu_at_gmail_com"]
  ssh_keys = [digitalocean_ssh_key.my_key.fingerprint,data.digitalocean_ssh_key.rebrain_key.id ]   
}

//create loadbalancer servers
resource "digitalocean_droplet" "loadbalancer_server" {
  image  = "ubuntu-18-04-x64"
  name   = "${element(var.lb, count.index)}"
  region = "fra1"
  size   = "s-1vcpu-1gb"
  count = local.LB_quantity
  tags   = ["devops", "dymon_ksu_at_gmail_com"]
  ssh_keys = [digitalocean_ssh_key.my_key.fingerprint,data.digitalocean_ssh_key.rebrain_key.id ]  
}

locals {
  
  LB_quantity = "${length(var.lb)}"
  APS_quantity = "${length(var.apps)}"
  
}

data "aws_route53_zone" "primary" {
  name = "devops.rebrain.srwx.net"
  
}
resource "aws_route53_record" "LB_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${element(var.lb, count.index)}.${data.aws_route53_zone.primary.name}"
  count   = local.LB_quantity
  type    = "A"
  ttl     = "300"
  records = [digitalocean_droplet.loadbalancer_server[count.index].ipv4_address]
}

resource "aws_route53_record" "APP_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${element(var.apps, count.index)}.${data.aws_route53_zone.primary.name}"
  count   = local.APS_quantity
  type    = "A"
  ttl     = "300"
  records = [digitalocean_droplet.application_server[count.index].ipv4_address]
}

resource "local_file" "inventory_1" {
    content     = templatefile("${path.module}/inventory.tpl", { 
                           
                          access_key = var.my_private,
                          ip_app = digitalocean_droplet.application_server.*.ipv4_address,
                          name_app = aws_route53_record.APP_record.*.name,
                          APP_servers = var.apps 
                          ip_lb = digitalocean_droplet.loadbalancer_server.*.ipv4_address,
                          name_lb = aws_route53_record.LB_record.*.name,
                          LB_servers = var.lb
      })
    filename = "${path.module}/inventory_1.yml"
}

resource "null_resource" "Ansible_run" {
  provisioner "local-exec" {
    command = "sleep 60 && ansible-playbook -i inventory_1.yml playbook_1.yml " 
 }
  depends_on = [
    digitalocean_droplet.application_server,
    digitalocean_droplet.loadbalancer_server,
    aws_route53_record.LB_record,
    aws_route53_record.APP_record,
    local_file.inventory_1
  ]
}
    
    