terraform {
    required_version = ">= 0.11.1"
    backend "s3" {}
}

variable "region" {
    type = "string"
    default = "us-west-2"
}

variable "project" {
    type = "string"
    default = "Fargate"
}

variable "creator" {
    type = "string"
    default = "kurron@jvmguy.com"
}

variable "environment" {
    type = "string"
    default = "sandbox"
}

variable "domain_name" {
    type = "string"
    default = "transparent.engineering"
}

variable "vpc_id" {
    type = "string"
    default = "vpc-ff217399"
}

variable "subnet_ids" {
    default = ["subnet-568ee830","subnet-4a33b402","subnet-ac5f72f7"]
}

provider "aws" {
    region = "${var.region}"
}

data "aws_acm_certificate" "certificate" {
    domain   = "*.${var.domain_name}"
    statuses = ["ISSUED"]
}

module "alb" {
    source = "kurron/alb/aws"

    region             = "${var.region}"
    name               = "Fargate"
    project            = "${var.project}"
    purpose            = "Fronts Docker containers"
    creator            = "${var.creator}"
    environment        = "${var.environment}"
    freetext           = "No notes at this time."
    internal           = "No"
    security_group_ids = ["sg-18d8b765"]
    subnet_ids         = "${var.subnet_ids}"
    vpc_id             = "${var.vpc_id}"
    ssl_policy         = "ELBSecurityPolicy-TLS-1-2-2017-01"
    certificate_arn    = "${data.aws_acm_certificate.certificate.arn}"
}

resource "aws_ecs_cluster" "main" {
    name = "Fargate"

    lifecycle {
        create_before_destroy = true
    }
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
