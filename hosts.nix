{ nixos-hardware }: [
  {
    name = "mandalore";
    nixosModules = [
      ./hardware/thinkcentre-m710q.nix
      {
        ruben.network.hostname = "mandalore";

        ruben.paperless.enable = true;
        ruben.gickup.enable = true;

        swapDevices = [{
          device = "/var/lib/swapfile";
          size = 8 * 1024;
        }];
      }
    ];
  }
]
