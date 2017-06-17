Run consul install:
  cmd.script:
    - name: install_consul
    - source: salt://consul/files/install_consul.sh
/etc/consul.d:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
consul:
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/consul.service
  file.managed:
    - name: /etc/systemd/system/consul.service
    - source: salt://consul/files/consul_agent.service
    - template: jinja
