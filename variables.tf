variable "webapp_vpc_cidr" {
    type = string
}
variable "webapp_public_subnets" {
    type = list(string)
}
variable "webapp_public_subnets_names" {
    type = list(string)
}
variable "webapp_azs" {
    type = list(string)
}
variable "webapp_vpc_name" {
    type = string
}
variable "webapp_igw_name" {
    type = string
}
variable "webapp_security_group_name" {
    type = string
}
variable "webapp_server" {
    type = string
}
variable "webapp_instance_type" {
    type = string
}