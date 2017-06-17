#Apply Iptables
debconf-utils:
  pkg.installed
iptables-debconf:
  debconf.set:
    - name: iptables
    - data:
        'iptables-persistent/autosave_v4':  {'type': 'boolean', 'value': True}
        'iptables-persistent/autosave_v6':  {'type': 'boolean', 'value': True}
iptables-persistent:
  pkg.installed
netfilter-persistent.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/iptables/rules.v4
  file.managed:
  - name: /etc/iptables/rules.v4
  - source: salt://dns/files/iptables.v4
#Update the dhclient file to resovle dns locally
networking:
  service.running:
    - watch:
      - file: /etc/dhcp/dhclient.conf
  file.managed:
    - name: /etc/dhcp/dhclient.conf
    - source: salt://dns/files/dhclient.conf
