{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.ruben.gickup;

  # required github token permissions see https://github.com/cooperspencer/gickup/issues/16
  githubTokenFile = config.age.secrets.gickupGithubToken.path;

  /* generate a gickup-config yaml file - as yaml is just a superset of json, we can just use json for this */
  configFile = pkgs.writeText "gickup-config.yml" (builtins.toJSON {
    source.github = [
      {
        token_file = "${githubTokenFile}";
        ssh = false;
        wiki = true;
        starred = false;
        exclude = [ "nixpkgs" ];
      }
    ];

    destination.local = [
      {
        path = "/var/lib/gickup/backups";
        structured = true;
      }
    ];
  });
in
{
  options.ruben.gickup = {
    enable = mkEnableOption "gickup service";
  };

  config = mkIf (cfg.enable)
    {
      /* gickup service user */
      users.users.gickup = {
        name = "gickup";
        group = "gickup";
        description = "Gickup service user";
        isSystemUser = true;
        uid = 986;
      };
      users.groups.gickup = {
        gid = 984;
      };

      /* create volume directory */
      systemd.tmpfiles.settings."gickup-volumes" = {
        "/var/lib/gickup".d = {
          mode = "0770";
          user = "gickup";
          group = "gickup";
        };
        "/var/lib/gickup/backups".d = {
          mode = "0770";
          user = "gickup";
          group = "gickup";
        };
      };

      systemd = {
        /* gickup service */
        services.gickup = {
          description = "git backups with gickup";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.gickup}/bin/gickup ${configFile}";
            User = "gickup";
            Group = "gickup";
          };
        };
        /* gickup timer */
        timers.gickup = {
          description = "Periodic git backups with gickup";
          timerConfig = {
            Unit = "gickup.service";
            OnCalendar = "daily";
          };
        };
      };
    };
}
