{
  description = "Build environment for fonts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    fontforge_patched = pkgs.fontforge.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          (pkgs.fetchpatch {
            url = "https://github.com/fontforge/fontforge/pull/5643.patch";
            hash = "sha256-2EzYwj38huQMwSAVCZliUO5aZKD+sg/1o43NDUsM0h8=";
          })
          (pkgs.fetchpatch {
            url = "https://github.com/fontforge/fontforge/pull/5702.patch";
            hash = "sha256-GuIsHixsbXoNxfXOQDe244ZigfXnSl1rbeI/5QTYqi0=";
          })
        ];
    });

    pythonWithFontforge = pkgs.python3.withPackages (ps: with ps; [
      (toPythonModule fontforge_patched)
      fonttools
      fontmake
    ]);
  in {
    packages.${system}.fontforge = fontforge_patched;

    devShells.${system}.default = pkgs.mkShellNoCC {
      packages = [
        pythonWithFontforge
        pkgs.ttfautohint-nox
      ];
    };
  };
}
