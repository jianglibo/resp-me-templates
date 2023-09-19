# single line comment
/* mulitple line comments
*/

# install
# https://nixos.org/download.html
# envrc
# https://direnv.net/docs/installation.html

# tutorial https://serokell.io/blog/practical-nix-flakes

# https://search.nixos.org/packages
# https://nixos.org/guides/nix-pills/
# https://nixos.org/manual/nixpkgs/stable/
# https://ryantm.github.io/nixpkgs/using/overlays/
# https://nixos.org/manual/nix/stable/language/builtins.html

/*
nix repl:
:? for help
:l <nixpkgs>
builtins.attrNames builtins
use <tab> to show variables in the scope.
 */

/*
stdenv is one attribute of the pkgs attr set. it's a derivation too.
 */
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        # packages.hello = pkgs.hello;
        devShell = pkgs.mkShell { 
          buildInputs = [ pkgs.jdk17_headless pkgs.git pkgs.openssl pkgs.nodejs];
          shellHook = ''
            export JAVA_HOME=${pkgs.jdk17_headless}
          '';
     };
      });
}