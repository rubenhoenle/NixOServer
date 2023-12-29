{ nixos-hardware }: [
  {
    name = "mandalore";
    nixosModules = [
      ./hardware-configuration.nix
      {
        #ruben.network.hostname = "mandalore";
        #ruben.paperless.enable = true;
        ruben.backup.enable = true;
        #ruben.wireguard.enable = true;
        #ruben.battery.notifications = {
        #  enable = true;
        #  percentage = 15;
        #};

        # Setup keyfile
        #boot.initrd.secrets = {
        #  "/crypto_keyfile.bin" = null;
        #};

        # Enable swap on luks
        #boot.initrd.luks.devices."luks-6d3659bf-9d20-42ad-9fe5-43395cdb683f".device = "/dev/disk/by-uuid/6d3659bf-9d20-42ad-9fe5-43395cdb683f";
        #boot.initrd.luks.devices."luks-6d3659bf-9d20-42ad-9fe5-43395cdb683f".keyFile = "/crypto_keyfile.bin";

        swapDevices = [{
          device = "/var/lib/swapfile";
          size = 8 * 1024;
        }];

      }
    ];
  }
]
