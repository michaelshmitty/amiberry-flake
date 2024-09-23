{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = {self, nixpkgs}:
    let pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    inherit (pkgs) lib stdenv;
    in {
      packages.aarch64-darwin.default = stdenv.mkDerivation rec {
        name = "amiberry";
        version = "5.7.4";

        src = pkgs.fetchFromGitHub {
          owner = "BlitterStudio";
          repo = "amiberry";
          rev = "refs/tags/v${version}";
          sha256 = "sha256-EOoVJYefX2pQ2Zz9bLD1RS47u/+7ZWTMwZYha0juF64=";
        };

        patches = [
          ./mt32emu-libdir.diff
        ];

        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
        ];

        buildInputs = with pkgs; [
          flac
          freetype
          glib
          harfbuzz
          libmpeg2
          libmpg123
          libogg
          libpng
          libserialport
          mpeg2dec
          portmidi
          SDL2
          SDL2_image
          SDL2_ttf
        ];

        configurePhase = ''
          runHook preConfigure
          runHook postConfigure
        '';

        env.EXTRA_CFLAGS = toString [
          "-I${lib.getDev pkgs.flac}/include"
          "-I${lib.getDev pkgs.libmpg123}/include"
          "-I${lib.getDev pkgs.libpng}/include"
          "-I${lib.getDev pkgs.libserialport}/include"
          "-I${lib.getDev pkgs.mpeg2dec}/include"
          "-I${lib.getDev pkgs.portmidi}/include"
          "-I${lib.getDev pkgs.SDL2}/include"
        ];

        makeFlags = [
          "PLATFORM=osx-m1"
        ];

        installPhase = ''
          mkdir -p $out/bin
          cp amiberry $out/bin
          #cp -r abr cdroms conf controllers data floppies harddrives kickstarts lha nvram \
          #      plugins savestates screenshots whdboot \
          #      $out/
        '';
      };
    };
}
