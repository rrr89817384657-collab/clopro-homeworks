# NAT-инстанс с фиксированным IP 192.168.10.254
resource "yandex_compute_instance" "nat" {
  name = "nat-instance"
  
  resources {
    cores  = 2
    memory = 2
  }
  
  boot_disk {
    initialize_params {
      image_id = var.nat_image_id
      size     = 10
    }
  }
  
  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat        = true
  }
  
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

# Output для NAT
output "nat_public_ip" {
  value = yandex_compute_instance.nat.network_interface[0].nat_ip_address
  description = "Public IP of NAT instance"
}

output "nat_internal_ip" {
  value = yandex_compute_instance.nat.network_interface[0].ip_address
  description = "Internal IP of NAT instance"
}
