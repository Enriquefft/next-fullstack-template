{
  description = "generic Flake for Next api's.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flakelight.url = "github:nix-community/flakelight";
  };

  outputs = { flakelight, nixpkgs, ... }:
    flakelight ./. {

      inputs.nixpkgs = nixpkgs;

      devShell.packages = pkgs:
        with pkgs; [

          bun
          nodejs

          coreutils

          lefthook
          commitlint-rs
                    biome

        ];
    };

}
