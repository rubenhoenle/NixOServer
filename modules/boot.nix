{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # https://discourse.nixos.org/t/disk-encryption-on-nixos-servers-how-when-to-unlock/5030

  # additional hardware configuration not discovered by hardware scan
  boot.initrd.availableKernelModules = [ "virtio-pci" "e1000e" ];

  #boot.initrd.secrets = {
  #  "/etc/secrets/initrd/ssh_host_rsa_key" = "/etc/secrets/initrd/ssh_host_rsa_key";
  #  "/etc/secrets/initrd/ssh_host_ed25519_key" = "/etc/secrets/initrd/ssh_host_ed25519_key";
  #};

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;

      shell = "/bin/cryptsetup-askpass";

      # sudo mkdir -p /etc/secrets/initrd
      # sudo ssh-keygen -t rsa -N "" -f /etc/secrets/initrd/ssh_host_rsa_key
      # sudo ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
      hostKeys = [
        "/etc/secrets/initrd/ssh_host_rsa_key"
        "/etc/secrets/initrd/ssh_host_ed25519_key"
      ];

      # this includes the ssh keys of all users in the wheel group, but you can just specify some keys manually
      authorizedKeys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGz2voOKRU2i2BECmdXRw+1okyV+Kwm6PSN0ghaD8zuqAAAABHNzaDo="
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsnp3qCYwCpb49UptuZ8csHzIZzZr0Buyl7uVW9udFdAAAABHNzaDo="
      ];

      #authorizedKeys = with lib; concatLists (mapAttrsToList (name: user: if elem "wheel" user.extraGroups then user.openssh.authorizedKeys.keys else []) config.users.users);
    };
  };

  boot.kernelParams = [ "ip=dhcp" ];
}
