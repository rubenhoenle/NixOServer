{ config, pkgs, ... }:
let
  database-path = "/var/lib/nextcloud/data/nextcloud.db";
  backup-restore-logic-script = pkgs.writeText "restore-nextcloud-backup.sh"
    ''
      if [ -f "${database-path}" ]; then
        echo "[CUSTOM] ${database-path} exists. Using existing database. No backup restore required."
      else
        echo "[CUSTOM] ${database-path} does not exist. Restoring backup..."
        /run/current-system/sw/bin/restic-nextcloud restore --target / latest
        mv /var/lib/nextcloud/db-dumps/db-dump.sqlite3 ${database-path}
      fi
    '';
in
{

  /* nextcloud service user */
  users.users.nextcloud = {
    name = "nextcloud";
    group = "nextcloud";
    description = "Nextcloud service user";
    isSystemUser = true;
    extraGroups = [ "backup" ];
  };
  users.groups.nextcloud = { };

  /* nextcloud service */
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "cloud.home.hoenle.xyz";
    home = "/var/lib/nextcloud";
    config = {
      adminuser = "ruben";
      adminpassFile = config.age.secrets.initialNextcloudPassword.path;
    };

    autoUpdateApps.enable = true;
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks deck;
    };
    extraAppsEnable = true;
  };

  /* create db dump directory */
  systemd.tmpfiles.settings."nextcloud-db-dumps" = {
    "/var/lib/nextcloud".d = {
      mode = "0770";
      user = "nextcloud";
      group = "nextcloud";
    };
    "/var/lib/nextcloud/db-dumps".d = {
      mode = "0770";
      user = "nextcloud";
      group = "nextcloud";
    };
  };

  /* nextcloud backup service */
  services.restic.backups.nextcloud = {
    user = "nextcloud";
    initialize = true;
    passwordFile = config.age.secrets.resticPassword.path;
    repository = "s3:https://s3.eu-central-003.backblazeb2.com/nixos-server-restic-backup/services/nextcloud";
    environmentFile = config.age.secrets.backblazeB2ResticS3EnvironmentSecrets.path;
    paths = [
      "/var/lib/nextcloud"
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
    backupPrepareCommand = "${pkgs.sqlite}/bin/sqlite3 ${database-path} \".backup '/var/lib/nextcloud/db-dumps/db-dump.sqlite3'\"";
  };

  /* nextcloud backup restore service : if no nextcloud database is present (e.g. on new machine), restore the latest restic backup */
  systemd.services.nextcloud-backup-auto-restore = {
    wantedBy = [ "multi-user.target" ];
    before = [ "nextcloud-setup.service" ];
    requiredBy = [ "nextcloud-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "nextcloud";
      Group = "nextcloud";
      ExecStart = "${pkgs.bash}/bin/bash ${backup-restore-logic-script}";
    };
  };
}
