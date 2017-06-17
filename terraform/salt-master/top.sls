base:
  '*':
  - base
  'roles:docker':
  - match: grain
  - consul.docker
  - dns.dnsmasq
  - nomad.docker
  - docker.server
  'roles:consul':
  - match: grain
  - consul.server
  'roles:nomad':
  - match: grain
  - consul.agent
  - dns.iptables
  - nomad.server
  'roles:vault':
  - match: grain
  - consul.agent
  - vault.server
  'roles:nginx':
  - match: grain
  - consul.agent
  - dns.iptables
  - nginx.server
  'roles:saltmaster':
  - match: grain
  - nomad.agent
  - consul.agent
