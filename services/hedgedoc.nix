{ config, pkgs, lib, ... }:
with lib;
let
  volumeBasePath = "/home/ruben/services/podman/hedgedoc";
  podmanNetworkName = "hedgedoc-net";
  #postgresPasswordFile = config.age.secrets.tandoorPostgresPassword.path;
  #secretKeyFile = config.age.secrets.tandoorSecretKey.path;
in
{
  # create a podman network so the hedgedoc app can reach it's database
  systemd.services.create-hedgedoc-network = with config.virtualisation.oci-containers; {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "podman-hedgedoc-app.service" "podman-hedgedoc-db.service" ];
    script = ''
      ${pkgs.podman}/bin/podman network exists ${podmanNetworkName} || \
      ${pkgs.podman}/bin/podman network create ${podmanNetworkName}
    '';
  };

  virtualisation.oci-containers.containers = {
    hedgedoc-app = {
      image = "quay.io/hedgedoc/hedgedoc:1.9.9";
      autoStart = true;
      ports = [
        #"127.0.0.1:
        "3000:3000"
      ];
      volumes = [
        "${volumeBasePath}/uploads:/hedgedoc/public/uploads"
      ];
      environment = {
        "CMD_DB_URL" = "postgres://hedgedoc:password@hedgedoc-db:5432/hedgedoc";
        "CMD_DOMAIN" = "pad.local";
        #"CMD_HOST" = "localhost";
        "CMD_URL_ADDPORT" = "false";
        "CMD_PROTOCOL_USESSL" = "true";
      };
      extraOptions = [
        "--network=${podmanNetworkName}"
        "--userns=keep-id:uid=${toString config.users.users."ruben".uid},gid=${toString config.users.groups."users".gid}"
      ];
      dependsOn = [ "hedgedoc-db" ];
    };

    hedgedoc-db = {
      image = "docker.io/library/postgres:13.4-alpine";
      hostname = "hedgedoc-db";
      autoStart = true;
      volumes = [
        "${volumeBasePath}/postgresql:/var/lib/postgresql/data"
        #"${postgresPasswordFile}:/var/lib/postgresql/postgres.passwd:ro"
      ];
      environment = {
        #"POSTGRES_DB" = "${postgresDatabase}";
        #"POSTGRES_USER" = "${postgresUsername}";
        #"POSTGRES_PASSWORD_FILE" = "/var/lib/postgresql/postgres.passwd";

        "POSTGRES_USER" = "hedgedoc";
        "POSTGRES_PASSWORD" = "password";
        "POSTGRES_DB" = "hedgedoc";
      };
      extraOptions = [
        "--network=${podmanNetworkName}"
        "--userns=keep-id:uid=${toString config.users.users."ruben".uid},gid=${toString config.users.groups."users".gid}"
      ];
    };
  };
}
