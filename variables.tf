variable "DO_token" {
    description = "loggin in DO"
    type = string
    
} 

/*variable "DO_RSA_rebrain" {
    description = "rebrain access key"
    type = string
    
} */

variable "my_DO_rsa" {
    description = "my access key"
    type = string
    
} 


variable "my_private" {
  description = "my private key"
    type = string
}

variable "my-access-key" {
    description = "accsess AWS"
    type = string
    
} 
variable "my-secret-key" {
    description = "secret AWS"
    type = string
    
} 

variable "login_rebrain" {
    description = "my login in rebrain"
    type = string
    
} 

variable "apps" {
  description = "application servers"
  type    = list
  default = ["app-1", "app-2", "appppp"]  
}
variable "lb" {
  description = "loadbalancer servers"
  type    = list
  default = ["lb-1"]  
}

variable "region" {
  type = string
}