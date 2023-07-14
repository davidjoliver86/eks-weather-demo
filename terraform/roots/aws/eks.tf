module "eks" {
  source       = "../../modules/aws/eks"
  cluster_name = "weather"
  subnet_ids   = concat(module.vpc.subnet_ids.public, module.vpc.subnet_ids.private)
}

module "eks_node_group" {
  source          = "../../modules/aws/eks_node_group"
  cluster_name    = module.eks.cluster_name
  node_group_name = "weather-ng"
  subnet_ids      = module.vpc.subnet_ids.private
  desired_size    = 2
  max_size        = 2
  min_size        = 1
  instance_types  = ["t3.medium"]

  depends_on = [
    module.eks
  ]
}
