module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"

    name = "${var.env_prefix}-vpc"
    cidr = var.vpc_cidr_block

    azs             = [var.avail_zone_1 , var.avail_zone_2]
    public_subnets  = [var.vpc_pubic_subnet_1, var.vpc_pubic_subnet_2]
    private_subnets = [var.vpc_private_subnet_1 , var.vpc_private_subnet_2]
    intra_subnets   = [var.vpc_intra_subnet_1 , var.vpc_intra_subnet_2]

    enable_nat_gateway = true
    single_nat_gateway = true

    public_subnet_tags = {
        "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
    }
  
    tags = {
        Name = "${var.env_prefix}_vpc"
    }
}