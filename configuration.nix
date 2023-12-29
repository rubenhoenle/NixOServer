{ config, pkgs, agenix, ... }:
{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mandalore";

  # Enable networking
  networking.networkmanager.enable = true;

  users.users.ruben = {
    isNormalUser = true;
    description = "Ruben";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      #vim
    ];
  };

  # Enable experimental support for flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    screenfetch
    agenix
  ];

  # https://discourse.nixos.org/t/disk-encryption-on-nixos-servers-how-when-to-unlock/5030


  # additional hardware configuration not discovered by hardware scan
  boot.initrd.availableKernelModules = [ "virtio-pci" "e1000e" ];

  #boot.initrd.secrets = {
  #      "/etc/secrets/initrd/ssh_host_rsa_key" = "/etc/secrets/initrd/ssh_host_rsa_key";
  #	"/etc/secrets/initrd/ssh_host_ed25519_key" = "/etc/secrets/initrd/ssh_host_ed25519_key";
  #     };

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
        "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBNk/0ETSX9reNQaOJZDXm52cVx767pnJJW4K+jjJF53VSiHQcb6G4rpE16a51lWssAOVHFySGRb2q/cs1esNYu8AAAAEc3NoOg=="
      ];

      #authorizedKeys = with lib; concatLists (mapAttrsToList (name: user: if elem "wheel" user.extraGroups then user.openssh.authorizedKeys.keys else []) config.users.users);
    };
    #postCommands = ''
    #  echo 'cryptsetup-askpass' >> /root/.profile
    #'';
  };

  boot.kernelParams = [ "ip=dhcp" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
