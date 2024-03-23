{ config, pkgs, lib, ... }:
{
  users.users.hedgedoc = {
    name = "hedgedoc";
    group = "hedgedoc";
    description = "HedgeDoc service user";
    isSystemUser = true;
    extraGroups = [ "backup" ];
  };
  users.groups.hedgedoc = { };

  services.hedgedoc = {
    enable = true;
    settings = {
      host = "0.0.0.0";
      port = 3000;
      protocolUseSSL = true;
      domain = "pad.home.hoenle.xyz";
      db = {
        dialect = "sqlite";
        storage = "/var/lib/hedgedoc/db.sqlite";
      };

      uploadPath = "/var/lib/hedgedoc/uploads";
      allowOrigin = [ "localhost" "127.0.0.1" "pad.home.hoenle.xyz" ];
    };
  };

  /* create db dump directory */
  systemd.tmpfiles.settings."hedgedoc-db-dumps" = {
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
    backupPrepareCommand = "${pkgs.sqlite}/bin/sqlite3 /var/lib/hedgedoc/db.sqlite \".backup '/var/lib/hedgedoc/db-dumps/db-dump.sqlite3'\"";
  };

  /* hedgedoc restore backup service (restores the latest restic backup and imports the latest dump into the hedgedoc database) */
  systemd.user.services = {
    hedgedoc-backup-restore = {
      serviceConfig = {
        Type = "oneshot";
        User = "hedgedoc";
        Group = "hedgedoc";
        ExecStart = "restic-hedgedoc restore --target / latest && mv /var/lib/hedgedoc/db-dumps/db-dump.sqlite3 /var/lib/hedgedoc/db.sqlite";
      };
    };
  };
}
