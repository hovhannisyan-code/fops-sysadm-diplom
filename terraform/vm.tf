resource "yandex_compute_instance" "web" {
  count = 2

  name        = "web-${count.index + 1}"
  zone        = element(["ru-central1-a", "ru-central1-b"], count.index)
  platform_id = var.platform_id

  resources {
    cores         = var.cpu
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk_size
    }
  }

  network_interface {
    subnet_id          = count.index == 0 ? yandex_vpc_subnet.subnet_a.id : yandex_vpc_subnet.subnet_b.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web_sg.id]
  }

  metadata = {
    user-data          = file("${path.module}/metadata.yml")
    serial-port-enable = 1
  }
}


resource "yandex_compute_instance" "prometheus" {
  name        = "prometheus"
  zone        = "ru-central1-b"
  platform_id = var.platform_id

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_b.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.prometheus_sg.id]
  }

  metadata = {
    user-data          = file("${path.module}/metadata.yml")
    serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "grafana" {
  name        = "grafana"
  zone        = "ru-central1-b"
  platform_id = var.platform_id

  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_b.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.grafana_sg.id]
  }

  metadata = {
    user-data          = file("${path.module}/metadata.yml")
    serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "elasticsearch" {
  name        = "elasticsearch"
  zone        = "ru-central1-b"
  platform_id = var.platform_id

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_logging.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.efk_sg.id]
  }

  metadata = {
    user-data          = file("${path.module}/metadata.yml")
    serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  zone        = "ru-central1-b"
  platform_id = var.platform_id

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_logging.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.efk_sg.id]
  }

  metadata = {
    user-data          = file("${path.module}/metadata.yml")
    serial-port-enable = 1
  }
}
