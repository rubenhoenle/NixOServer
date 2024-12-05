{
  age.identityPaths = [ "/home/ruben/.ssh/id_ed25519" ];
  age.secrets.resticPassword = {
    file = ../secrets/restic-password.age;
    owner = "root";
    group = "root";
    mode = "440";
  };
  age.secrets.backblazeB2ResticS3EnvironmentSecrets = {
    file = ../secrets/backblaze-b2-restic-s3-secrets.age;
    owner = "root";
    group = "root";
    mode = "440";
  };
  age.secrets.healthchecksIoUuid = {
    file = ../secrets/healthchecks-io-uuid.age;
    owner = "root";
    group = "root";
    mode = "440";
  };
  age.secrets.paperlessPassword = {
    file = ../secrets/paperless-password.age;
    owner = "paperless";
    group = "paperless";
    mode = "400";
  };
}
