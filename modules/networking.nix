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
        allowedTCPPorts = [ 22 53 69 80 443 8080 2222 ];
        allowedUDPPorts = [ 22 53 69 2222 ];

        #interfaces.podman1 = {
        #  allowedUDPPorts = [ 53 ]; # this needs to be there so that containers can look eachother's names up over DNS
        #};
        interfaces."podman+" = {
          allowedUDPPorts = [ 53 ];
          allowedTCPPorts = [ 53 ];
        };
      };
    };
  };
}
