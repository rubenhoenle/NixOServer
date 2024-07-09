{ nixos-hardware, ... }: [
  {
    name = "mandalore";
    system = "x86_64-linux";
    nixosModules = [
      ./hardware/thinkcentre-m710q.nix
      ./modules/boot.nix
      {
        ruben.network.hostname = "mandalore";

        ruben.gatus.enable = true;
        ruben.gickup.enable = true;
        ruben.hedgedoc.enable = true;
        ruben.homer.enable = true;
        ruben.matrixbridge.enable = true;
        ruben.nginx.enable = true;
        ruben.paperless.enable = true;
        ruben.stashapp.enable = true;
        ruben.tandoor.enable = true;
        ruben.minecraft.enable = true;

        #ruben.syncthing.enable = true;

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

        # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
        boot.loader.grub.enable = false;
        # Enables the generation of /boot/extlinux/extlinux.conf
        boot.loader.generic-extlinux-compatible.enable = true;

        system.stateVersion = "24.05";
      }
    ];
  }
]
