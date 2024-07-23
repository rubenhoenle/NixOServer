{
  age.identityPaths = [ "/home/ruben/.ssh/id_ed25519" ];
  age.secrets.resticPassword = {
    file = ../secrets/restic-password.age;
    owner = "ruben";
    group = "backup";
    mode = "440";
  };
  age.secrets.backblazeB2ResticS3EnvironmentSecrets = {
    file = ../secrets/backblaze-b2-restic-s3-secrets.age;
    owner = "ruben";
    group = "backup";
    mode = "440";
  };
  age.secrets.paperlessPassword = {
    file = ../secrets/paperless-password.age;
    owner = "paperless";
    group = "paperless";
    mode = "400";
  };
  age.secrets.gickupGithubToken = {
    file = ../secrets/gickup-github-token.age;
    owner = "gickup";
    group = "gickup";
    mode = "400";
  };

  /* ovh */
  age.secrets.ovhApplicationKey = {
    file = ../secrets/ovh/application-key.age;
    owner = "acme";
    group = "acme";
    mode = "400";
  };
  age.secrets.ovhApplicationSecret = {
    file = ../secrets/ovh/application-secret.age;
    owner = "acme";
    group = "acme";
    mode = "400";
  };
  age.secrets.ovhConsumerKey = {
    file = ../secrets/ovh/consumer-key.age;
    owner = "acme";
    group = "acme";
    mode = "400";
  };

  /* bk nextcloud backup */
  age.secrets.bkNextcloudBackupNetrc = {
    file = ../secrets/bk-nextcloud-backup-netrc.age;
    owner = "bk_nc_backup";
    group = "bk_nc_backup";
    mode = "400";
    path = "/home/bk_nc_backup/.netrc";
  };

  /* syncthing */
  age.secrets.syncthingKey = {
    file = ../secrets/syncthing/syncthing-key.age;
    owner = "syncthing";
    group = "syncthing";
    mode = "400";
  };
  age.secrets.syncthingCert = {
    file = ../secrets/syncthing/syncthing-cert.age;
    owner = "syncthing";
    group = "syncthing";
    mode = "400";
  };
}
