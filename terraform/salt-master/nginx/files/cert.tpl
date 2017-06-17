{{with secret "pki/issue/nginx" "common_name=nginx.hashicorpdemo.com" "format=pem_bundle" }}
{{ .Data.certificate }}  {{ end }}
