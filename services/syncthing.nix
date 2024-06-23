{ config, lib, ... }:
with lib;
let
  cfg = config.ruben.syncthing;
in
{
  options.ruben.syncthing = {
    enable = mkEnableOption "syncthing service";
  };

  config = mkIf (cfg.enable)
    {
      /* syncthing service user */
      users.users.syncthing = {
        name = "syncthing";
        group = "syncthing";
        description = "Syncthing daemon user";
        isSystemUser = true;
        extraGroups = [ "backup" ];
      };
      users.groups.syncthing = { };

      /* syncthing directory structure */
      systemd.tmpfiles.settings."syncthing-dirs" = {
        "/var/lib/syncthing".d = {
          mode = "0770";
          user = "syncthing";
          group = "syncthing";
        };
        "/var/lib/syncthing/.config".d = {
          mode = "0770";
          user = "syncthing";
          group = "syncthing";
        };
        "/var/lib/syncthing/files".d = {
          mode = "0770";
          user = "syncthing";
          group = "syncthing";
        };
        "/var/lib/syncthing/files/Photos-synced".d = {
          mode = "0770";
          user = "syncthing";
          group = "syncthing";
        };
      };

      /* syncthing service */
      services.syncthing = {
        enable = true;
        user = "syncthing";
        group = "syncthing";

        openDefaultPorts = true;
        guiAddress = "0.0.0.0:8384";

        key = config.age.secrets.syncthingKey.path;
        cert = config.age.secrets.syncthingCert.path;

        dataDir = "/var/lib/syncthing";
        configDir = "/var/lib/syncthing/.config";

        /* overrides any devices and folders added or deleted through the WebUI */
        overrideDevices = true;
        overrideFolders = true;

        settings = {
          gui = {
            user = "ruben";
            password = "6vwScmeRgH6&qnDC";
          };

          /* disable telemetry */
          options.urAccepted = -1;

          /* enable connections outside of network */
          options.relaysEnabled = true;

          devices = {
            "phone-ruben" = { id = "GKPXJKO-MM6RZGS-XL4B4EI-XLNYUMI-SAQ65CT-POKEZDT-ARSM6GG-ZQD4XAP"; };
          };
          folders = {
            "Photos-synced" = {
              path = "/var/lib/syncthing/files/Photos-synced";
              devices = [ "phone-ruben" ];
            };
          };
        };
      };

      /* syncthing backup service */
      services.restic.backups.syncthing = {
        user = "syncthing";
        initialize = true;
        passwordFile = config.age.secrets.resticPassword.path;
        repository = "s3:https://s3.eu-central-003.backblazeb2.com/nixos-server-restic-backup/services/syncthing";
        environmentFile = config.age.secrets.backblazeB2ResticS3EnvironmentSecrets.path;
        paths = [
          "/var/lib/syncthing/files"
        ];
        pruneOpts = [
          "--keep-hourly 48"
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 12"
          "--keep-yearly 5"
        ];
        extraOptions = [ "s3.region=eu-central-003" ];
        timerConfig = {
          OnCalendar = "hourly";
          Persistent = true;
        };
      };
    };
}
