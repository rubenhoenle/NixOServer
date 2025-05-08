{ lib, config, ... }:
{
  options.ruben.fileserver = {
    enable = lib.mkEnableOption "fileserver";
    path = lib.mkOption {
      type = lib.types.str;
      default = "/home/fileserver";
    };
  };

  config = lib.mkIf (config.ruben.fileserver.enable)
    {
      users.users.fileserver = {
        isNormalUser = true;
        createHome = true;
        home = config.ruben.fileserver.path;
        openssh.authorizedKeys.keys = config.ruben.ssh.authorizedKeys;
        uid = 1003;
      };
    };
}
