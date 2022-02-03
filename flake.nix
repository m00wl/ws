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
      ws = pkgs.stdenv.mkDerivation {
        name = "ws";
        src = self;
        buildPhase = ''
          jekyll build
        '';
        installPhase = ''
          mkdir -p $out/_site
          cp -r _site $out
        '';
        nativeBuildInputs = [
          pkgs.jekyll
        ];
      };
      host_ws = pkgs.writeShellScriptBin "host_ws" ''
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
        host_ws = flake-utils.lib.mkApp { 
          drv = host_ws;
        };
      };
      defaultApp = apps.host_ws;
    }
  );
}
