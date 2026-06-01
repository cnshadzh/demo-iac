output "clusters_ksm_arn" {
  #value       = "${aws_kms_key.apps.*.arn}"
  value       = tomap({
    for entry in aws_kms_alias.clusters :
    entry.arn => entry.target_key_id
  })
  description = "Clusters sops kms key arn"
}

output "products_ksm_arn" {
  #value       = "${aws_kms_key.apps.*.arn}"
  value       = tomap({
    for k in aws_kms_alias.products :
    k.arn => k.target_key_id
  })
  description = "products sops kms key arn"
}
