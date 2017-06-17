Run vault install:
  cmd.script:
    - name: install_vault
    - source: salt://vault/files/install_vault.sh
/etc/vault.d:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
vault:
  service.running:
    - enable: True
    - watch:
      - file: /etc/vault.d/vault.hcl
      - file: /etc/systemd/system/vault.service
/etc/vault.d/vault.hcl:
  file.managed:
    - name: /etc/vault.d/vault.hcl
    - source: salt://vault/files/vault.hcl
/etc/systemd/system/vault.service:
  file.managed:
    - name: /etc/systemd/system/vault.service
    - source: salt://vault/files/vault.service
