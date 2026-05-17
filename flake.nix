{
  description = "Home Manager configuration for NixOS user env";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, nur, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        config.allowUnfree = true;
        inherit system;
        overlays = [ nur.overlays.default ];
      };
    in
    {
      homeConfigurations."hogan" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
}
