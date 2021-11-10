terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
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


resource "digitalocean_ssh_key" "my_key" {
  name       = "DOMYKEY"
  
   public_key = var.my_DO_rsa
}


data "digitalocean_ssh_key" "rebrain_key" {
  name = "REBRAIN.SSH.PUB.KEY"
}

resource "digitalocean_droplet" "ksumag" {
  image  = "ubuntu-18-04-x64"
  name   = "ksumag"
  region = "fra1"
  size   = "s-1vcpu-1gb"
  tags   = ["devops", "dymon_ksu_at_gmail_com"]
  ssh_keys = [digitalocean_ssh_key.my_key.fingerprint,data.digitalocean_ssh_key.rebrain_key.id ]    
}

resource "local_file" "inventory_1" {
    content     = templatefile("${path.module}/inventory.tpl", { 
                           
                          access_key = var.my_private,
                          ip = digitalocean_droplet.ksumag.ipv4_address,
                          name = digitalocean_droplet.ksumag.name
      })
    filename = "${path.module}/inventory_1.yml"
}


    
    