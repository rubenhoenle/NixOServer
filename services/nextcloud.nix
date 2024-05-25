{ config, pkgs, lib, ... }:
let
  config-path = "/var/lib/nextcloud/config/config.php";
  backup-restore-logic-script = pkgs.writeText "restore-nextcloud-backup.sh"
    ''
      if [ -f "${config-path}" ]; then
        echo "[CUSTOM] ${config-path} exists. Using existing nextcloud structure. No backup restore required."
      else
        echo "[CUSTOM] ${config-path} does not exist. Restoring backup..."
        /run/current-system/sw/bin/restic-nextcloud restore --target / latest
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
    configureRedis = true;
    maxUploadSize = "64G";
    phpOptions."max_file_uploads" = "9999";

    config = {
      dbtype = "pgsql";
      dbname = "nextcloud";
      dbtableprefix = "oc_";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";

      adminuser = "ruben";
      adminpassFile = config.age.secrets.initialNextcloudPassword.path;

    };
    extraOptions = {
      "memories.exiftool" = "${lib.getExe pkgs.exiftool}";
      "memories.vod.ffmpeg" = "${pkgs.ffmpeg-headless}/bin/ffmpeg";
      "memories.vod.ffprobe" = "${pkgs.ffmpeg-headless}/bin/ffprobe";
    };

    autoUpdateApps.enable = true;
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks memories deck;
    };
    extraAppsEnable = true;
  };

  /* delay nextcloud startup until the postgres database is available */
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
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
  };

  /* get a postgres db dump incl. restic update before running the nextcloud restic backup job */
  systemd.services."restic-backups-nextcloud" = {
    requires = [ "restic-backups-postgres.service" ];
    after = [ "restic-backups-postgres.service" ];
  };

  /* nextcloud backup restore service : if no nextcloud config.php is present (e.g. on new machine), restore the latest restic backup */
  systemd.services.nextcloud-backup-auto-restore = {
    wantedBy = [ "multi-user.target" ];

    before = [ "nextcloud-setup.service" ];
    requiredBy = [ "nextcloud-setup.service" ];

    # wait for postgresql database (incl. backup restore) to be available
    requires = [ "postgresql.service" "nextcloud-backup-auto-restore.service" ];
    after = [ "postgresql.service" "nextcloud-backup-auto-restore.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "nextcloud";
      Group = "nextcloud";
      ExecStart = "${pkgs.bash}/bin/bash ${backup-restore-logic-script}";
    };
  };
}
