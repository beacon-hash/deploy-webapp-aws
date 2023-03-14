# Project - Deploy simple web application on AWS


## Overview

In this project, I'm trying to automate the process of deploying a simple web application on AWS:

- [Terraform](https://registry.terraform.io) - As an infrastructure provisioning tool to automate the infrastructure provisioning process
- [Ansible](https://www.ansible.com) - As a configuration management tool to configure the web application server after provisioning

## My process

I've used Terraform to isolate the application to its environment by creating its own VPC, subnet, route tables, security groups, and key pair. After setting up the environment and creating the EC2 instance, I handed over the configuration part of the server to a simple ansible playbook script in the `ansible` directory.

## How to use the code

To use this code to provision this web application, you need the following:

- [AWS](https://aws.amazon.com/free) account with free tier
- Install AWS CLI and configure it with your AWS access and secret keys  
    
        aws configure
- Create a `terraform.tfvars` file in the repo working directory with your preferred variables as below:

        webapp_azs = [ "eu-west-3a" ]
        webapp_public_subnets = [ "192.168.0.0/20" ]
        webapp_public_subnets_names = [ "webapp-public-subnet-1" ]
        webapp_vpc_cidr = "192.168.0.0/16"
        webapp_vpc_name = "webapp-vpc"
        webapp_igw_name = "webapp-igw"
        webapp_security_group_name = "webapp-sg"
        webapp_instance_type = "t2.micro"
- Execute the below commands to initialize the terraform environment and apply the scripts.

        terraform init
        terraform apply --auto-approve
## The output

After executing the Terraform script, you will get the public ip of the provisioned ec2 instance on the output section and you will get the private key `.pem` file in the repo working directory to use it for ssh remote login. 

## What I learned 

I've learned the following points from this project:

- How to use Terraform as a provisioning tool 
- How to use Ansible as a configuration management tool
- How to extend Terraform with Ansible
- The core difference between Ansible and Terraform
