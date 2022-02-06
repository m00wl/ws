{
  description = "flake for m00wl's personal website";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
      ruby = pkgs.ruby;
      ws-gems = pkgs.bundlerEnv {
        name = "ws-gems";
        inherit (pkgs.ruby);
        gemdir = ./.;
      };
      ws = pkgs.stdenv.mkDerivation {
        name = "ws";
        src = self;
        buildPhase = ''
          bundle exec jekyll build
        '';
        installPhase = ''
          mkdir -p $out/_site
          cp -r _site $out
        '';
        buildInputs = [
          ws-gems
          ruby
        ];
      };
      ws-host = pkgs.writeShellScriptBin "ws-host" ''
        cd ${ws}
        ${pkgs.jekyll}/bin/jekyll serve \
          --safe \
          --skip-initial-build \
          --open-url
      '';
    in
    rec {
      packages = flake-utils.lib.flattenTree {
        inherit ws;
      };
      defaultPackage = packages.ws;
      apps = {
        ws-host = flake-utils.lib.mkApp { 
          drv = ws-host;
        };
      };
      defaultApp = apps.ws-host;
    }
  );
}
