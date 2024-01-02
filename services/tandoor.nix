{ config, pkgs, lib, ... }:
with lib;
let
  volumeBasePath = "/home/ruben/services/podman/tandoor";
  podmanNetworkName = "tandoor-net";
  postgresUsername = "";
  postgresPasswordFile = "";
in
{
  # https://madison-technologies.com/take-your-nixos-container-config-and-shove-it/
  systemd.services.create-tandoor-network = with config.virtualisation.oci-containers; {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "podman-tandoor-app.service" "podman-tandoor-db.service" ];
    script = ''
      ${pkgs.podman}/bin/podman network exists tandoor-net || \
      ${pkgs.podman}/bin/podman network create tandoor-net
    '';
  };

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    tandoor-app = {
      image = "docker.io/vabene1111/recipes";
      autoStart = true;
      volumes = [
        #"staticfiles:/opt/recipes/staticfiles"
        ## Do not make this a bind mount, see https://docs.tandoor.dev/install/docker/#volumes-vs-bind-mounts
        #"nginx_config:/opt/recipes/nginx/conf.d"
        #"/home/ruben/services/podman/tandoor/mediafiles:/opt/recipes/mediafiles"
      ];
      ports = [
        #"127.0.0.1:
        "7450:8080"
      ];
      environment = {
        "DEBUG" = "0";
        "GUNICORN_MEDIA" = "1";
        "SECRET_KEY" = "JUST_A_TEST_CHANGE_THIS";
        #"SECRET_KEY_FILE" = "/do/not/forget-to/mount-this";
        "DB_ENGINE" = "django.db.backends.postgresql";
        "POSTGRES_HOST" = "tandoor-db";
        "POSTGRES_PORT" = "5432";
        "POSTGRES_USER" = "djangouser";
        "POSTGRES_PASSWORD" = "TODO-CHANGE-THIS-temporary";
        "POSTGRES_DB" = "djangodb";
        "TIMEZONE" = "Europe/Berlin";
        "ENABLE_PDF_EXPORT" = "1";
      };
      extraOptions = [ "--network=tandoor-net" ];
      dependsOn = [ "tandoor-db" ];
    };

    #tandoor-webserver = {
    #  image = "docker.io/vabene/recipes";
    #  autoStart = true;
    #  ports = [ "127.0.0.1:8080:80" ];
    #  extraOptions = [ "--network=tandoor-net" ];
    #};

    tandoor-db = {
      image = "docker.io/library/postgres:15-alpine";
      hostname = "tandoor-db";
      autoStart = true;
      volumes = [
        #"/home/ruben/services/podman/tandoor/postgresql:/var/lib/postgresql/data"
      ];
      environment = {
        "POSTGRES_DB" = "djangodb";
        "POSTGRES_PASSWORD" = "TODO-CHANGE-THIS-temporary";
        # POSTGRES_PASSWORD_FILE = "/dont/forget/to/mount/this";
        "POSTGRES_USER" = "djangouser";
      };
      extraOptions = [ "--network=tandoor-net" ];
    };
  };
}
