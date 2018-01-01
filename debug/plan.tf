terraform {
    required_version = ">= 0.11.1"
    backend "s3" {}
}

variable "region" {
    type = "string"
    default = "us-east-1"
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
    default = "vpc-b85b93c0"
}

variable "subnet_ids" {
    default = [" subnet-d1eefc8b","subnet-7d229919"]
}

provider "aws" {
    region = "${var.region}"
}

variable "container_port" {
    type = "string"
    default = "80"
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
    security_group_ids = ["sg-c161d4b3"]
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

resource "aws_ecs_task_definition" "definition" {
    family                   = "Nginx"
    container_definitions    = "${file("debug/files/task-definition.json")}"
    network_mode             = "awsvpc"
    cpu                      = "256"
    memory                   = "512"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn       = "arn:aws:iam::037083514056:role/ecs-role20171016145604531200000004"
}

resource "aws_ecs_service" "service" {
    name                               = "Fargate"
    task_definition                    = "${aws_ecs_task_definition.definition.arn}"
    desired_count                      = "1"
    cluster                            = "${aws_ecs_cluster.main.arn}"
    deployment_maximum_percent         = "200"
    deployment_minimum_healthy_percent = "50"

    launch_type                        = "FARGATE"
    network_configuration = {
        subnets         = "${var.subnet_ids}"
        security_groups = ["sg-8618d0f2"]
    }
}

resource "aws_lb_target_group" "target_group" {
    name_prefix          = "fgate-"
    port                 = "${var.container_port}"
    protocol             = "HTTP"
    vpc_id               = "${var.vpc_id}"
    target_type          = "ip"
    deregistration_delay = 300
    stickiness {
        type            = "lb_cookie"
        cookie_duration = 86400
        enabled         = "false"
    }
    health_check {
        interval            = "15"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        matcher             = "200-299"
    }
    tags {
        Name        = "Fargate"
        Project     = "${var.project}"
        Purpose     = "Maps the ALB to the back end containers"
        Creator     = "${var.creator}"
        Environment = "${var.environment}"
        Freetext    = "No notes yet"
    }
}

resource "aws_lb_listener_rule" "insecure_rule" {
    listener_arn = "${module.alb.insecure_listener_arn}"
    priority     = "1"
    action = {
        target_group_arn = "${aws_lb_target_group.target_group.arn}"
        type             = "forward"
    }
    condition = {
        field = "path-pattern"
        values = ["/*"]
    }
}
