{
  /* FYI: no need to open ports in the firewall when using SSH tunneling */
  services.nginx = {
    recommendedProxySettings = true;
    recommendedTlsSettings = false;
  };
}
