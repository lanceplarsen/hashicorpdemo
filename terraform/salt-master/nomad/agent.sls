Run nomad install:
  cmd.script:
    - name: install_nomad
    - source: salt://nomad/files/install_nomad.sh
/etc/nomad.d:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
nomad:
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/nomad.service
      - file: /etc/nomad.d/nomad.hcl
/etc/nomad.d/nomad.hcl:
  file.managed:
    - name: /etc/nomad.d/nomad.hcl
    - source: salt://nomad/files/nomad_agent.hcl
/etc/systemd/system/nomad.service:
  file.managed:
    - name: /etc/systemd/system/nomad.service
    - source: salt://nomad/files/nomad_agent.service
    - template: jinja
