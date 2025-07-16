resource "yandex_compute_snapshot_schedule" "daily_all_vms" {
  name        = "snapshot-all-vms"
  description = "Daily snapshot for all VM disks"

  schedule_policy {
    expression = "0 3 * * *"
  }

  snapshot_count   = 7
  retention_period = "168h"

 disk_ids = flatten([
    [for i in yandex_compute_instance.web           : i.boot_disk[0].disk_id],
    [yandex_compute_instance.grafana.boot_disk[0].disk_id],
    [yandex_compute_instance.prometheus.boot_disk[0].disk_id],
    [yandex_compute_instance.kibana.boot_disk[0].disk_id],
    [yandex_compute_instance.elasticsearch.boot_disk[0].disk_id],
  ])

  labels = {
    auto-delete = "7d"
    environment = "diploma"
  }
}