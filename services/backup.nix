{ pkgs, lib, config, ... }:
let
  hostname = config.networking.hostName;

  backupPrepareScript = pkgs.writeText "backup-prepare-script.sh" (pkgs.lib.strings.concatLines (
    [
      "${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 https://hc-ping.com/$(${pkgs.coreutils}/bin/cat ${config.age.secrets.healthchecksIoUuid.path})/${hostname}-backup/start"
    ] ++ pkgs.lib.ifEnable config.ruben.paperless.enable [
      config.ruben.paperless.backupPrepareCommandDatabase
      config.ruben.paperless.backupPrepareCommandExport
    ]
  ));
in
{
  options.ruben.fullbackup.enable = lib.mkEnableOption "full backup";

  config = lib.mkIf (config.ruben.fullbackup.enable)
    {
      /* backup service */
      services.restic.backups.fullbackup = {
        user = "root";
        initialize = true;
        passwordFile = config.age.secrets.resticPassword.path;
        repository = "s3:https://s3.eu-central-003.backblazeb2.com/nixos-server-restic-backup/system-backup/${hostname}";
        environmentFile = config.age.secrets.backblazeB2ResticS3EnvironmentSecrets.path;
        paths = [ "/home/ruben" ]
          ++ pkgs.lib.ifEnable config.ruben.gitserver.enable [ config.ruben.gitserver.path ]
          ++ pkgs.lib.ifEnable config.ruben.fileserver.enable [ config.ruben.fileserver.path ]
          ++ pkgs.lib.ifEnable config.ruben.phone-backup.enable [ config.ruben.phone-backup.path ]
          ++ pkgs.lib.ifEnable config.ruben.paperless.enable [ config.ruben.paperless.path config.ruben.paperless.backup-path ];
        backupPrepareCommand = "${pkgs.bash}/bin/bash ${backupPrepareScript}";
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

      systemd.services."restic-backups-fullbackup" = {
        onSuccess = [ "restic-notify-fullbackup@success.service" ];
        onFailure = [ "restic-notify-fullbackup@failure.service" ];
      };

      systemd.services."restic-notify-fullbackup@" =
        let
          script = pkgs.writeText "restic-notify-fullbackup.sh"
            ''
              ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 https://hc-ping.com/$(cat ${config.age.secrets.healthchecksIoUuid.path})/${hostname}-backup/''${MONITOR_EXIT_STATUS}
            '';
        in
        {
          serviceConfig = {
            Type = "oneshot";
            User = "root";
            ExecStart = "${pkgs.bash}/bin/bash ${script}";
          };
        };
    };
}
