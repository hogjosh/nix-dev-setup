{
  lib,
  pkgs,
  devenvPackage,
  ...
}:

let
  # Moshi distributes a standalone Linux binary rather than a Nixpkgs package.
  # Pin its release artifact and checksum so Home Manager installs it reproducibly.
  moshiHook = pkgs.stdenvNoCC.mkDerivation {
    pname = "moshi-hook";
    version = "0.2.80";

    src = pkgs.fetchurl {
      url = "https://cdn.getmoshi.app/hook/v0.2.80/moshi-hook_Linux_x86_64.tar.gz";
      hash = "sha256-eeyDmYKT1G5cuFIvB3FOEKBrMeK9VhMc34RtITVL8aE=";
    };

    sourceRoot = ".";
    unpackPhase = "tar -xzf $src";
    installPhase = ''
      install -Dm755 moshi-hook "$out/bin/moshi-hook"
      ln -s moshi-hook "$out/bin/moshi"
    '';
  };
in
{
  imports = [ ./plasma.nix ];

  home.username = "hogan";
  home.homeDirectory = "/home/hogan";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    ast-grep
    bat
    btop
    claude-code
    cmake
    delta
    devenvPackage
    difftastic
    direnv
    discord
    duf
    dust
    eza
    fd
    ffmpeg
    fzf
    gcc
    gh
    gnumake
    (nerd-fonts.hack)
    hyperfine
    jq
    just
    kitty
    lazygit
    mise
    mosh
    moshiHook
    neovim
    nixd
    nixfmt
    nodejs_24
    opencode
    pkg-config
    python3
    python3Packages.huggingface-hub
    ripgrep
    rustup
    starship
    statix
    stylua
    tldr
    tmux
    tree
    unzip
    wget
    yq-go
    zellij
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    LESS = "-R --no-init --quit-if-one-screen";
  };

  # Retain a month of rollback generations, then reclaim unreferenced store
  # paths weekly. This user-level timer never manages NixOS configuration.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  xdg.configFile."zellij/config.kdl" = {
    force = true;
    source = ./zellij/config.kdl;
  };

  home.file.".config/kitty/kitty.conf".source = ./kitty/kitty.conf;

  home.file.".config/nvim".source = ./nvim;

  # Herdr writes onboarding, in-app settings, and config migrations. Seed a
  # normal file once, then leave the mutable live config entirely to Herdr.
  home.activation.seedHerdrConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    herdr_config="$HOME/.config/herdr/config.toml"

    if [ ! -e "$herdr_config" ]; then
      ${pkgs.coreutils}/bin/install -Dm644 \
        "${./herdr/config.toml}" \
        "$herdr_config"
    fi
  '';

  # KRDP shares the current Plasma session over RDP. It uses the existing
  # Linux account for authentication; its TLS private key stays local.
  xdg.configFile."krdpserverrc".text = ''
    [General]
    Certificate=/home/hogan/.local/share/krdpserver/krdp.crt
    CertificateKey=/home/hogan/.local/share/krdpserver/krdp.key
    SystemUserEnabled=true
  '';

  # KRDP 6.5 identifies itself with this hyphenated ID, while Nixpkgs ships
  # only the non-hyphenated desktop entry. Plasma's portal needs both to agree.
  xdg.dataFile."applications/org.kde.krdp-server.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=KRDP
    Exec=/run/current-system/sw/bin/krdpserver
    Icon=krfb
    Terminal=false
    NoDisplay=true
    X-KDE-Wayland-Interfaces=org_kde_kwin_fake_input,zkde_screencast_unstable_v1
  '';

  home.activation.krdpCertificate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    certificate_directory="$HOME/.local/share/krdpserver"
    certificate="$certificate_directory/krdp.crt"
    certificate_key="$certificate_directory/krdp.key"

    if [ ! -s "$certificate" ] || [ ! -s "$certificate_key" ]; then
      mkdir -p "$certificate_directory"
      umask 077
      ${pkgs.openssl}/bin/openssl req -nodes -new -x509 \
        -keyout "$certificate_key" \
        -out "$certificate" \
        -days 3650 \
        -subj '/CN=nixos'
    fi
  '';

  systemd.user.services.krdpserver = {
    Unit = {
      Description = "KDE Plasma RDP server";
      After = [
        "plasma-xdg-desktop-portal-kde.service"
        "plasma-core.target"
      ];
    };
    Service = {
      # Pre-authorize the server to share this user session through Plasma's
      # Remote Desktop portal before every service start.
      ExecStartPre = "${pkgs.systemd}/bin/busctl --user call org.freedesktop.impl.portal.PermissionStore /org/freedesktop/impl/portal/PermissionStore org.freedesktop.impl.portal.PermissionStore SetPermission sbssas kde-authorized true remote-desktop org.kde.krdp-server 1 yes";
      ExecStart = "/run/current-system/sw/bin/krdpserver";
      Restart = "on-abnormal";
    };
    Install.WantedBy = [ "plasma-workspace.target" ];
  };

  # Moshi Hook connects local coding agents to the Moshi iOS app. With user
  # lingering enabled, this user service also runs before graphical login.
  systemd.user.services.moshi-hook = {
    Unit = {
      Description = "Moshi agent hook daemon";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      # Pairing creates this local, secret-bearing file. Do not run an
      # unpaired daemon in a restart loop before setup is complete.
      ConditionPathExists = "%h/.config/moshi/config.toml";
    };
    Service = {
      ExecStart = "${moshiHook}/bin/moshi-hook serve";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Keep Codex on the npm release stream instead of the version pinned in
  # nixpkgs. Mise supplies the shim while Node.js is provided by home.packages.
  home.file.".config/mise/config.toml".text = ''
    [tools]
    "npm:@openai/codex" = "latest"
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

      hs = "home-manager switch --flake ~/dev/nix-dev-setup";
      hu = "(cd ~/dev/nix-dev-setup && nix flake update) && home-manager switch --flake ~/dev/nix-dev-setup";

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
        alias-main = "!git symbolic-ref refs/heads/main refs/heads/master && git symbolic-ref refs/remotes/origin/main refs/remotes/origin/master";
        difft = "!GIT_EXTERNAL_DIFF=difft git diff";
      };
    };
    signing.format = null;
    ignores = [
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      ".idea/"
      "*.swp"
      "*.swo"
      "**/.claude/settings.local.json"
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
      nix_shell = {
        symbol = "❄️ ";
        impure_msg = "";
        format = "via [$symbol$state]($style)";
      };
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
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config.global = {
      hide_env_diff = true;
      warn_timeout = "30s";
    };
  };

  programs.home-manager.enable = true;
}
