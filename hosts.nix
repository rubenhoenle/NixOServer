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

        ruben = {
          sangam-quiz.enable = true;
          commanderer.enable = true;
          nginx.enable = true;
        };

        boot.loader.grub.enable = true;

        services = {
          minecraft-server.enable = true;
          teamspeak3 = {
            enable = true;
            openFirewall = true;
          };
        };

        # ipv6 config
        systemd.network.enable = true;
        systemd.network.networks."30-wan" = {
          matchConfig.Name = "enp1s0"; # either ens3 or enp1s0, check 'ip addr'
          networkConfig.DHCP = "ipv4";
          address = [
            # replace this subnet with the one assigned to your instance
            "2a01:4f8:1c1c:1e6e::/64"
          ];
          routes = [
            { Gateway = "fe80::1"; }
          ];
        };

        swapDevices = [{
          device = "/var/lib/swapfile";
          size = 4 * 1024;
        }];

        system.stateVersion = "24.11";
      }
    ];
  }
]
