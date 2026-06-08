# Security group для публичной подсети
resource "yandex_vpc_security_group" "public_sg" {
  name        = "public-sg"
  description = "Security group for public subnet"
  network_id  = yandex_vpc_network.main.id
  
  ingress {
    protocol       = "TCP"
    description    = "SSH from anywhere"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  
  ingress {
    protocol       = "ICMP"
    description    = "ICMP for testing"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# Security group для приватной подсети
resource "yandex_vpc_security_group" "private_sg" {
  name        = "private-sg"
  description = "Security group for private subnet"
  network_id  = yandex_vpc_network.main.id
  
  ingress {
    protocol       = "TCP"
    description    = "SSH from public subnet"
    v4_cidr_blocks = var.public_subnet_cidr
    port           = 22
  }
  
  ingress {
    protocol       = "ICMP"
    description    = "ICMP from public subnet"
    v4_cidr_blocks = var.public_subnet_cidr
  }
  
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
