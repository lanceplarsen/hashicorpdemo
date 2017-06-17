# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/tmp/nomad"

# Enable the server
server {
    enabled = true

    # Self-elect, should be 3 or 5 for production
    bootstrap_expect = 1
}


vault {
  enabled = true
  address = "http://vault.service.consul:8200"
  token   = "05ada700-12cf-1d2d-cf66-fd4d2a99a59b"
}
