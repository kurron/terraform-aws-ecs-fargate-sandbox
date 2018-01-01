terraform {
    required_version = ">= 0.10.7"
    backend "s3" {}
}

variable "region" {
    type = "string"
    default = "us-west-2"
}

variable "domain_name" {
    type = "string"
    default = "transparent.engineering"
}

provider "aws" {
    region = "${var.region}"
}

data "aws_acm_certificate" "certificate" {
    domain   = "*.${var.domain_name}"
    statuses = ["ISSUED"]
}

data "terraform_remote_state" "vpc" {
    backend = "s3"
    config {
        bucket = "transparent-test-terraform-state"
        key    = "us-west-2/debug/networking/vpc/terraform.tfstate"
        region = "us-east-1"
    }
}

data "terraform_remote_state" "security-groups" {
    backend = "s3"
    config {
        bucket = "transparent-test-terraform-state"
        key    = "us-west-2/debug/networking/security-groups/terraform.tfstate"
        region = "us-east-1"
    }
}

module "alb" {
    source = "../"

    region             = "us-west-2"
    name               = "Ultron"
    project            = "Debug"
    purpose            = "Fronts Docker containers"
    creator            = "kurron@jvmguy.com"
    environment        = "development"
    freetext           = "No notes at this time."
    internal           = "No"
    security_group_ids = ["${data.terraform_remote_state.security-groups.alb_id}"]
    subnet_ids         = "${data.terraform_remote_state.vpc.public_subnet_ids}"
    vpc_id             = "${data.terraform_remote_state.vpc.vpc_id}"
    ssl_policy         = "ELBSecurityPolicy-TLS-1-2-2017-01"
    certificate_arn    = "${data.aws_acm_certificate.certificate.arn}"
}

output "alb_id" {
    value = "${module.alb.alb_id}"
}

output "alb_arn" {
    value = "${module.alb.alb_arn}"
}

output "alb_arn_suffix" {
    value = "${module.alb.alb_arn_suffix}"
}

output "alb_dns_name" {
    value = "${module.alb.alb_dns_name}"
}

output "alb_zone_id" {
    value = "${module.alb.alb_zone_id}"
}

output "secure_listener_arn" {
    value = "${module.alb.secure_listener_arn}"
}

output "insecure_listener_arn" {
    value = "${module.alb.insecure_listener_arn}"
}
