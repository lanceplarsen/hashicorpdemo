# See https://cloud.google.com/compute/docs/load-balancing/network/example


provider "google" {
  region      = "${var.region}"
  project     = "${var.project_name}"
  credentials = "${file("${var.credentials_file_path}")}"
}

resource "google_compute_instance" "saltmaster" {

  name         = "tf-saltmaster-0"
  machine_type = "n1-standard-2"
  zone         = "${var.region_zone}"
  tags         = ["saltmaster"]

  disk {
    image = "ubuntu-1604-xenial-v20170516-saltmaster-dev"
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral
    }
  }

  metadata {
    ssh-keys = "root:${file("${var.public_key_path}")}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }

    inline = [
	  "sudo mkdir -p /srv/salt",
	  "sudo mkdir -p /etc/salt",
    ]
  }

  provisioner "file" {
    source      = "salt-master/"
    destination = "/srv/salt"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }
  }

  provisioner "file" {
    source      = "salt-master/master"
    destination = "/etc/salt/master"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }
  }
  
  provisioner "file" {
    source      = "salt-master/minion"
    destination = "/etc/salt/minion"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }
  }
  
  provisioner "file" {
    source      = "salt-master/minion"
    destination = "/etc/salt/minion"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }
  }
  
  provisioner "file" {
    source      = "salt-master/minion_id"
    destination = "/etc/salt/minion_id"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }

    inline = [
	  "sudo service salt-minion restart",
	  "sudo service salt-master restart",
    ]
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}


resource "google_compute_instance" "nginx" {

  name         = "tf-nginx-0"
  machine_type = "n1-standard-2"
  zone         = "${var.region_zone}"
  tags         = ["nginx"]

  disk {
    image = "ubuntu-1604-xenial-v20170516"
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral
    }
  }

  metadata {
    ssh-keys = "root:${file("${var.public_key_path}")}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }

    inline = [
	  "curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com",
	  "sudo sh bootstrap-salt.sh -A ${google_compute_instance.saltmaster.network_interface.0.address} git develop",
    ]
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

}

resource "google_compute_instance" "vault" {

  name         = "tf-vault-0"
  machine_type = "n1-standard-2"
  zone         = "${var.region_zone}"
  tags         = ["vault"]

  disk {
    image = "ubuntu-1604-xenial-v20170516"
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral
    }
  }

  metadata {
    ssh-keys = "root:${file("${var.public_key_path}")}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }

    inline = [
	  "curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com",
	  "sudo sh bootstrap-salt.sh -A ${google_compute_instance.saltmaster.network_interface.0.address} git develop",
    ]
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

}

resource "google_compute_instance" "consul" {

  name         = "tf-consul-0"
  machine_type = "n1-standard-2"
  zone         = "${var.region_zone}"
  tags         = ["consul"]

  disk {
    image = "ubuntu-1604-xenial-v20170516"
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral
    }
  }

  metadata {
    ssh-keys = "root:${file("${var.public_key_path}")}"
  }



  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }

    inline = [
	  "curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com",
	  "sudo sh bootstrap-salt.sh -A ${google_compute_instance.saltmaster.network_interface.0.address} git develop",
    ]
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

}



resource "google_compute_instance" "docker" {
  count = 3

  name         = "tf-docker-${count.index}"
  machine_type = "n1-standard-2"
  zone         = "${var.region_zone}"
  tags         = ["docker"]

  disk {
    image = "ubuntu-1604-xenial-v20170516"
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral
    }
  }

  metadata {
    ssh-keys = "root:${file("${var.public_key_path}")}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }

    inline = [
	  "curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com",
	  "sudo sh bootstrap-salt.sh -A ${google_compute_instance.saltmaster.network_interface.0.address} git develop",
    ]
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly","https://www.googleapis.com/auth/cloud-platform.read-only"]
  }

}

resource "google_compute_instance" "nomad" {
  count = 1

  name         = "tf-nomad-${count.index}"
  machine_type = "n1-standard-2"
  zone         = "${var.region_zone}"
  tags         = ["nomad"]

  disk {
    image = "ubuntu-1604-xenial-v20170516"
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral
    }
  }

  metadata {
    ssh-keys = "root:${file("${var.public_key_path}")}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }

    inline = [
	  "curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com",
	  "sudo sh bootstrap-salt.sh -A ${google_compute_instance.saltmaster.network_interface.0.address} git develop",
    ]
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

}

resource "google_compute_firewall" "consul" {
  name    = "allow-consul"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8500"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["consul"]
}


resource "google_compute_firewall" "nginx" {
  name    = "allow-nginx"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["nginx"]
}
