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
        openssh.authorizedKeys.keys = config.ruben.ssh.authorizedKeys;
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

