resource "google_compute_network" "vpc_network" {
  name                    = "funk-custom-mode-network"
  auto_create_subnetworks = false
  project                 = "sandbox-io-289003"
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "funk-custom-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-west1"
project                 = "sandbox-io-289003"
  network       = google_compute_network.vpc_network.id
}

# Create a single Compute Engine instance
resource "google_compute_instance" "default" {
  name         = "funk-vm"
  machine_type = "f1-micro"
  zone         = "us-west1-a"
  project                 = "sandbox-io-289003"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Install Flask
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
 project                 = "sandbox-io-289003"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}
resource "google_compute_firewall" "flask" {
  name    = "flask-app-firewall"
  network = google_compute_network.vpc_network.id
 project                 = "sandbox-io-289003"
  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
  source_ranges = ["0.0.0.0/0"]
}

// A variable for extracting the external IP address of the VM
output "Web-server-URL" {
 value = join("",["http://",google_compute_instance.default.network_interface.0.access_config.0.nat_ip,":5000"])
}
