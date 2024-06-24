{
  description = "A basic flakelight templ to be used with nix-direnv";

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
          pre-commit

          awscli2

        ];
    };

}
