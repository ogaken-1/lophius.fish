# lophius.fish

Tab completion via fzf for fish shell.

The git and kill snippets are shamelessly stolen from [zeno.zsh](https://github.com/yuki-yano/zeno.zsh).

## Requirements

- [fzf](https://github.com/junegunn/fzf)

## Install

### Fisher

```fish
fisher install ogaken-1/lophius.fish
```

### home-manager (Nix)

Add repo to `inputs` of flake.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lophius = {
      url = "github:ogaken-1/lophius.fish";
    };
  };
  outputs = { nixpkgs, home-manager, lophius, ...  }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      homeConfiguration = { pkgs, ... }: {
        # Add overlay to `nixpkgs.overlays`
        nixpkgs.overlays = [
          lophius.overlays.default
        ];
        programs.fish = {
          enable = true;
        };
        # Add package to `home.packages`.
        home.packages = [
          pkgs.fishPlugins.lophius
        ];
      };
    in
    {
      homeConfigurations.alice = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          homeConfiguration
        ];
      };
    };

}
```

## Features

- **git**: Context-aware completion for subcommands (branches, commits, files, remotes, etc.) with preview
- **cd**: Directory completion with preview
- **kill**: Process completion
- **Fallback**: Falls back to fish's `complete -C` piped through fzf for unconfigured commands

Press `?` to toggle preview in fzf.

## Configuration

Set `LOPHIUS_NO_DEFAULT_BINDING` to disable the default Tab binding:

```fish
set -g LOPHIUS_NO_DEFAULT_BINDING 1
```

## Acknowledgments

- [zeno.zsh](https://github.com/yuki-yano/zeno.zsh) by [@yuki-yano](https://github.com/yuki-yano) - Original implementation for zsh
- [fzf](https://github.com/junegunn/fzf) by [@junegunn](https://github.com/junegunn) - The `complete -C` based fallback is adapted from fzf's `shell/completion.fish` (MIT License). See `LICENSE`.

## License

MIT
