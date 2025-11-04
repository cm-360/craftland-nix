{
  description = "Craftland Aether server launcher";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];

      forAllSystems =
        function:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          function (
            import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            }
          )
        );
    in
    {
      overlays.default = final: prev: {
        craftland-launcher = final.callPackage ./package.nix { };
      };

      packages = forAllSystems (pkgs: rec {
        inherit (pkgs) craftland-launcher;
        default = craftland-launcher;
      });
    };
}
