{
  description = "generic Flake for Nextjs.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakelight.url = "github:nix-community/flakelight";
  };

  outputs =
    { flakelight, nixpkgs, ... }:
    flakelight ./. {

      inputs.nixpkgs = nixpkgs;

      devShell.packages =
        pkgs: with pkgs; [

          bun
          nodejs

          coreutils
          jq
          tmux
          bats

          lefthook
          commitlint-rs

          nodePackages.vercel
          stdenv.cc.cc.lib

        ];

      devShell.env = pkgs: {
        # Skip Playwright host requirements check on NixOS
        PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
      };
    };

}
