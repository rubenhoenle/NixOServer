{ config, pkgs, lib, ... }:
let
  database-path = "/var/lib/tandoor-recipes/db.sqlite3";
  backup-restore-logic-script = pkgs.writeText "restore-tandoor-backup.sh"
    ''
      if [ -f "${database-path}" ]; then
        echo "[CUSTOM] ${database-path} exists. Using existing database. No backup restore required."
      else
        echo "[CUSTOM] ${database-path} does not exist. Restoring backup..."
        /run/current-system/sw/bin/restic-tandoor restore --target / latest
        mv /var/lib/tandoor-recipes/db-dumps/db-dump.sqlite3 ${database-path}
      fi
    '';
in
{
  /* tandoor service user */
  users.users.tandoor_recipes = {
    name = "tandoor_recipes";
    group = "tandoor_recipes";
    description = "Tandoor recipes service user";
    isSystemUser = true;
    extraGroups = [ "backup" ];
  };
  users.groups.tandoor_recipes = { };

  /* tandoor recipes service */
  services.tandoor-recipes = {
    enable = true;
    port = 7450;
    address = "127.0.0.1";
  };
  systemd.services.tandoor-recipes.serviceConfig.DynamicUser = lib.mkForce false;

  /* create db dump directory */
  systemd.tmpfiles.settings."tandoor-db-dumps" = {
    "/var/lib/tandoor-recipes".d = {
      mode = "0770";
      user = "tandoor_recipes";
      group = "tandoor_recipes";
    };
    "/var/lib/tandoor-recipes/db-dumps".d = {
      mode = "0770";
      user = "tandoor_recipes";
      group = "tandoor_recipes";
    };
  };

  /* tandoor recipes backup service */
  services.restic.backups.tandoor = {
    user = "tandoor_recipes";
    initialize = true;
    passwordFile = config.age.secrets.resticPassword.path;
    repository = "s3:https://s3.eu-central-003.backblazeb2.com/nixos-server-restic-backup/services/tandoor-recipes";
    environmentFile = config.age.secrets.backblazeB2ResticS3EnvironmentSecrets.path;
    paths = [
      "/var/lib/tandoor-recipes/recipes" # recipe pictures
      "/var/lib/tandoor-recipes/db-dumps"
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
    backupPrepareCommand = "${pkgs.sqlite}/bin/sqlite3 ${database-path} \".backup '/var/lib/tandoor-recipes/db-dumps/db-dump.sqlite3'\"";
  };

  /* tandoor recipes backup restore service: if no tandoor-recipes database is present (e.g. on new machine), restore the latest restic backup */
  systemd.services.tandoor-backup-auto-restore = {
    wantedBy = [ "multi-user.target" ];
    before = [ "tandoor-recipes.service" ];
    requiredBy = [ "tandoor-recipes.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "tandoor_recipes";
      Group = "tandoor_recipes";
      ExecStart = "${pkgs.bash}/bin/bash ${backup-restore-logic-script}";
    };
  };

}
