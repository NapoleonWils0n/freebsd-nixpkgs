{
  description = "A development shell for ffmpeg";

  inputs = {
    nixpkgs.url = "github:NixOS/Nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell rec {
          name = "ffmpeg-shell";

          buildInputs = with pkgs; [
            ffmpeg-full
            fdk-aac-encoder
            yt-dlp
          ];

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

          shellHook = ''
            echo "Entering ffmpeg development shell"
          '';
        };
      });
}
