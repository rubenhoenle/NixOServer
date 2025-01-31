{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # agenix for encrypting secrets
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # formatter for *.nix files
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, agenix, disko, treefmt-nix, nixos-hardware, ... }:
    let
      pkgs = system: import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
      pkgs-unstable = system: import nixpkgs-unstable {
        inherit system;
        config = { allowUnfree = true; };
      };
      lib = nixpkgs.lib;

      treefmtEval = treefmt-nix.lib.evalModule (pkgs "x86_64-linux") ./treefmt.nix;
    in
    {
      formatter."x86_64-linux" = treefmtEval.config.build.wrapper;
      checks."x86_64-linux".formatter = treefmtEval.config.build.check self;

      nixosConfigurations = builtins.listToAttrs (
        builtins.map
          (host: {
            name = host.name;
            system = host.system;
            value = lib.nixosSystem {
              system = host.system;
              pkgs = (pkgs host.system);
              specialArgs = {
                pkgs-unstable = pkgs-unstable host.system;
              };
              modules = [
                disko.nixosModules.disko
                agenix.nixosModules.default
                {
                  _module.args.agenix = agenix.packages.${host.system}.default;
                }
                ./modules/modules.nix
                ./services/services.nix
              ] ++ host.nixosModules;
            };
          })
          (import ./hosts.nix { inherit nixos-hardware; })
      );
    };
}
