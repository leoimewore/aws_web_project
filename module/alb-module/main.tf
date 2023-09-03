
resource "aws_security_group" "ec_eg1" {
  vpc_id = var.vpc-id
  name = "ssh-http"
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    protocol = "TCP"
    to_port = 22
  }

   ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 80
    protocol = "TCP"
    to_port = 80
  }


  egress{
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    to_port = 0
    protocol = -1
  }


  tags = {
    "Name" = "ssh-http"
  }
}


resource "aws_security_group" "al_eg1" {
  vpc_id = var.vpc-id
  name = "lb-traffic"
  

   ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 80
    protocol = "TCP"
    to_port = 80
  }


  egress{
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    to_port = 0
    protocol = -1
  }


  tags = {
    "Name" = "lb-traffic"
  }
}



















resource "aws_lb" "public" {

  
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.al_eg1.id]
  subnets= var.public_subnets
  

  enable_deletion_protection = false
  depends_on = [  ]



  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc-id
}

resource "aws_lb_target_group" "test" {
  name       = "my-app-eg1"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = var.vpc-id
  slow_start = 0

  load_balancing_algorithm_type = "round_robin"

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

   health_check {
    enabled             = true
    port                = 80
    interval            = 30
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}


resource "aws_instance" "myec2" {
    ami = var.ami
    instance_type = "t2.micro"
    count ="${length(var.public_subnets)}"
    subnet_id = "${element(var.public_subnets,count.index)}"
    associate_public_ip_address = true
    user_data = "${file("install_yum.sh")}"
    vpc_security_group_ids = [aws_security_group.ec_eg1.id]
    tags = {
        Name ="ec2-${count.index}"
    }
  
}


resource "aws_lb_target_group_attachment" "test1" {
  count ="${length(var.public_subnets)}"
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = "${element(aws_instance.myec2.*.id,count.index)}"
  port             = 80
}

resource "aws_lb_listener" "front_end" {
    load_balancer_arn = aws_lb.public.arn
    port = "80"
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.test.arn
    }
  
}