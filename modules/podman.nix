{
  virtualisation = {
    podman = {
      enable = true;
      # Required for containers under podman-compose to be able to talk to each other.
      # defaultNetwork.settings.dns_enabled = true;
    };
  };
}
