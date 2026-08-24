{
  description = "LaTeX build environment";

  inputs = {
    nixpkgs.url = "github:NixOS/Nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "latex-shell";

          nativeBuildInputs = with pkgs; [
            texliveFull
            biber        # Optional: For biblatex references
            ghostscript  # Optional: For PDF rendering/conversion
          ];

          shellHook = ''
            echo "LaTeX environment loaded (pdflatex, xelatex, lualatex ready)."
          '';
        };
      });
}
