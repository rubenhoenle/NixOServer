{ nixos-hardware, ... }: [
  {
    name = "mandalore";
    system = "x86_64-linux";
    nixosModules = [
      ./hardware/thinkcentre-m710q.nix
      ./modules/boot.nix
      {
        ruben.network.hostname = "mandalore";

        virtualisation.podman.enable = false;

        ruben = {
          gatus.enable = false;
          homer.enable = false;
          paperless.enable = true;
          gitserver.enable = true;
          phone-backup.enable = true;
          fileserver.enable = true;
        };

        services = {
          minecraft-server.enable = true;
          nginx.enable = true;
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
  {
    name = "scarif";
    system = "aarch64-linux";
    nixosModules = [
      ./hardware/raspberry-pi-4.nix
      {
        ruben.network.hostname = "scarif";

        ruben.filebrowser.enable = true;

        # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
        boot.loader.grub.enable = false;
        # Enables the generation of /boot/extlinux/extlinux.conf
        boot.loader.generic-extlinux-compatible.enable = true;

        system.autoUpgrade.enable = true;

        system.stateVersion = "24.05";
      }
    ];
  }
]
