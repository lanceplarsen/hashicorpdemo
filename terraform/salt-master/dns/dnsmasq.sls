salt://dns/files/dummy_interface.sh:
  cmd.script
/etc/dnsmasq.d:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
/etc/systemd/network/dummy0.netdev:
  file.managed:
    - name: /etc/systemd/network/dummy0.netdev
    - source: salt://dns/files/dummy0.netdev 
/etc/systemd/network/dummy0.network:
  file.managed:
    - name: /etc/systemd/network/dummy0.network
    - source: salt://dns/files/dummy0.network
systemd-networkd:
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/network/dummy0.netdev
      - file: /etc/systemd/network/dummy0.network
/etc/dnsmasq.d/consul.conf:
  file.managed:
    - name: /etc/dnsmasq.d/consul.conf
    - source: salt://dns/files/dnsmasq_consul.conf
dnsmasq:
  pkg.installed:
    - name: dnsmasq
  service.running:
    - name: dnsmasq
    - enable: True
    - watch:
      - file: /etc/dnsmasq.d/consul.conf
