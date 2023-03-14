module "webapp-vpc" {
    source = "terraform-aws-modules/vpc/aws"
    cidr = var.webapp_vpc_cidr
    azs = var.webapp_azs
    public_subnets = var.webapp_public_subnets
    public_subnet_names = var.webapp_public_subnets_names
    enable_dns_hostnames = true
    enable_dns_support = true
    vpc_tags = {
        Name = var.webapp_vpc_name
    }
    igw_tags = {
        Name = var.webapp_igw_name
    }
}
module "webapp-security-group" {
    source = "terraform-aws-modules/security-group/aws"

    name = var.webapp_security_group_name
    description = "Security group to release access for SSH and HTTP traffic to the application server."
    create_sg = true
    vpc_id = module.webapp-vpc.vpc_id
    tags = {
        Name = var.webapp_security_group_name
    }
    ingress_with_cidr_blocks = [
        {
            from_port = 8080
            to_port = 8080
            protocol = "tcp"
            description = "Allow HTTP incoming traffic"
            cidr_blocks = "0.0.0.0/0"
            name = "webapp-http"
        },
        {
            from_port = 22
            to_port = 22
            protocol = "tcp"
            description = "Allow SSH incoming traffic"
            cidr_blocks = "0.0.0.0/0"
            name = "webapp-ssh"
        }
    ]
    egress_with_cidr_blocks = [
        {
            from_port = 0
            to_port = 0
            protocol = "-1"
            description = "Allow all outgoing traffic for software install/upgrades"
            cidr_blocks = "0.0.0.0/0"
            name = "gateway"
        }
    ]
}
data "aws_ami" "webapp-ami" {
    most_recent = true
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
    }
}
resource "tls_private_key" "wepapp-key" {
    algorithm = "RSA"
    rsa_bits = 2048
}
resource "aws_key_pair" "generated-key" {
    key_name = "webapp-key"
    public_key = tls_private_key.wepapp-key.public_key_openssh
}
resource "local_file" "pem-file" {
    content = tls_private_key.wepapp-key.private_key_pem
    filename = "./webapp-key.pem"
    file_permission = "400"
}
resource "aws_instance" "webapp-server" {
    ami = data.aws_ami.webapp-ami.id
    instance_type = var.webapp_instance_type
    key_name = aws_key_pair.generated-key.key_name
    subnet_id = module.webapp-vpc.public_subnets[0]
    vpc_security_group_ids = [module.webapp-security-group.security_group_id]
    tags = {
        Name = "webapp-server"
    }
}
# data "aws_instance" "webapp-server-state" {
#     instance_id = aws_instance.webapp-server.id
# }
# resource "null_resource" "start-if-stopped" {
#     count = data.aws_instance.webapp-server-state.instance_state == "stopped" ? 1 : 0
#     provisioner "local-exec" {
#         command = "aws ec2 start-instances --instance-ids ${aws_instance.webapp-server.id}"
#     }
#     triggers = {
#     always_run = timestamp()
#     "before" = "${aws_instance.webapp-server.id}"
#     }
# }
resource "local_file" "ansible-inventory" {
    filename = "ansible/inventory"
    content = aws_instance.webapp-server.public_ip
}

resource "null_resource" "configure-server" {
    provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ansible/inventory --private-key ${local_file.pem-file.filename} --extra-vars 'endpoint_ip=${aws_instance.webapp-server.public_ip}' ansible/main.yml"
    }
    triggers = {
    always_run = timestamp()
    }
}