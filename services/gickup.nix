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
        token_file = "/gickup/github-token.secret";
        ssh = false;
        wiki = true;
        starred = true;
      }
    ];

    destination.local = [
      {
        path = "/gickup/backups";
        structured = true;
      }
    ];

    #cron = "0 1 * * *";
    # optional - when cron is not provided, the program runs once and exits.
    # Otherwise, it runs according to the cron schedule.
    # For more information on crontab or testing: https://crontab.guru/
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

      /* gickup service */
      virtualisation.oci-containers.containers = {
        gickup = {
          image = "docker.io/buddyspencer/gickup:latest";
          autoStart = true;
          volumes = [
            "${configFile}:/gickup/conf.yml"
            "${githubTokenFile}:/gickup/github-token.secret"
            "/var/lib/gickup/backups:/gickup/backups"
          ];
          environment = {
            TZ = "Europe/Berlin";
          };
          cmd = [ "/gickup/conf.yml" ];
          extraOptions = [ "--userns=keep-id:uid=${toString config.users.users."gickup".uid},gid=${toString config.users.groups."gickup".gid}" ];
        };
      };
    };
}
