{ config, pkgs, lib, ... }:
with lib;
let
  volumeBasePath = "/home/ruben/services/podman/tandoor";
  podmanNetworkName = "tandoor-net";
  postgresDatabase = "djangodb";
  postgresUsername = "djangouser";
  postgresPasswordFile = config.age.secrets.tandoorPostgresPassword.path;
  secretKeyFile = config.age.secrets.tandoorSecretKey.path;
in
{
  # create a podman network so the tandoor app can reach it's database
  systemd.services.create-tandoor-network = with config.virtualisation.oci-containers; {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "podman-tandoor-app.service" "podman-tandoor-webserver.service" "podman-tandoor-db.service" ];
    script = ''
      ${pkgs.podman}/bin/podman network exists ${podmanNetworkName} || \
      ${pkgs.podman}/bin/podman network create ${podmanNetworkName}
    '';
  };

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    tandoor-app = {
      image = "docker.io/vabene1111/recipes";
      autoStart = true;
      hostname = "web_recipes";
      volumes = [
        "tandoor-staticfiles:/opt/recipes/staticfiles"
        "tandoor-nginx_config:/opt/recipes/nginx/conf.d"
        "${volumeBasePath}/mediafiles:/opt/recipes/mediafiles"
        "${secretKeyFile}:/opt/recipes/secret.key"
        "${postgresPasswordFile}:/opt/recipes/postgres.passwd"
      ];
      environment = {
        "DEBUG" = "0";
        "SQL_DEBUG" = "0";
        "DEBUG_TOOLBAR" = "0";
        "GUNICORN_MEDIA" = "0";
        "SECRET_KEY_FILE" = "/opt/recipes/secret.key";
        "DB_ENGINE" = "django.db.backends.postgresql";
        "POSTGRES_HOST" = "tandoor-db";
        "POSTGRES_PORT" = "5432";
        "POSTGRES_USER" = "${postgresUsername}";
        "POSTGRES_PASSWORD_FILE" = "/opt/recipes/postgres.passwd";
        "POSTGRES_DB" = "${postgresDatabase}";
        "TIMEZONE" = "Europe/Berlin";
        "ENABLE_PDF_EXPORT" = "1";
      };
      extraOptions = [
        "--network=${podmanNetworkName}"
        "--userns=keep-id:uid=${toString config.users.users."ruben".uid},gid=${toString config.users.groups."users".gid}"
      ];
      dependsOn = [ "tandoor-db" ];
    };

    tandoor-webserver = {
      image = "docker.io/library/nginx:mainline-alpine";
      autoStart = true;
      ports = [
        "127.0.0.1:7450:80"
      ];
      volumes = [
        "tandoor-nginx_config:/etc/nginx/conf.d:ro"
        "tandoor-staticfiles:/static:ro"
        "${volumeBasePath}/mediafiles:/media:ro"
      ];
      dependsOn = [ "tandoor-app" ];
      extraOptions = [ "--network=${podmanNetworkName}" ];
    };

    tandoor-db = {
      image = "docker.io/library/postgres:15-alpine";
      hostname = "tandoor-db";
      autoStart = true;
      # I don't think that's needed
      #user = "${toString config.users.users."ruben".uid}:${toString config.users.users."ruben".group}";
      volumes = [
        "${volumeBasePath}/postgresql:/var/lib/postgresql/data"
        "${postgresPasswordFile}:/var/lib/postgresql/postgres.passwd:ro"
      ];
      environment = {
        "POSTGRES_DB" = "${postgresDatabase}";
        "POSTGRES_USER" = "${postgresUsername}";
        "POSTGRES_PASSWORD_FILE" = "/var/lib/postgresql/postgres.passwd";
      };
      extraOptions = [
        "--network=${podmanNetworkName}"
        "--userns=keep-id:uid=${toString config.users.users."ruben".uid},gid=${toString config.users.groups."users".gid}"
      ];
    };
  };
}
