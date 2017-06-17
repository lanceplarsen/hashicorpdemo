job "node" {
  datacenters = ["dc1"]
  type = "service"
  group "cache" {
    count = 3
    task "node" {
      driver = "docker"
      config {
        image = "us.gcr.io/llarsen-hashicorp-demo/nodetranslate:latest"
	volumes = ["new/config.js:/usr/src/app/config.js"]
        dns_servers = ["169.254.1.1"]
        port_map {
          app = 3000
        }

      }

      artifact {
        source = "https://storage.googleapis.com/llarsen-hashicorp-bucket/nomad/api_config.tpl"
      }

      template {
        source        = "local/api_config.tpl"
        destination   = "new/config.js"
        change_mode   = "restart"
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
        network {
          mbits = 10
          port "app" {}
        }
      }

      service {
        name = "nodetranslate"
        tags = ["global", "node"]
        port = "app"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      vault {
        policies = ["api_policy"]
      }

    }
  }
}
