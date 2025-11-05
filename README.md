# Craftland Launcher Flake

This is an **unofficial** Nix flake packaging the [Craftland](https://craftland.org/) modded Aether server's launcher. The provided package wraps the original launcher files from the website with a suitable Java 17 runtime and some necessary libraries.

## Usage

Start by adding this repository to your inputs in `flake.nix`:

```nix
inputs = {
    craftland-nix.url = "github:cm-360/craftland-nix";
    ...
};
```

This flake provides only a single package: `craftland-launcher`. The recommended way to install it is by applying the provided overlay:

```nix
overlays = [
    inputs.craftland-nix.overlays.default
];
```

The package would then be accessible via `pkgs.craftland-launcher`. More information about using overlays is available on the [NixOS Wiki](https://nixos.wiki/wiki/Overlays).

Alternatively, you can directly list the package in either `environment.systemPackages` or `home.packages` with the following:

```nix
inputs.craftland-nix.packages."${system}".default
```
