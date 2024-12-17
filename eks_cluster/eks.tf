/*provider "aws" {
    region = "ca-central-1"
    access_key = "AKIAU6GDX3MJGI5LNZM2"
    secret_key = "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"
}*/


module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 20.0"

    # EKS Cluster Name and Version
    cluster_name    = "${var.env_prefix}-k8-cluster"
    cluster_version = "1.31"

    # Indicates EKS public API server endpoint is enabled
    cluster_endpoint_public_access  = true

    # EKS Addons
    cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    }

    # EKS Cluster Network Specification
    vpc_id                   = module.vpc.vpc_id
    subnet_ids               = module.vpc.private_subnets
    control_plane_subnet_ids = module.vpc.intra_subnets

    #cluster_primary_security_group_id = module.vpc.default_security_group_id

    # EKS Managed Node Group(s)
    eks_managed_node_group_defaults = {
    instance_types = ["${var.instance_type_default}"]
    }

    eks_managed_node_groups = {
        test-env-ng = {
            ami_type       = "${var.ami_type}"
            instance_types = ["${var.instance_type}"]

            min_size     = 2
            max_size     = 3
            desired_size = 2

            tags = {
            Name = "${var.env_prefix}_k8_node"
            }
        }
    }

    # Cluster access entry -> To add the current caller identity as an administrator
    enable_cluster_creator_admin_permissions = true

    tags = {
        Environment = "${var.env_prefix}"
        Terraform   = "true"
    }
}

