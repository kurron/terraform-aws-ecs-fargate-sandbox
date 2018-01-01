# Overview
This Terraform module creates a sandbox with an [ALB](https://aws.amazon.com/elasticloadbalancing/) fronting an [ECS](https://aws.amazon.com/ecs/) cluster with [Fargate](https://aws.amazon.com/fargate/) launched containers.

**NOTE:** this isn't working yet.  I don't get errors during deployment but the task never fully comes up and nothing gets sent to the logs.  Given that EC2 instances are no longer involved, I can't SSH into the box and poke around.   Currently, I've tried disconnecting the service from the ALB so see if I can get further but no joy.  My guess is that there is either a missing resource I need to create or there is an issue with the IAM Role.

# Prerequisites
* [Terraform](https://terraform.io/) installed and working
* Development and testing was done on [Ubuntu Linux](http://www.ubuntu.com/)
* Working AWS account and API keys

# Building
Since this is just a collection of Terraform scripts, there is nothing to build.

# Installation
This module is not installed but, instead, is obtained by the project using the module.  See [kurron/terraform-environments](https://github.com/kurron/terraform-environments) for example usage.

# Tips and Tricks

## Debugging
The `debug` folder contains files that can be used to test out local changes
to the module.  Edit `backend.cfg` and `plan.tf` to your liking and
then run `debug/debug-module.sh` to test your changes.

# Troubleshooting

# License and Credits
This project is licensed under the [Apache License Version 2.0, January 2004](http://www.apache.org/licenses/).
[Deploying FARGATE services using CloudFormation: The guide I wish I had](https://blog.devopspro.co.uk/deploying-fargate-services-using-cloudformation-the-guide-i-wish-i-had-d89b6dc62303)

# List of Changes
