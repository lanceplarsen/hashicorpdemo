path "secret/api_keys/*" {
  policy = "read"
}

path "auth/token/lookup-self" {
  policy = "read"
}
