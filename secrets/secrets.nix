let
  mandalore = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfJk6Sjjr704jT+YwBT01nxEQLvZC9SThQiLbr1a3BJ";
  millenium-falcon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPSGQkg+lmetJAVsd0Ojy76ehuoc2aJuIP03f08Ny0lQ";
in
{
  /* backups */
  "restic-password.age".publicKeys = [ mandalore millenium-falcon ];
  "backblaze-b2-restic-s3-secrets.age".publicKeys = [ mandalore millenium-falcon ];

  /* paperless */
  "paperless-password.age".publicKeys = [ mandalore millenium-falcon ];

  /* uuid for healthchecks.io cronjob monitoring */
  "healthchecks-io-uuid.age".publicKeys = [ mandalore millenium-falcon ];
}
