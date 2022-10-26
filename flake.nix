{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
  };

  outputs = { self, nixpkgs }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {

    defaultPackage.x86_64-linux = pkgs.stdenv.mkDerivation rec {
      name = "matrix.skeleton";
      src = pkgs.nix-gitignore.gitignoreSource [".gitignore" "example.png" "*.nix"] ./.;
      installPhase = ''
        PREFIX=$out make install
      '';
      buildInputs = [
        (pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-small cleveref standalone;
        })
      ];
    };
  };
}
