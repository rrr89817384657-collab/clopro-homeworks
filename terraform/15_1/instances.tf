# Публичная виртуалка (bastion)
resource "yandex_compute_instance" "public_vm" {
  name = "public-vm"
  
  resources {
    cores  = 2
    memory = 2
  }
  
  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"
      size     = 10
    }
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }
  
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

# Приватная виртуалка (без публичного IP)
resource "yandex_compute_instance" "private_vm" {
  name = "private-vm"
  
  resources {
    cores  = 2
    memory = 2
  }
  
  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"
      size     = 10
    }
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = false
  }
  
  metadata = {
    ssh-keys = "ubuntu:${file("${path.module}/mykey.pub")}"
  }
}

# Outputs
output "public_vm_ip" {
  value = yandex_compute_instance.public_vm.network_interface[0].nat_ip_address
}

output "private_vm_ip" {
  value = yandex_compute_instance.private_vm.network_interface[0].ip_address
}
