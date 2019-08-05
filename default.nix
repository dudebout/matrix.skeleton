{ nixpkgs ? import <nixpkgs> {} }:

with nixpkgs;
stdenv.mkDerivation rec {
  name = "matrix.skeleton";
  src = nix-gitignore.gitignoreSource [".gitignore" "example.png" "*.nix"] ./.;
  installPhase = ''
    PREFIX=$out make install
  '';
  buildInputs = [
    (texlive.combine {
        inherit (texlive) scheme-small cleveref standalone;
    })
  ];
}
