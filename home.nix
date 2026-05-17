{ pkgs, ... }:

{
  home.username = "hogan";
  home.homeDirectory = "/home/hogan";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    bat
    codex
    delta
    direnv
    eza
    fd
    fzf
    gcc
    gh
    gnumake
    jq
    just
    kitty
    lazygit
    mise
    neovim
    opencode
    python3
    ripgrep
    rustup
    starship
    tldr
    tree
    unzip
    wget
    yq-go
    zip
    zellij
    zoxide
  ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  xdg.configFile."zellij/config.kdl" = {
    force = true;
    text = ''
      default_shell "zsh"
    '';
  };

  home.file.".config/kitty/kitty.conf".text = ''
    font_family      Hack Nerd Font Mono
    font_size        16
    background_opacity 0.95
    enable_audio_bell no
    confirm_os_window_close 0
    shell zsh

    map ctrl+c copy_to_clipboard
    map ctrl+v paste_from_clipboard
    map shift+insert paste_from_selection
  '';

  home.file.".config/nvim".source = ./nvim;

  home.file.".config/mise/config.toml".text = ''
    [tools]
    erlang = "latest"
    rebar = "latest"
    elixir = "latest"
    node = "lts"
  '';

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.highlight = "fg=#808080";

    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      cat = "bat";
      ls = "eza";
      ll = "eza -la";
      lt = "eza --tree";
      z = "zellij";

      gs = "git status";
      gl = "git log --oneline --graph --decorate";
      gd = "git diff";
      gds = "git diff --staged";

      hs = "nix run home-manager/release-25.11 -- switch --flake ~/dev/nix-dev-setup";
      hu = "(cd ~/dev/nix-dev-setup && nix flake update) && nix run home-manager/release-25.11 -- switch --flake ~/dev/nix-dev-setup";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };

    initContent = ''
      bindkey -v

      if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
      fi

      if [ -f "$HOME/.config/env/local.sh" ]; then
        source "$HOME/.config/env/local.sh"
      fi

      eval "$(mise activate zsh)"
      eval "$(direnv hook zsh)"
      eval "$(zoxide init zsh)"
      eval "$(starship init zsh)"
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user = {
        name = "Josh Hogan";
        email = "josh.hogan@me.com";
      };
      push.autoSetupRemote = true;
      pull.rebase = true;
      diff = {
        renames = "copies";
        algorithm = "histogram";
        colorMoved = "default";
      };
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
      };
      merge.conflictstyle = "diff3";
      column.ui = "auto";
      branch.sort = "-committerdate";
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        cp = "cherry-pick";
        lg = "log --oneline --graph --decorate";
        lga = "log --oneline --graph --decorate --all";
        ll = "log --stat --format=medium";
        undo = "reset --soft HEAD~1";
        outgoing = "log @{u}..HEAD";
        incoming = "log HEAD..@{u}";
      };
    };
    ignores = [
      ".direnv/"
      "result"
      "result-*"
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      git_branch = {
        format = "\\[[$symbol$branch(:$remote_branch)]($style)\\] ";
        symbol = " ";
      };
      git_status = {
        format = "(\\[[$all_status$ahead_behind]($style)\\]) ";
      };
      golang.disabled = true;
      rust.disabled = true;
      aws.disabled = true;
      gcloud.disabled = true;
      package.disabled = true;
      elixir = {
        disabled = false;
        format = "\\[[$symbol$version]($style)\\] ";
      };
      nodejs = {
        disabled = false;
        format = "\\[[$symbol$version]($style)\\] ";
      };
      cmd_duration = {
        disabled = true;
        min_time = 2000;
        format = "\\[[$duration]($style)\\] ";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;
}
