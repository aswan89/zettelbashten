{
  description = "A zettelkasten using bash and GNU recutils";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let

      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlays.default ]; });

    in

    {

      # A Nixpkgs overlay.
      overlays.default = final: prev: {

        zettelbashten = with final; stdenv.mkDerivation rec {
          name = "zettelbashten";
          version = "v0.2";
          src = ./.;
          patchPhase = "patchShebangs zettel_create";
          buildInputs = [ makeWrapper ];
          installPhase = let deps = lib.makeBinPath [ recutils ]; in 
            ''
              mkdir -p $out/bin
              cp zettel_create $out/bin/zettel_create
              wrapProgram $out/bin/zettel_create --prefix PATH : "${deps}"
            '';
        };

      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) zettelbashten;
        });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.zettelbashten);
    };
}
