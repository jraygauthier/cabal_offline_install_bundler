{ nixpkgs ? import <nixpkgs> {}, compiler ? "default" }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, cabal-install
      }:
      mkDerivation {
        pname = "cabal_offline_install_download_env";
        version = "0.0.0.0";
        src = ./.;
        libraryHaskellDepends = [
          cabal-install
        ];
        executableSystemDepends = with pkgs; [ 
              curl
              wget
              coreutils # For `realpath` used in `./run.sh`.
        ];

        license = "GPL";
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  drv = haskellPackages.callPackage f {};

in

  if pkgs.lib.inNixShell then drv.env else drv

