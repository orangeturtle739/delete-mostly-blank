{
  description = "Shell script to delete mostly blank pages in a PDF";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "aarch64-linux" "i686-linux" "x86_64-linux" ]
    (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        progs = with pkgs; [ pdftk ghostscript nawk gawk bc coreutils gnugrep ];

        myProgram = pkgs.stdenv.mkDerivation rec {
          name = "delete-mostly-blank";
          buildInputs = progs ++ [ pkgs.shellcheck pkgs.makeWrapper ];
          src = self;
          installPhase = ''
            mkdir -p $out/bin
            cp delete-mostly-blank $out/bin/
            wrapProgram $out/bin/delete-mostly-blank --set PATH ${
              pkgs.lib.makeBinPath progs
            }
          '';
        };
      in {
        devShell = myProgram;
        defaultPackage = myProgram;
        defaultApp = {
          type = "app";
          program = "${myProgram}/bin/delete-mostly-blank";
        };
      });
}
