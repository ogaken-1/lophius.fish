# lophius.fish

Tab completion via fzf for fish shell.

Most of snippets are ported from https://github.com/yuki-yano/zeno.zsh

## Breaking change in v0.5.0

The namespace has been completely changed from `fzf_complete` / `FZF_COMPLETE_*` to `lophius` / `LOPHIUS_*`.

**Why:** fzf's official distribution now ships a function named `fzf_complete`, which collides with the previous naming of this plugin. To avoid the conflict, the plugin adopts the fully independent name `lophius` — the genus name of anglerfish, which lures fish with bait (a metaphor for luring completions with fzf). The internal `__fzf_complete_*` prefix is renamed together for consistency.

Migration:

```fish
# Before
bind tab fzf_complete
set -g FZF_COMPLETE_NO_DEFAULT_BINDING 1

# After
bind tab lophius
set -g LOPHIUS_NO_DEFAULT_BINDING 1
```

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

Press `?` to toggle preview in fzf.

## Configuration

Set `LOPHIUS_NO_DEFAULT_BINDING` to disable the default Tab binding:

```fish
set -g LOPHIUS_NO_DEFAULT_BINDING 1
```

## Acknowledgments

- [zeno.zsh](https://github.com/yuki-yano/zeno.zsh) by [@yuki-yano](https://github.com/yuki-yano) - Original implementation for zsh

## License

MIT
