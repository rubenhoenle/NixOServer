let
  mandalore = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfJk6Sjjr704jT+YwBT01nxEQLvZC9SThQiLbr1a3BJ";
in
{
  "restic-password.age".publicKeys = [ mandalore ];
  "backblaze-b2-restic-s3-secrets.age".publicKeys = [ mandalore ];
}
