{ config, ... }:
{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # additional hardware configuration not discovered by hardware scan
  boot.initrd.availableKernelModules = [ "virtio-pci" "e1000e" ];

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 45274;

      shell = "/bin/cryptsetup-askpass";

      # sudo mkdir -p /etc/secrets/initrd
      # sudo ssh-keygen -t rsa -N "" -f /etc/secrets/initrd/ssh_host_rsa_key
      # sudo ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
      hostKeys = [
        "/etc/secrets/initrd/ssh_host_rsa_key"
        "/etc/secrets/initrd/ssh_host_ed25519_key"
      ];

      authorizedKeys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGz2voOKRU2i2BECmdXRw+1okyV+Kwm6PSN0ghaD8zuqAAAABHNzaDo="
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsnp3qCYwCpb49UptuZ8csHzIZzZr0Buyl7uVW9udFdAAAABHNzaDo="

        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN17O8nYCSqrUUboEl5fHFN5suqsAgDboPM/6ORrnqVaAAAABHNzaDo="
      ];
    };
  };

  boot.kernelParams = [ "ip=dhcp" ];

  /* open firewall ports */
  networking.firewall =
    let
      port = config.boot.initrd.network.ssh.port;
    in
    {
      allowedTCPPorts = [ port ];
      allowedUDPPorts = [ port ];
    };
}
