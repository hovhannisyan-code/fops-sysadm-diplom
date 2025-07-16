resource "yandex_vpc_network" "this" {
  name = "diploma-network"
}

resource "yandex_vpc_gateway" "nat" {
  name  = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat_route" {
  network_id = yandex_vpc_network.this.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_subnet" "subnet_a" {
  name           = "subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = ["10.10.0.0/24"]

  route_table_id = yandex_vpc_route_table.nat_route.id
}

resource "yandex_vpc_subnet" "subnet_b" {
  name           = "subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = ["10.20.0.0/24"]

  route_table_id = yandex_vpc_route_table.nat_route.id
}


resource "yandex_vpc_security_group" "bastion_sg" {
  name       = "bastion-sg"
  network_id = yandex_vpc_network.this.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "web_sg" {
  name       = "web-sg"
  network_id = yandex_vpc_network.this.id

  ingress {
    protocol          = "TCP"
    description       = "Allow SSH only from bastion"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion_sg.id
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow HTTP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "TCP"
    port              = 9100
    description       = "Allow Prometheus access to Node Exporter"
    v4_cidr_blocks    = ["10.10.0.0/24", "10.20.0.0/24"]
  }

  ingress {
    protocol       = "TCP"
    port           = 9113
    description    = "Allow Prometheus to access nginx exporter"
    v4_cidr_blocks = ["10.10.0.0/24", "10.20.0.0/24"]
  }

  ingress {
    protocol       = "TCP"
    port           = 4040
    description    = "Allow Prometheus to access nginx log exporter"
    v4_cidr_blocks = ["10.10.0.0/24", "10.20.0.0/24"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "yandex_vpc_security_group" "prometheus_sg" {
  name       = "prometheus-sg"
  network_id = yandex_vpc_network.this.id

  ingress {
    protocol          = "TCP"
    port              = 9100 # node exporter
    description       = "Allow access to Node Exporter from web"
    v4_cidr_blocks    = ["10.10.0.0/24"]
  }

  ingress {
    protocol       = "TCP"
    port           = 9113
    description    = "Allow Prometheus to access nginx exporter"
    v4_cidr_blocks = ["10.10.0.0/24", "10.20.0.0/24"]
  }

   ingress {
    protocol       = "TCP"
    port           = 4040
    description    = "Allow Prometheus to access nginx log exporter"
    v4_cidr_blocks = ["10.10.0.0/24", "10.20.0.0/24"]
  }

  ingress {
    protocol          = "TCP"
    port              = 9090
    description       = "Allow access to Prometheus from Grafana"
    security_group_id = yandex_vpc_security_group.grafana_sg.id
  }

  ingress {
    protocol          = "TCP"
    port              = 8080 # nginx exporter
    description       = "Allow access to Nginx Exporter from web"
    v4_cidr_blocks    = ["10.10.0.0/24", "10.20.0.0/24"]
  }

  ingress {
    protocol          = "TCP"
    port              = 22
    description       = "SSH from bastion"
    security_group_id = yandex_vpc_security_group.bastion_sg.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "grafana_sg" {
  name       = "grafana-sg"
  network_id = yandex_vpc_network.this.id

  ingress {
    protocol       = "TCP"
    port           = 3000
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Allow Grafana UI access"
  }



  ingress {
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion_sg.id
    description       = "SSH from bastion"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "yandex_vpc_subnet" "subnet_logging" {
  name           = "subnet-logging"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = ["10.30.0.0/24"]

  route_table_id = yandex_vpc_route_table.nat_route.id
}

resource "yandex_vpc_security_group" "efk_sg" {
  name       = "efk-sg"
  network_id = yandex_vpc_network.this.id

  ingress {
    protocol       = "TCP"
    port           = 9200
    v4_cidr_blocks = ["10.0.0.0/8"]
    description    = "Allow access to Elasticsearch from internal network"
  }

  ingress {
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Allow access to Kibana UI"
  }

  ingress {
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion_sg.id
    description       = "SSH from bastion"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}