{ nixos-hardware, ... }: [
  {
    name = "mandalore";
    nixosModules = [
      ./hardware/thinkcentre-m710q.nix
      {
        ruben.network.hostname = "mandalore";

        ruben.gatus.enable = true;
        ruben.gickup.enable = true;
        ruben.homer.enable = true;
        ruben.matrixbridge.enable = true;
        ruben.nginx.enable = true;
        ruben.nextcloud.enable = true;
        ruben.paperless.enable = true;
        ruben.stashapp.enable = true;
        ruben.tandoor.enable = true;

        #ruben.syncthing.enable = true;

        swapDevices = [{
          device = "/var/lib/swapfile";
          size = 8 * 1024;
        }];
      }
    ];
  }
]
