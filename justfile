default:
    @just --list

switch:
    nix run home-manager/release-25.11 -- switch --flake .

switch-abs:
    /nix/var/nix/profiles/default/bin/nix run home-manager/release-25.11 -- switch --flake .

validate:
    nix flake check --no-build --no-write-lock-file

check: validate
    command -v nix
    echo $SHELL
    command -v nvim
    nvim --version
    mise --version
    grep -Fx 'check_for_update_on_startup = false' "$HOME/.codex/config.toml"
    codex --version
    zellij --version
    direnv --version
    mosh --version
    ffmpeg -version
    hf --help
    gh --version
    just --version
    tldr --version
    tree --version
    yq --version

# Refresh only the latest-tracking npm Codex package managed by Mise. Codex's
# own startup update check stays disabled by the Home Manager activation.
codex-update:
    mise upgrade npm:@openai/codex

# Update every flake input, then apply the resulting Home Manager profile.
update:
    nix flake update
    just switch

# Update one named flake input, then apply the resulting Home Manager profile.
# Usage: just update-input nixpkgs
update-input input:
    nix flake update {{ input }}
    just switch
