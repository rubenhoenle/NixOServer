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
    };
  };
}
