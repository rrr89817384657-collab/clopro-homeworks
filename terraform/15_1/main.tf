# Создаем VPC
resource "yandex_vpc_network" "main" {
  name = var.vpc_name
}

# Публичная подсеть
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = var.public_subnet_cidr
}

# Приватная подсеть с route table
resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = var.private_subnet_cidr
  route_table_id = yandex_vpc_route_table.private_route.id
}
