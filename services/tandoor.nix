{ config, pkgs, lib, ... }:
{
  services.tandoor-recipes = {
    enable = true;
    port = 7450;
    address = "127.0.0.1";
  };

  users.users.tandoor_recipes = {
    name = "tandoor_recipes";
    group = "tandoor_recipes";
    description = "Tandoor recipes service user";
    isSystemUser = true;
    extraGroups = [ "backup" ];
  };
  users.groups.tandoor_recipes = { };

  systemd.user.services = {
    tandoor_recipes_database_backup = {
      serviceConfig = {
        Type = "oneshot";
        User = "tandoor_recipes";
        Group = "tandoor_recipes";
        #ExecStart = "${pkgs.sqlite}/bin/sqlite3 /var/lib/tandoor-recipes/db.sqlite3 \".backup '/home/ruben/backups/tandoor/database/db-dump.sqlite3'\"";
        #ExecStart = "${pkgs.sqlite}/bin/sqlite3 /var/lib/tandoor-recipes/db.sqlite3 \".backup '/var/lib/private/tandoor-recipes/db-dumps/db-dump.sqlite3'\"";
        ExecStart = "${pkgs.sqlite}/bin/sqlite3 /var/lib/private/tandoor-recipes/db.sqlite3 \".backup '/var/lib/tandoor-recipes-db-dumps/db-dump.sqlite3'\"";
        #-$(date '+%d%m%Y-%H%M')
        #ExecStartPost = "chown ";
      };
    };
  };

  #systemd.services.tandoor-recipes.serviceConfig.DynamicUser = lib.mkForce false;

  # create db dump directory
  systemd.tmpfiles.settings."tandoor-db-dumps" = {
    "/var/lib/tandoor-recipes-db-dumps".d = {
      mode = "0777";
      user = "tandoor_recipes";
      group = "tandoor_recipes";
    };
  };

  /* tandoor recipes backup service */
  services.restic.backups.tandoor_recipes = {
    user = "tandoor_recipes";
    initialize = true;
    passwordFile = config.age.secrets.resticPassword.path;
    repository = "s3:https://s3.eu-central-003.backblazeb2.com/nixos-server-restic-backup/services/tandoor_recipes";
    environmentFile = config.age.secrets.backblazeB2ResticS3EnvironmentSecrets.path;
    paths = [
      "/var/lib/private/tandoor-recipes/recipes" # recipe pictures
      "/var/lib/private/tandoor-recipes/db-dumps"

      "/var/lib/tandoor-recipes-db-dumps"
    ];

    # restic can't handle symlinks so we have to follow them to get the correct backup paths
    # TODO / edit: seems like we always need sudo to follow symlinks
    #dynamicFilesFrom = "${pkgs.coreutils}/bin/readlink -f /var/lib/tandoor-recipes/recipes /var/lib/tandoor-recipes/db-dumps";
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      "--keep-yearly 3"
    ];
    extraOptions = [
      "s3.region=eu-central-003"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    #backupPrepareCommand = "mkdir /var/lib/private/tandoor-recipes/db-dumps && ${pkgs.sqlite}/bin/sqlite3 /var/lib/tandoor-recipes/db.sqlite3 \".backup '/var/lib/private/tandoor-recipes/db-dumps/db-dump.sqlite3'\"";
    #backupPrepareCommand = "${pkgs.coreutils}/bin/touch /var/lib/tandoor-recipes-db-dumps/db-dump.sqlite3";
    backupPrepareCommand = "${pkgs.sqlite}/bin/sqlite3 /var/lib/private/tandoor-recipes/db.sqlite3 \".backup '/var/lib/tandoor-recipes-db-dumps/db-dump.sqlite3'\"";
  };

}
