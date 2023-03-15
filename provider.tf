provider "aws" {
  region = "eu-west-1"
}

variable "vpc_id" { type = string }
variable "subnets" { type = list(string) }
