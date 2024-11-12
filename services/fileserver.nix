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
        openssh.authorizedKeys.keys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGz2voOKRU2i2BECmdXRw+1okyV+Kwm6PSN0ghaD8zuqAAAABHNzaDo= ruben"
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsnp3qCYwCpb49UptuZ8csHzIZzZr0Buyl7uVW9udFdAAAABHNzaDo= ruben"
        ];
        uid = 1003;
      };
    };
}
