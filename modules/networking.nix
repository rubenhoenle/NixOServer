{ config, pkgs, lib, ... }:
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
      networkmanager.enable = true;
      firewall = {
        allowedTCPPorts = [
          22 # endless ssh
          53
          69 # openssh 
          80
          443 # nginx reverse proxy 
          8080 # for http testing 
          2222 # initrd ssh server 
        ];
        allowedUDPPorts = [ 22 53 69 2222 ];

        interfaces."podman+" = {
          allowedUDPPorts = [ 53 ];
          allowedTCPPorts = [ 53 ];
        };
      };
    };
  };
}
