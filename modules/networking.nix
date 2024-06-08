{ config, lib, ... }:
with lib;
let
  cfg = config.ruben.network;
in
{
  options.ruben.network = {
    hostname = mkOption {
      type = types.str;
    };
  };

  config = {
    networking = {
      hostName = cfg.hostname;
      nameservers = [ "127.0.0.1" ];
      networkmanager.enable = true;
      firewall = {
        allowedTCPPorts = [
          53
          80
          443 # nginx reverse proxy 
          8080 # for http testing 
          2222 # initrd ssh server 
        ];
        allowedUDPPorts = [ 53 2222 ];

        #interfaces."podman+" = {
        #  allowedUDPPorts = [ 53 ];
        #  allowedTCPPorts = [ 53 ];
        #};
      };
      /*hosts = {
        "192.168.178.1" = [ "fritz.box" ];
        "192.168.178.2" = [ "synology" "synology.fritz.box" ];
        "192.168.178.5" = [
          "mandalore"
          "pad.home.hoenle.xyz"
          "recipes.home.hoenle.xyz"
          "paperless.home.hoenle.xyz"
        ];
        "192.168.178.20" = [ "printer01" "printer01.fritz.box" ];
      };*/
    };
  };
}
