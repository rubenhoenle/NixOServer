# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  boot.loader.grub.enableCryptodisk=true;

  boot.initrd.luks.devices."luks-3b42cfe9-f1cd-436f-9e5d-35110f30dde8".keyFile = "/crypto_keyfile.bin";
  networking.hostName = "mandalore"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "de";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ruben = {
    isNormalUser = true;
    description = "Ruben";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
	vim
	git
	htop
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  #services.openssh.enable = true;
  services.openssh = {
  	enable = true;
  	# require public key authentication for better security
  	settings.PasswordAuthentication = false;
  	settings.KbdInteractiveAuthentication = false;
  	#settings.PermitRootLogin = "yes";
  };

  users.users."ruben".openssh.authorizedKeys.keys = [
    "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBNk/0ETSX9reNQaOJZDXm52cVx767pnJJW4K+jjJF53VSiHQcb6G4rpE16a51lWssAOVHFySGRb2q/cs1esNYu8AAAAEc3NoOg== ruben" # content of authorized_keys file
    # note: ssh-copy-id will add user@your-machine after the public key
    # but we can remove the "@your-machine" part
  ];


  # https://discourse.nixos.org/t/disk-encryption-on-nixos-servers-how-when-to-unlock/5030


  # additional hardware configuration not discovered by hardware scan
  boot.initrd.availableKernelModules = [ "virtio-pci" "e1000e" ];

  boot.initrd.secrets = {
        "/etc/secrets/initrd/ssh_host_rsa_key" = "/etc/secrets/initrd/ssh_host_rsa_key";
	"/etc/secrets/initrd/ssh_host_ed25519_key" = "/etc/secrets/initrd/ssh_host_ed25519_key";
      };

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;

      # ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
      hostKeys = [
        "/etc/secrets/initrd/ssh_host_rsa_key"
	"/etc/secrets/initrd/ssh_host_ed25519_key"
      ];


      #hostECDSAKey = /var/src/secrets/dropbear/ecdsa-hostkey;
      # this includes the ssh keys of all users in the wheel group, but you can just specify some keys manually
      authorizedKeys = [ 
        "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBNk/0ETSX9reNQaOJZDXm52cVx767pnJJW4K+jjJF53VSiHQcb6G4rpE16a51lWssAOVHFySGRb2q/cs1esNYu8AAAAEc3NoOg== ruben@deathstar"
	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPSGQkg+lmetJAVsd0Ojy76ehuoc2aJuIP03f08Ny0lQ ruben@millenium-falcon"
      ];
      
      #authorizedKeys = with lib; concatLists (mapAttrsToList (name: user: if elem "wheel" user.extraGroups then user.openssh.authorizedKeys.keys else []) config.users.users);
    };
    #postCommands = ''
    #  echo 'cryptsetup-askpass' >> /root/.profile
    #'';
  };

    boot.initrd.network.postCommands = let
      # I use a LUKS 2 label. Replace this with your disk device's path.
      disk = "/dev/disk/by-uuid/3b42cfe9-f1cd-436f-9e5d-35110f30dde8";
    in ''
      echo 'cryptsetup open ${disk} root --type luks && echo > /tmp/continue' >> /root/.profile
      echo 'starting sshd...'
    '';
    # Block the boot process until /tmp/continue is written to
    boot.initrd.postDeviceCommands = ''
      echo 'waiting for root device to be opened...'
      mkfifo /tmp/continue
      cat /tmp/continue
    '';


  boot.kernelParams = [ "ip=dhcp" ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 2222 ];
  networking.firewall.allowedUDPPorts = [ 22 2222 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
