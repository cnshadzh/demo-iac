output "aws_auth_configmap_yaml" {
  description = "[DEPRECATED - use `var.manage_aws_auth_configmap`] Formatted yaml output for base aws-auth configmap containing roles used in cluster node groups/fargate profiles"
  value = module.eks.aws_auth_configmap_yaml
}