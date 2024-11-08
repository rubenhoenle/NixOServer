{ config, lib, pkgs, ... }: {
  options.ruben.gitserver = {
    enable = lib.mkEnableOption "git server";
    path = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/git-server";
    };
  };

  config = lib.mkIf (config.ruben.gitserver.enable)
    {
      users.users.git = {
        isSystemUser = true;
        group = "git";
        home = config.ruben.gitserver.path;
        createHome = true;
        shell = "${pkgs.git}/bin/git-shell";
        extraGroups = [ "backup" ];
        openssh.authorizedKeys.keys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGz2voOKRU2i2BECmdXRw+1okyV+Kwm6PSN0ghaD8zuqAAAABHNzaDo="
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsnp3qCYwCpb49UptuZ8csHzIZzZr0Buyl7uVW9udFdAAAABHNzaDo="
        ];
        uid = 976;
      };
      users.groups.git.gid = 974;

      services.openssh = {
        enable = true;
        extraConfig = ''
          Match user git
            AllowTcpForwarding no
            AllowAgentForwarding no
            PasswordAuthentication no
            PermitTTY no
            X11Forwarding no
        '';
      };

      /* backup service */
      services.restic.backups.gitserver = {
        user = "git";
        initialize = true;
        passwordFile = config.age.secrets.resticPassword.path;
        repository = "s3:https://s3.eu-central-003.backblazeb2.com/nixos-server-restic-backup/services/gitserver";
        environmentFile = config.age.secrets.backblazeB2ResticS3EnvironmentSecrets.path;
        paths = [
          "/var/lib/git-server"
        ];
        backupPrepareCommand = "${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 https://hc-ping.com/$(${pkgs.coreutils}/bin/cat ${config.age.secrets.healthchecksIoUuid.path})/backup-gitserver/start";
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

      systemd.services."restic-backups-gitserver" = {
        onSuccess = [ "restic-notify-gitserver@success.service" ];
        onFailure = [ "restic-notify-gitserver@failure.service" ];
      };

      systemd.services."restic-notify-gitserver@" =
        let
          script = pkgs.writeText "restic-notify-gitserver.sh"
            ''
              ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 https://hc-ping.com/$(cat ${config.age.secrets.healthchecksIoUuid.path})/backup-gitserver/''${MONITOR_EXIT_STATUS}
            '';
        in
        {
          serviceConfig = {
            Type = "oneshot";
            User = "git";
            ExecStart = "${pkgs.bash}/bin/bash ${script}";
          };
        };
    };
}

