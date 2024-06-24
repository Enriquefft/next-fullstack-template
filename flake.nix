{
  description = "A basic flakelight templ to be used with nix-direnv";

  inputs = {

    flakelight.url = "github:nix-community/flakelight";
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  };

  outputs = { flakelight, ... }:
    flakelight ./. ({ inputs, ... }: {
      inherit inputs;
      devShell.packages = pkgs:
        with pkgs; [

          bun
          nodejs

          coreutils

          lefthook
          pre-commit

          awscli2

        ];
    });

}
