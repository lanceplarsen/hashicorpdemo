module.exports = {
  "api_key": "{{ with secret "secret/api_keys/nodetranslate" }}{{ .Data.key }}{{ end }}"
};
