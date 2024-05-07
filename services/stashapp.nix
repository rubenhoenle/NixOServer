{ config, lib, ... }:
with lib;
let
  cfg = config.ruben.stashapp;
  path = "/var/lib/stashapp";
in
{
  options.ruben.stashapp = {
    enable = mkEnableOption "stashapp service";
  };

  config = mkIf (cfg.enable)
    {
      /* stashapp service user */
      users.users.stashapp = {
        name = "stashapp";
        group = "stashapp";
        description = "Stashapp service user";
        isSystemUser = true;
        uid = 983;
      };
      users.groups.stashapp = {
        gid = 981;
      };

      /* create volume directory */
      systemd.tmpfiles.settings."stashapp-volumes" = {
        "${path}".d = {
          mode = "0770";
          user = "stashapp";
          group = "stashapp";
        };
        "${path}/root".d = {
          mode = "0770";
          user = "stashapp";
          group = "stashapp";
        };
        "${path}/root/.config".d = {
          mode = "0770";
          user = "stashapp";
          group = "stashapp";
        };
        "${path}/data".d = {
          mode = "0770";
          user = "stashapp";
          group = "stashapp";
        };
        "${path}/metadata".d = {
          mode = "0770";
          user = "stashapp";
          group = "stashapp";
        };
        "${path}/cache".d = {
          mode = "0770";
          user = "stashapp";
          group = "stashapp";
        };
        "${path}/generated".d = {
          mode = "0770";
          user = "stashapp";
          group = "stashapp";
        };
        "${path}/blobs".d = {
          mode = "0770";
          user = "stashapp";
          group = "stashapp";
        };
      };

      /* stashapp service */
      virtualisation.oci-containers.containers = {
        stashapp = {
          image = "stashapp/stash:v0.25.1";
          autoStart = true;
          volumes = [
            "/etc/localtime:/etc/localtime:ro"
            "/var/lib/stashapp/root:/root"
            "/var/lib/stashapp/root/.config:/root/.stash"
            "/var/lib/stashapp/data:/data"
            "/var/lib/stashapp/metadata:/metadata"
            "/var/lib/stashapp/cache:/cache"
            "/var/lib/stashapp/generated:/generated"
            "/var/lib/stashapp/blobs:/blobs"
          ];
          environment = {
            STASH_STASH = "/data/";
            STASH_GENERATED = "/generated/";
            STASH_METADATA = "/metadata/";
            STASH_CACHE = "/cache/";
            STASH_PORT = "9999";
          };
          ports = [ "9999:9999" ];
          extraOptions = [ "--userns=keep-id:uid=${toString config.users.users."stashapp".uid},gid=${toString config.users.groups."stashapp".gid}" ];
        };
      };
    };
}
