let
  mandalore = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfJk6Sjjr704jT+YwBT01nxEQLvZC9SThQiLbr1a3BJ";
in
{
  "restic-password.age".publicKeys = [ mandalore ];
  "backblaze-b2-restic-s3-secrets.age".publicKeys = [ mandalore ];
  "paperless-password.age".publicKeys = [ mandalore ];
  "matrix-mqtt-bridge-config.age".publicKeys = [ mandalore ];
  "tandoor-postgres-password.age".publicKeys = [ mandalore ];
  "tandoor-secret-key.age".publicKeys = [ mandalore ];
  "gickup-github-token.age".publicKeys = [ mandalore ];
}
