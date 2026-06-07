# Группа ВМ
resource "yandex_compute_instance_group" "lamp_group" {
  name               = "lamp-instance-group"
  folder_id          = var.folder_id
  service_account_id = yandex_iam_service_account.storage_sa.id
  
  instance_template {
    platform_id = "standard-v3"
    resources {
      cores  = 2
      memory = 2
    }
    
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = var.lamp_image_id
        size     = 10
      }
    }
    
    network_interface {
      network_id = yandex_vpc_network.develop.id
      subnet_ids = [yandex_vpc_subnet.develop.id]
      nat        = true
      security_group_ids = [yandex_vpc_security_group.example.id]
    }
    
    metadata = {
      user-data = templatefile("${path.module}/startup.sh", {
        bucket_domain = yandex_storage_bucket.images.bucket_domain_name
        image_key     = yandex_storage_object.picture.key
      })
    }
    
    scheduling_policy {
      preemptible = false
    }
  }
  
  scale_policy {
    fixed_scale {
      size = var.instance_count
    }
  }
  
  allocation_policy {
    zones = [var.default_zone]
  }
  
  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }
  
  health_check {
    interval = 30
    timeout  = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    
    http_options {
      port = 80
      path = "/"
    }
  }
  
  depends_on = [yandex_storage_object.picture]
}

# Целевая группа для балансировщика
resource "yandex_lb_target_group" "web_group" {
  name      = "web-target-group"
  folder_id = var.folder_id
  
  dynamic "target" {
    for_each = yandex_compute_instance_group.lamp_group.instances
    content {
      subnet_id = yandex_vpc_subnet.develop.id
      address   = target.value.network_interface[0].ip_address
    }
  }
}

# Сетевой балансировщик
resource "yandex_lb_network_load_balancer" "web_balancer" {
  name = "web-network-balancer"
  
  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  
  attached_target_group {
    target_group_id = yandex_lb_target_group.web_group.id
    
    healthcheck {
      name = "http-health-check"
      interval = 30
      timeout  = 10
      healthy_threshold   = 2
      unhealthy_threshold = 3
      
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}