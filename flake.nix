{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = {
    self,
    nixpkgs,
  } @ inputs: let
    supportedSystems = [
      "aarch64-darwin"
      "x86_64-linux"
    ];

    # Function to generate a set based on supported systems
    forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

    # Attribute set of nixpkgs for each system
    nixpkgsFor = forAllSystems (system:
      import inputs.nixpkgs {
        inherit system;
      });
  in {
    packages = let
      name = "amiberry";
      version = "5.7.4";
      patches = [
        ./mt32emu-libdir.diff
      ];
      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp amiberry $out/bin
        cp -r abr cdroms conf controllers data floppies harddrives kickstarts \
              lha nvram plugins savestates screenshots whdboot \
             $out/
        wrapProgram $out/bin/amiberry \
          --set AMIBERRY_DATA_DIR $out \
          --run 'AMIBERRY_HOME_DIR="''${XDG_DATA_HOME:-$HOME}/.amiberry"' \
          --run 'mkdir -p $AMIBERRY_HOME_DIR'
        runHook postInstall
      '';
    in {
      x86_64-linux.default = let
        pkgs = nixpkgsFor.x86_64-linux;
        inherit (pkgs) lib stdenv;
      in
        stdenv.mkDerivation rec {
          inherit name version patches installPhase;

          src = pkgs.fetchFromGitHub {
            owner = "BlitterStudio";
            repo = "amiberry";
            rev = "refs/tags/v${version}";
            sha256 = "sha256-EOoVJYefX2pQ2Zz9bLD1RS47u/+7ZWTMwZYha0juF64=";
          };

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
            makeWrapper
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
            "PLATFORM=x86-64"
          ];
        };

      aarch64-darwin.default = let
        pkgs = nixpkgsFor.aarch64-darwin;
        inherit (pkgs) lib stdenv;
      in
        stdenv.mkDerivation rec {
          inherit name version patches installPhase;

          src = pkgs.fetchFromGitHub {
            owner = "BlitterStudio";
            repo = "amiberry";
            rev = "refs/tags/v${version}";
            sha256 = "sha256-EOoVJYefX2pQ2Zz9bLD1RS47u/+7ZWTMwZYha0juF64=";
          };

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
            makeWrapper
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
        };
    };

    formatter = forAllSystems (system: nixpkgsFor.${system}.alejandra);
  };
}
