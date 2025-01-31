{ nixos-hardware, ... }: [
  {
    name = "mandalore";
    system = "x86_64-linux";
    nixosModules = [
      ./hardware/thinkcentre-m710q.nix
      ./modules/boot.nix
      ./modules/secrets.nix
      {
        networking.hostName = "mandalore";

        #virtualisation.podman.enable = true;

        ruben = {
          paperless.enable = true;
          gitserver.enable = true;
          phone-backup.enable = true;
          fileserver.enable = true;

          fullbackup.enable = true;
        };

        services = {
          minecraft-server.enable = false;
          nginx.enable = false;
        };

        swapDevices = [{
          device = "/var/lib/swapfile";
          size = 8 * 1024;
        }];

        system.stateVersion = "23.11";
      }
    ];
  }
  {
    name = "vps";
    system = "x86_64-linux";
    nixosModules = [
      ./hardware/hetzner-vm.nix
      ./disko-config.nix
      {
        networking.hostName = "vps";

        services.nginx.enable = true;

        boot.loader.grub.enable = true;

        swapDevices = [{
          device = "/var/lib/swapfile";
          size = 4 * 1024;
        }];

        system.stateVersion = "24.11";
      }
    ];
  }
]
