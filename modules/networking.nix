{ config, lib, ... }:
{
  options.ruben.network = {
    hostname = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = {
    networking = {
      hostName = config.ruben.network.hostname;
      nameservers = [ "127.0.0.1" "192.168.178.5" "192.168.178.4" ];
      networkmanager.enable = true;
      firewall = {
        allowedTCPPorts = [
          80
          443 # nginx reverse proxy 
        ];

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
          "paperless.home.hoenle.xyz"
        ];
        "192.168.178.20" = [ "printer01" "printer01.fritz.box" ];
      };*/
    };
  };
}
