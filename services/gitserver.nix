{ config, lib, pkgs, ... }: {
  options.ruben.gitserver = {
    enable = lib.mkEnableOption "git server";
    path = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/git-server";
    };
  };

  config = lib.mkIf (config.ruben.gitserver.enable)
    {
      users.users.git = {
        isSystemUser = true;
        group = "git";
        home = config.ruben.gitserver.path;
        createHome = true;
        shell = "${pkgs.git}/bin/git-shell";
        openssh.authorizedKeys.keys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGz2voOKRU2i2BECmdXRw+1okyV+Kwm6PSN0ghaD8zuqAAAABHNzaDo="
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsnp3qCYwCpb49UptuZ8csHzIZzZr0Buyl7uVW9udFdAAAABHNzaDo="

          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN17O8nYCSqrUUboEl5fHFN5suqsAgDboPM/6ORrnqVaAAAABHNzaDo="
        ];
        uid = 976;
      };
      users.groups.git.gid = 974;

      services.openssh = {
        enable = true;
        extraConfig = ''
          Match user git
            AllowTcpForwarding no
            AllowAgentForwarding no
            PasswordAuthentication no
            PermitTTY no
            X11Forwarding no
        '';
      };
    };
}

