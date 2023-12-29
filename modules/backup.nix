{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.ruben.backup;
in
{
  options.ruben.backup = {
    enable = mkEnableOption "restic backup";
  };

  config = mkIf (cfg.enable)
    {
      systemd.user.services =
        let
          s3DefaultRegion = "eu-central-003";
          remoteRepo = "s3:https://s3.eu-central-003.backblazeb2.com/nixos-server-restic-backup";
          s3SecretsEnvironmentFile = config.age.secrets.backblazeB2ResticS3EnvironmentSecrets.path;
          resticPasswordFile = config.age.secrets.resticPassword.path;
          backupPaths = "/home/ruben";
          backupExcludes = "--exclude-caches --exclude=\"/home/ruben/cache\" --exclude=\"/home/ruben/.local/\"";
          keep = {
            hourly = "48";
            daily = "7";
            weekly = "4";
            monthly = "12";
            yearly = "3";
          };
        in
        {
          restic_init = {
            serviceConfig = {
              Type = "oneshot";
              EnvironmentFile = "${s3SecretsEnvironmentFile}";
              ExecStart = "${pkgs.restic}/bin/restic init -r ${remoteRepo} -o s3.region=${s3DefaultRegion} --password-file ${resticPasswordFile}";
            };
            path = [
              pkgs.openssh
            ];
          };
          restic_backup = {
            serviceConfig = {
              Type = "oneshot";
              EnvironmentFile = "${s3SecretsEnvironmentFile}";
              ExecStart = "${pkgs.restic}/bin/restic backup -r ${remoteRepo} ${backupExcludes} -o s3.region=${s3DefaultRegion} --password-file ${resticPasswordFile} --one-file-system --tag systemd.timer ${backupPaths}";
              ExecStartPost = "${pkgs.restic}/bin/restic forget -r ${remoteRepo} -o s3.region=${s3DefaultRegion} --password-file ${resticPasswordFile} --tag systemd.timer --group-by \"paths,tags\" --keep-hourly ${keep.hourly} --keep-daily ${keep.daily} --keep-weekly ${keep.weekly} --keep-monthly ${keep.monthly} --keep-yearly ${keep.yearly}";
            };
            path = [
              pkgs.openssh
            ];
          };
          restic_prune = {
            serviceConfig = {
              Type = "oneshot";
              EnvironmentFile = "${s3SecretsEnvironmentFile}";
              ExecStart = "${pkgs.restic}/bin/restic -r ${remoteRepo} -o s3.region=${s3DefaultRegion} --password-file ${resticPasswordFile} prune";
            };
            path = [
              pkgs.openssh
            ];
          };
          restic_unlock = {
            serviceConfig = {
              Type = "oneshot";
              EnvironmentFile = "${s3SecretsEnvironmentFile}";
              ExecStart = "${pkgs.restic}/bin/restic -r ${remoteRepo} -o s3.region=${s3DefaultRegion} --password-file ${resticPasswordFile} unlock";
            };
            unitConfig = {
              OnSuccess = "restic_backup.service";
            };
            path = [
              pkgs.openssh
            ];
          };
        };
      systemd.user.timers = {
        restic_backup = {
          wantedBy = [ "timers.target" ];
          partOf = [ "restic_backup.service" ];
          timerConfig = {
            OnCalendar = "hourly";
            Persistent = true;
          };
        };
        restic_prune = {
          wantedBy = [ "timers.target" ];
          partOf = [ "restic_prune.service" ];
          timerConfig = {
            OnCalendar = "monthly";
            Persistent = true;
          };
        };
      };
    };
}
