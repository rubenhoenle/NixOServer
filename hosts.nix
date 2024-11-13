{ nixos-hardware, ... }: [
  {
    name = "mandalore";
    system = "x86_64-linux";
    nixosModules = [
      ./hardware/thinkcentre-m710q.nix
      ./modules/boot.nix
      {
        networking.hostName = "mandalore";

        virtualisation.podman.enable = false;

        ruben = {
          gatus.enable = false;
          paperless.enable = true;
          gitserver.enable = true;
          phone-backup.enable = true;
          fileserver.enable = true;

          fullbackup.enable = true;
        };

        services = {
          minecraft-server.enable = false;
          nginx.enable = false;
          unbound.enable = false;
        };

        ruben.bk-nc-backup.enable = true;

        swapDevices = [{
          device = "/var/lib/swapfile";
          size = 8 * 1024;
        }];

        system.stateVersion = "23.11";
      }
    ];
  }
]
