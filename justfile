default:
    @just --list

switch:
    nix run --inputs-from . home-manager -- switch --flake .

switch-abs:
    /nix/var/nix/profiles/default/bin/nix run --inputs-from . home-manager -- switch --flake .

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
    mosh --version
    newt --version
    ffmpeg -version
    hf --help
    gh --version
    just --version
    tldr --version
    tree --version
    yq --version

# Update only Codex; retain older versions for sessions that are still running.
update-codex:
    mise upgrade --no-prune npm:@openai/codex
    mise exec -- codex --version

# Update every flake input, then apply the resulting Home Manager profile.
update:
    nix flake update
    just switch

# Update one named flake input, then apply the resulting Home Manager profile.
# Usage: just update-input nixpkgs
update-input input:
    nix flake update {{ input }}
    just switch
