{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.ruben.hedgedoc;

  database-path = "/var/lib/hedgedoc/db.sqlite";
  backup-restore-logic-script = pkgs.writeText "restore-hedgedoc-backup.sh"
    ''
      if [ -f "${database-path}" ]; then
        echo "[CUSTOM] ${database-path} exists. Using existing database. No backup restore required."
      else
        echo "[CUSTOM] ${database-path} does not exist. Restoring backup..."
        /run/current-system/sw/bin/restic-hedgedoc restore --target / latest
        mv /var/lib/hedgedoc/db-dumps/db-dump.sqlite3 ${database-path}
      fi
    '';
in
{
  options.ruben.hedgedoc = {
    enable = mkEnableOption "hedgedoc service";
  };

  config = mkIf (cfg.enable)
    {
      /* hedgedoc service user */
      users.users.hedgedoc = {
        name = "hedgedoc";
        group = "hedgedoc";
        description = "HedgeDoc service user";
        isSystemUser = true;
        extraGroups = [ "backup" ];
      };
      users.groups.hedgedoc = { };

      /* hedgedoc service */
      services.hedgedoc = {
        enable = true;
        settings = {
          host = "0.0.0.0";
          port = 3000;
          protocolUseSSL = true;
          domain = "pad.home.hoenle.xyz";
          db = {
            dialect = "sqlite";
            storage = "${database-path}";
          };
          uploadPath = "/var/lib/hedgedoc/uploads";
          allowOrigin = [ "localhost" "127.0.0.1" "pad.home.hoenle.xyz" ];
        };
      };

      /* create db dump directory */
      systemd.tmpfiles.settings."hedgedoc-db-dumps" = {
        "/var/lib/hedgedoc".d = {
          mode = "0770";
          user = "hedgedoc";
          group = "hedgedoc";
        };
        "/var/lib/hedgedoc/db-dumps".d = {
          mode = "0770";
          user = "hedgedoc";
          group = "hedgedoc";
        };
      };

      /* hedgedoc backup service */
      services.restic.backups.hedgedoc = {
        user = "hedgedoc";
        initialize = true;
        passwordFile = config.age.secrets.resticPassword.path;
        repository = "s3:https://s3.eu-central-003.backblazeb2.com/nixos-server-restic-backup/services/hedgedoc";
        environmentFile = config.age.secrets.backblazeB2ResticS3EnvironmentSecrets.path;
        paths = [
          "/var/lib/hedgedoc/uploads"
          "/var/lib/hedgedoc/db-dumps"
        ];
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 12"
          "--keep-yearly 3"
        ];
        extraOptions = [ "s3.region=eu-central-003" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
        # get a db dump before running the restic backup job
        backupPrepareCommand = "${pkgs.sqlite}/bin/sqlite3 ${database-path} \".backup '/var/lib/hedgedoc/db-dumps/db-dump.sqlite3'\"";
      };

      /* hedgedoc backup restore service : if no hedgedoc database is present (e.g. on new machine), restore the latest restic backup */
      systemd.services.hedgedoc-backup-auto-restore = {
        wantedBy = [ "multi-user.target" ];
        before = [ "hedgedoc.service" ];
        requiredBy = [ "hedgedoc.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = "hedgedoc";
          Group = "hedgedoc";
          ExecStart = "${pkgs.bash}/bin/bash ${backup-restore-logic-script}";
        };
      };
    };
}
