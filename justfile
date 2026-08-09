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
    codex --version
    zellij --version
    direnv --version
    zoxide --version
    gh --version
    just --version
    tldr --version
    tree --version
    yq --version

# Refresh only the latest-tracking npm Codex package managed by Mise.
codex-update:
    mise upgrade npm:@openai/codex
