output "foo" {
    value = "${aws_lb.alb.id}"
    description = "ID of the created ALB"
}
