{ config, pkgs, lib, ... }:
with lib;
let
  volumeBasePath = "/home/ruben/services/podman/gickup";

  # required github token permissions see https://github.com/cooperspencer/gickup/issues/16
  githubTokenFile = config.age.secrets.gickupGithubToken.path;

  # generate a gickup-config yaml file
  # as yaml is just a superset of json, we can just use json for this 
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

    cron = "0 1 * * *";
    # optional - when cron is not provided, the program runs once and exits.
    # Otherwise, it runs according to the cron schedule.
    # For more information on crontab or testing: https://crontab.guru/
  });
in
{
  virtualisation.oci-containers.containers = {
    gickup = {
      image = "docker.io/buddyspencer/gickup:latest";
      autoStart = true;
      volumes = [
        "${configFile}:/gickup/conf.yml"
        "${githubTokenFile}:/gickup/github-token.secret"
        "${volumeBasePath}/backups:/gickup/backups"
      ];
      environment = {
        TZ = "Europe/Berlin";
      };
      cmd = [ "/gickup/conf.yml" ];
      extraOptions = [ "--userns=keep-id:uid=${toString config.users.users."ruben".uid},gid=${toString config.users.groups."users".gid}" ];
    };
  };
}
