{ config, pkgs, lib, ... }:
let
  postgresqlBackupDumpLocation = "/var/backup/postgresql";
  backup-restore-logic-script = pkgs.writeText "restore-postgres-backup.sh"
    ''
      echo "Waiting for PostgreSQL to be ready..."
      until ${pkgs.postgresql_15}/bin/pg_isready -U $USER -d nextcloud; do
        sleep 1
      done
    
      TABLE_COUNT=$(${pkgs.postgresql_15}/bin/psql -U $USER -d nextcloud -tAc "SELECT COUNT(*) FROM pg_catalog.pg_tables WHERE schemaname = 'public' AND tablename LIKE 'oc_%';")

      if [ "$TABLE_COUNT" -gt 0 ]; then
        echo "There are $TABLE_COUNT tables with the prefix 'oc_' in the 'nextcloud' database."
        echo "No need to restore a database dump..."
      else
        echo "No tables with the prefix 'oc_' found in the 'nextcloud' database."
        echo "Unpacking dump...."
        cd ${postgresqlBackupDumpLocation}
        ${pkgs.gzip}/bin/gzip -dkf nextcloud.sql.gz
        echo "Restoring database from dump..."
        ${pkgs.postgresql_15}/bin/psql -U $USER -d nextcloud -a -f nextcloud.sql

        if [ $? -eq 0 ]; then
          echo "Database restored successfully."
        else
          echo "Failed to restore the database."
        fi
      fi
    '';
in
{
  /* postgres service user */
  users.users.postgres = {
    name = "postgres";
    group = "postgres";
    description = "PostgreSQL server user";
    isSystemUser = true;
    extraGroups = [ "backup" ];
  };
  users.groups.postgres = { };

  /* postgresql database service */
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    settings = {
      max_connections = "300";
      shared_buffers = "80MB";
    };
    ensureDatabases = [
      "nextcloud"
    ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
    ];
  };

  /* postgresql backup service */
  services.postgresqlBackup = {
    enable = true;
    databases = [ "nextcloud" ];
    location = "${postgresqlBackupDumpLocation}";
    compressionLevel = 9;
    compression = "gzip";
  };

  /* postgres restic backup service */
  services.restic.backups.postgres = {
    user = "postgres";
    initialize = true;
    passwordFile = config.age.secrets.resticPassword.path;
    repository = "s3:https://s3.eu-central-003.backblazeb2.com/nixos-server-restic-backup/services/postgres";
    environmentFile = config.age.secrets.backblazeB2ResticS3EnvironmentSecrets.path;
    paths = [
      "${postgresqlBackupDumpLocation}"
    ];
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      "--keep-yearly 3"
    ];
    extraOptions = [ "s3.region=eu-central-003" ];
    /* no timer needed, will be triggered by the nextcloud restic backup service */
    timerConfig = null;
  };

  /* get a postgres db dump before running the restic backup job */
  systemd.services."restic-backups-postgres" = {
    requires = [ "postgresqlBackup-nextcloud.service" ];
    after = [ "postgresqlBackup-nextcloud.service" ];
  };

  systemd.services.postgres-backup-auto-restore = {
    wantedBy = [ "multi-user.target" ];
    before = [ "nextcloud-backup-auto-restore.service" ];
    requiredBy = [ "nextcloud-backup-auto-restore.service" ];

    # wait for postgresql database to be available
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      ExecStart = "${pkgs.bash}/bin/bash ${backup-restore-logic-script}";
    };
  };
}
