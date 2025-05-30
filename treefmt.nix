{
  projectRootFile = "flake.nix";
  settings.global.excludes = [ "*.age" ];
  programs.nixpkgs-fmt.enable = true;

  programs.prettier = {
    enable = true;
    includes = [
      "*.md"
      "*.yaml"
      "*.yml"
    ];
  };
}
