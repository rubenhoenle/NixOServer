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
  age.secrets.matrixMqttBridgeConfig = {
    file = ../secrets/matrix-mqtt-bridge-config.age;
    owner = "ruben";
    group = "users";
    mode = "400";
  };
  age.secrets.gickupGithubToken = {
    file = ../secrets/gickup-github-token.age;
    owner = "gickup";
    group = "gickup";
    mode = "400";
  };
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
  age.secrets.initialNextcloudPassword = {
    file = ../secrets/nextcloud/initial-nextcloud-password.age;
    owner = "nextcloud";
    group = "nextcloud";
    mode = "400";
  };
}
