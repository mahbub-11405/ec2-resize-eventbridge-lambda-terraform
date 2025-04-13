provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "./modules/network"
}

module "ec2" {
  source        = "./modules/ec2"
  subnet_id     = module.network.public_subnet_id
  instance_type = "t4g.small"  # Initial ARM instance
  ami_id        = data.aws_ami.ubuntu_arm.id
}

module "lambda" {
  source      = "./modules/lambda"
  instance_id = module.ec2.instance_id
  lambda_name = "ec2_resize_arm_lambda"
  role_name   = "ec2_lambda_execution_role"
}

module "resize_to_large" {
  source      = "./modules/eventbridge"
  name        = "resize-to-large"
  schedule    = "cron(0 1 25 * ? *)" # 1 AM on the 25th of every month
  lambda_arn  = module.lambda.lambda_arn
  lambda_name = module.lambda.lambda_name
  instance_id = module.ec2.instance_id
  target_type = "c7g.xlarge"
}

module "resize_to_small" {
  source      = "./modules/eventbridge"
  name        = "resize-to-small"
  schedule    = "cron(0 1 5 * ? *)" # 1 AM on the 5th of every month
  lambda_arn  = module.lambda.lambda_arn
  lambda_name = module.lambda.lambda_name
  instance_id = module.ec2.instance_id
  target_type = "t4g.small"
}

# Ubuntu ARM64 AMI
data "aws_ami" "ubuntu_arm" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}
