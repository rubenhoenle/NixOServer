{ config, pkgs, ... }:
{
  networking = {
    hostName = "mandalore";
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 22 53 69 80 443 8080 2222 ];
      allowedUDPPorts = [ 22 53 69 80 443 8080 2222 ];
    };
  };
}
