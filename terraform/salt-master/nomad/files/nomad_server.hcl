# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/opt/nomad"

# Enable the server
server {
    enabled = true

    # Self-elect, should be 3 or 5 for production
    bootstrap_expect = 1
}


vault {
  enabled = true
  address = "http://vault.service.consul:8200"
  token   = "c48754f8-b8cc-2d57-de91-3a8fd46b1259"
}
