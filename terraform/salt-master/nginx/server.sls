#Install NGINX
nginx:
  pkg.installed:
    - name: nginx
  service.running:
    - name: nginx
    - enable: True
#Apply the consul template
Run consul template install:
  cmd.script:
    - name: install_consul_template
    - source: salt://consul/files/install_consul_template.sh
consul_template:  
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/consul_template.service
      - file: /etc/consul.d/nginx.tpl
      - file: /etc/consul.d/cert.tpl
#Add the consul template files
/etc/systemd/system/consul_template.service:
  file.managed: 
    - name: /etc/systemd/system/consul_template.service
    - source: salt://nginx/files/nginx_consul_template.service
/etc/consul.d/nginx.tpl:
  file.managed:
    - name: /etc/consul.d/nginx.tpl
    - source: salt://nginx/files/nginx.tpl
/etc/consul.d/cert.tpl:
  file.managed:
    - name: /etc/consul.d/cert.tpl
    - source: salt://nginx/files/cert.tpl
