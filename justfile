default:
    @just --list

switch:
    nix run home-manager/release-25.11 -- switch --flake .

switch-abs:
    /nix/var/nix/profiles/default/bin/nix run home-manager/release-25.11 -- switch --flake .

check:
    command -v nix
    echo $SHELL
    command -v nvim
    nvim --version
    mise --version
    zellij --version
    direnv --version
    zoxide --version
    gh --version
    just --version
    tldr --version
    tree --version
    yq --version
