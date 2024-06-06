{ nixos-hardware }: [
  {
    name = "mandalore";
    nixosModules = [
      ./hardware/thinkcentre-m710q.nix
      {
        ruben.network.hostname = "mandalore";

        ruben.gickup.enable = true;
        ruben.matrixbridge.enable = true;
        ruben.nextcloud.enable = true;
        ruben.paperless.enable = true;
        ruben.stashapp.enable = true;
        ruben.tandoor.enable = true;

        swapDevices = [{
          device = "/var/lib/swapfile";
          size = 8 * 1024;
        }];
      }
    ];
  }
]
