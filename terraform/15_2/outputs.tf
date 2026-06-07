output "bucket_url" {
  value = "http://${yandex_storage_bucket.images.bucket_domain_name}/${yandex_storage_object.picture.key}"
  description = "URL картинки в Object Storage"
}

output "instance_ips" {
  description = "IP адреса всех ВМ в группе"
  value = [for instance in yandex_compute_instance_group.lamp_group.instances : instance.network_interface[0].nat_ip_address]
}
