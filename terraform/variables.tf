variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "service_account_key_file" {
  description = "Path to the service account key JSON file"
  type        = string
  default     = "~/.authorized_key.json"
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
}

variable "instance_name" {
  description = "Name of the instance"
  type        = string
  default     = "vm" 
}

variable "platform_id" {
  description = "ID of the platform"
  type        = string
  default     = "standard-v2"
}

variable "zone" {
  description = "Zone to create the instance in"
  type        = string
  default     = "ru-central1-a"  
}

variable "cpu" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Amount of memory in GB"
  type        = number
  default     = 2
}

variable "core_fraction" {
  description = "Core fraction"
  type        = number
  default     = 20
}

variable "disk_size" {
  description = "Size of the boot disk in GB"
  type        = number
  default     = 20
}

variable "image_id" {
  description = "ID of the image to use for the boot disk"
  type        = string
}


#network

variable "network_name" {
  description = "Name of VPC network"
  type        = string
  default     = "my-vpc"
}

variable "subnet_name" {
  description = "Name of subnet"
  type        = string
  default     = "my-subnet"
}

variable "cidr_blocks" {
  description = "CIDR blocks for the subnet"
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "create_nat_gateway" {
  description = "Create NAT-gateway?"
  type        = bool
  default     = true
}

variable "attach_public_ip" {
  description = "Attach public IP to the instance?"
  type        = bool
  default     = true  
}