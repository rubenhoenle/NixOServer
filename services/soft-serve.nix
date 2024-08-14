{ pkgs, lib, config, ... }:
with lib;
let
  sshPort = 23231;
  database-path = "/var/lib/soft-serve/soft-serve.db";
  backup-restore-logic-script = pkgs.writeText "restore-tandoor-backup.sh"
    ''
      if [ -f "${database-path}" ]; then
        echo "[CUSTOM] ${database-path} exists. Using existing database. No backup restore required."
      else
        echo "[CUSTOM] ${database-path} does not exist. Restoring backup..."
        /run/current-system/sw/bin/restic-soft-serve restore --target / latest
      fi
    '';
  configFile = pkgs.writeText "soft-serve-config.yml" (builtins.toJSON {
    name = "Rubens repos";
    log_format = "text";
    ssh = {
      listen_addr = ":${toString sshPort}";
      public_url = "ssh://git.home.hoenle.xyz:${toString sshPort}";
      max_timeout = 30;
      idle_timeout = 120;
    };
    initial_admin_keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGz2voOKRU2i2BECmdXRw+1okyV+Kwm6PSN0ghaD8zuqAAAABHNzaDo= ruben"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsnp3qCYwCpb49UptuZ8csHzIZzZr0Buyl7uVW9udFdAAAABHNzaDo= ruben"
    ];
    jobs.mirror_pull = "@every 10m";
  });
in
{
  options.ruben.soft-serve = {
    enable = mkEnableOption "soft-serve git service";
    restoreBackup = mkEnableOption "automatic backup restore for soft-serve git service";
  };

  config = mkIf (config.ruben.soft-serve.enable)
    {
      /* soft-serve service user */
      users.users.soft-serve = {
        name = "soft-serve";
        group = "soft-serve";
        description = "Soft serve backup service user";
        isSystemUser = true;
        uid = 978;
        extraGroups = [ "backup" ];
      };
      users.groups.soft-serve = {
        gid = 976;
      };

      /* create soft-serve directory */
      systemd.tmpfiles.settings."soft-serve" = {
        "/var/lib/soft-serve".d = {
          mode = "0770";
          user = "soft-serve";
          group = "soft-serve";
        };
      };
      systemd.tmpfiles.rules = [
        "L+ /var/lib/soft-serve/config.yaml - - - - ${configFile}"
      ];

      systemd.services.soft-serve = {
        description = "Soft-serve - simple git server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        stopIfChanged = false;
        startLimitIntervalSec = 60;
        environment = {
          SOFT_SERVE_DATA_PATH = "/var/lib/soft-serve";
        };
        serviceConfig = {
          ExecStart = "${pkgs.soft-serve}/bin/soft serve";
          Restart = "always";
          RestartSec = "10s";
          User = "soft-serve";
          Group = "soft-serve";
        };
      };

      networking.firewall.allowedTCPPorts = [ sshPort ];

      services.restic.backups.soft-serve = {
        user = "soft-serve";
        initialize = true;
        passwordFile = config.age.secrets.resticPassword.path;
        repository = "s3:https://s3.eu-central-003.backblazeb2.com/nixos-server-restic-backup/services/soft-serve";
        environmentFile = config.age.secrets.backblazeB2ResticS3EnvironmentSecrets.path;
        paths = [ "/var/lib/soft-serve" ];
        pruneOpts = [
          "--keep-hourly 48"
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 12"
          "--keep-yearly 3"
        ];
        extraOptions = [ "s3.region=eu-central-003" ];
        timerConfig = {
          OnCalendar = "hourly";
          Persistent = true;
        };
      };

      /* soft-serve backup restore service: if no soft-serve database is present (e.g. on new machine), restore the latest restic backup */
      systemd.services.soft-serve-backup-auto-restore = {
        enable = config.ruben.soft-serve.restoreBackup;
        wantedBy = [ "multi-user.target" ];
        before = [ "soft-serve.service" ];
        requiredBy = [ "soft-serve.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = "soft-serve";
          Group = "soft-serve";
          ExecStart = "${pkgs.bash}/bin/bash ${backup-restore-logic-script}";
        };
      };
    };
}
