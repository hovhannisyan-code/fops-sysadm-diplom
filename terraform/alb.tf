### 1. Target Group ###
resource "yandex_alb_target_group" "web" {
  name = "alb-tg-web"

  dynamic "target" {
    for_each = yandex_compute_instance.web
    content {
      subnet_id  = target.value.network_interface[0].subnet_id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

### 2. Backend Group ###
resource "yandex_alb_backend_group" "web" {
  name = "alb-bg-web"

  http_backend {
    name             = "web-backend"
    port             = 80
    target_group_ids = [yandex_alb_target_group.web.id]

    load_balancing_config {
      panic_threshold = 50
    }

    healthcheck {
      interval = "2s"
      timeout  = "1s"

      http_healthcheck {
        path = "/"
      }
    }
  }
}

### 3. HTTP Router ###
resource "yandex_alb_http_router" "web" {
  name = "alb-router-web"
}

### 4. Virtual Host + Routing Rule ###
resource "yandex_alb_virtual_host" "web" {
  name           = "alb-vhost-web"
  http_router_id = yandex_alb_http_router.web.id
  authority      = ["*"]

  route {
    name = "route-to-web"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
        timeout          = "3s"
      }

      http_match {
        path {
          prefix = "/"
        }
      }
    }
  }
}

### 5. Load Balancer ###
resource "yandex_alb_load_balancer" "web" {
  name       = "alb-web"
  network_id = yandex_vpc_network.this.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet_a.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet_b.id
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }
}


