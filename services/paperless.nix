{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ruben.paperless;
  paperlessDir = "/var/lib/paperless";
  passwordFile = config.age.secrets.paperlessPassword.path;
  database-path = "/var/lib/paperless/data/db.sqlite3";
  backup-restore-logic-script = pkgs.writeText "restore-paperless-backup.sh"
    ''
      if [ -f "${database-path}" ]; then
        echo "[CUSTOM] ${database-path} exists. Using existing database. No backup restore required."
      else
        echo "[CUSTOM] ${database-path} does not exist. Restoring backup..."
        /run/current-system/sw/bin/restic-paperless restore --target / latest
        mv /var/lib/paperless/db-dumps/db-dump.sqlite3 ${database-path}
      fi
    '';
in
{
  options.ruben.paperless = {
    enable = mkEnableOption "paperless service";
  };

  config = mkIf (cfg.enable)
    {
      /* paperless service user */
      users.users.paperless = {
        name = "paperless";
        group = "paperless";
        description = "Paperless service user";
        isSystemUser = true;
        extraGroups = [ "backup" ];
      };
      users.groups.paperless = { };

      /* create db dump directory */
      systemd.tmpfiles.settings."paperless-db-dumps" = {
        "/var/lib/paperless".d = {
          mode = "0770";
          user = "paperless";
          group = "paperless";
        };
        "/var/lib/paperless/db-dumps".d = {
          mode = "0770";
          user = "paperless";
          group = "paperless";
        };
      };

      /* paperless service */
      services.paperless = {
        enable = true;
        address = "127.0.0.1";
        port = 8085;
        passwordFile = passwordFile;
        user = "paperless";
        dataDir = "${paperlessDir}/data";
        mediaDir = "${paperlessDir}/media";
        consumptionDir = "${paperlessDir}/input";
        settings = {
          PAPERLESS_OCR_LANGUAGE = "deu+eng";
          PAPERLESS_ADMIN_USER = "ruben";
          PAPERLESS_TASK_WORKERS = 2;
          PAPERLESS_THREADS_PER_WORKER = 2;
          PAPERLESS_WORKER_TIMEOUT = 3600;
        };
      };

      /* paperless backup service */
      services.restic.backups.paperless = {
        user = "paperless";
        initialize = true;
        passwordFile = config.age.secrets.resticPassword.path;
        repository = "s3:https://s3.eu-central-003.backblazeb2.com/nixos-server-restic-backup/services/paperless";
        environmentFile = config.age.secrets.backblazeB2ResticS3EnvironmentSecrets.path;
        paths = [
          "/var/lib/paperless"
          "/var/lib/paperless/db-dumps"
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
        backupPrepareCommand = "${pkgs.sqlite}/bin/sqlite3 ${database-path} \".backup '/var/lib/paperless/db-dumps/db-dump.sqlite3'\"";
      };

      /* paperless backup restore service: if no paperless database is present (e.g. on new machine), restore the latest restic backup */
      systemd.services.paperless-backup-auto-restore = {
        wantedBy = [ "multi-user.target" ];
        before = [
          "paperless-consumer.service"
          "paperless-scheduler.service"
          "paperless-task-queue.service"
          "paperless-web.service"
          "redis-paperless.service"
        ];
        requiredBy = [
          "paperless-consumer.service"
          "paperless-scheduler.service"
          "paperless-task-queue.service"
          "paperless-web.service"
          "redis-paperless.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          User = "paperless";
          Group = "paperless";
          ExecStart = "${pkgs.bash}/bin/bash ${backup-restore-logic-script}";
        };
      };
    };
}

