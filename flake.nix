{
  description = "Live Coder";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bqnlsp.url = "sourcehut:~detegr/bqnlsp";
  };

  outputs = { self, nixpkgs, flake-utils, bqnlsp }:
    flake-utils.lib.eachDefaultSystem (system:
    let

      pkgs = nixpkgs.legacyPackages.${system};
      cbqn = pkgs.cbqn-replxx;
      bqnlspPkg = bqnlsp.packages.${system}.lsp;
      raylib = pkgs.raylib;

    in rec {

      packages.default = pkgs.writeShellScriptBin "run" /*bash*/ ''
        # Loading the submodules
        git submodule update --init --recursive
        # (cd ./rayed-bqn; git submodule update --init --recursive)

        # Overwriting the default raylib loading
        echo "raylibheaderpath ⇐ •file.At \"${raylib}/include/raylib.h\"" > ./rayed-bqn/config.bqn
        echo "rayliblibpath ⇐ •file.At \"${raylib}/lib/libraylib.dylib\"" >> ./rayed-bqn/config.bqn
        echo "⟨raylibheaderpath ⋄ rayliblibpath⟩ ⇐ •Import \"../config.bqn\"" > ./rayed-bqn/src/loadConfig.bqn

        # Running the program
     	  ${cbqn}/bin/bqn -f ./src/main.bqn
      '';

      devShells.default = pkgs.mkShell {
        buildInputs = [
          cbqn
          bqnlspPkg
        ];
      };
  });
}
