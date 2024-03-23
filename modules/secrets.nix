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
    owner = "ruben";
    group = "users";
  };
  age.secrets.matrixMqttBridgeConfig = {
    file = ../secrets/matrix-mqtt-bridge-config.age;
    owner = "ruben";
    group = "users";
  };
  age.secrets.tandoorPostgresPassword = {
    file = ../secrets/tandoor-postgres-password.age;
    owner = "ruben";
    group = "users";
  };
  age.secrets.tandoorSecretKey = {
    file = ../secrets/tandoor-secret-key.age;
    owner = "ruben";
    group = "users";
  };
  age.secrets.gickupGithubToken = {
    file = ../secrets/gickup-github-token.age;
    owner = "ruben";
    group = "users";
  };
  age.secrets.ovhApplicationKey = {
    file = ../secrets/ovh/application-key.age;
    owner = "acme";
    group = "acme";
  };
  age.secrets.ovhApplicationSecret = {
    file = ../secrets/ovh/application-secret.age;
    owner = "acme";
    group = "acme";
  };
  age.secrets.ovhConsumerKey = {
    file = ../secrets/ovh/consumer-key.age;
    owner = "acme";
    group = "acme";
  };
}
