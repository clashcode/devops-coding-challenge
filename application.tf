

resource "aws_ecs_cluster" "cluster" {
  name = "testapp"
}

resource "aws_ecs_cluster_capacity_providers" "capacity_providers" {
  cluster_name = aws_ecs_cluster.cluster.name
}

resource "aws_lb" "testapp" {
  name               = aws_ecs_cluster.cluster.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [ aws_security_group.testapp.id ]
  subnets            = var.subnets
}

resource "aws_lb_listener" "testapp" {
  load_balancer_arn = aws_lb.testapp.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.testapp.arn
  }
}

resource "aws_lb_target_group" "testapp" {
  name     = "testapp"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_security_group.testapp.vpc_id

  health_check {
    matcher = "200"
    path = "/"
    port = 80
  }
}

resource "aws_ecs_task_definition" "testapp" {
  family = "testapp"

  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048

  network_mode       = "awsvpc"

  container_definitions = jsonencode([
    {
      name         = "testapp"
      image        = "yeasy/simple-web:latest"
      essential    = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      environment = [
        { name = "HTTPPORT", value = "80" },
        { name = "MEM_MX", value = "2048m" },
        { name = "DB_DEFAULT_URL", value = "jdbc:postgresql://testapp.eu-west-1.rds.amazonaws.com:5432/testapp" },
        { name = "DB_DEFAULT_USER", value = "testapp" },
        { name = "DB_DEFAULT_PASSWORD", value = "xw3489sf" },
        { name = "S3_BUCKET", value = aws_s3_bucket.bucket.bucket }
      ]
    }
  ])
}

resource "aws_ecs_service" "testapp" {
  name            = "testapp"
  cluster         = aws_ecs_cluster.cluster.name
  task_definition = "${aws_ecs_task_definition.testapp.id}:${aws_ecs_task_definition.testapp.revision}"

  health_check_grace_period_seconds = 30
  desired_count = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.testapp.arn
    container_name   = "testapp"
    container_port   = 80
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = 1
  }

  network_configuration {
    subnets            = aws_lb.testapp.subnets
    security_groups    = aws_lb.testapp.security_groups
    assign_public_ip   = true
  }

}

resource "aws_security_group" "testapp" {
  name        = "testapp"
  description = "Security group for testapp"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
