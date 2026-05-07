{
  description = "Minimal Docker image via stream with Dev Goodies";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    
    # 1. DEFINE YOUR GOODIES:
    # We use writeTextDir to create a file exactly at /root/.bashrc 
    # inside the container.
    bashConfig = pkgs.writeTextDir "root/.bashrc" ''
      # Enable colors
      export TERM=xterm-256color
      
      # A clean, colorful custom prompt
      export PS1="\[\e[1;32m\][nix-dev]\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \$ "
      
      # Useful aliases
      alias ll='ls -lah --color=auto'
      alias ls='ls --color=auto'
      alias gs='git status'
      
      # Welcome banner
      echo -e "\n\e[1;36m🚀 Welcome to your Nix Dev Environment!\e[0m"
      echo -e "Available tools:"
      echo -e "  🐍 Python: $(python3 --version)"
      echo -e "  📦 Node:   $(node --version)"
      echo -e "  🐙 Git:    $(git --version)\n"
    '';

    # 2. Extract the image definition into a variable
    myImage = pkgs.dockerTools.streamLayeredImage {
      name = "my-dev-env";
      tag = "latest";
      
      # 3. Add 'bashConfig' to the contents so it gets included in the image
      contents = with pkgs; [ 
        bashInteractive 
        coreutils 
        python3 
        nodejs 
        git 
        bashConfig 
      ];
      
      config = {
        Cmd = [ "/bin/bash" ];
        
        # 4. ENVIRONMENT SETUP:
        # - Set HOME so bash knows where to find our custom .bashrc
        # - Set TERM so the terminal knows it can render our colors
        Env = [ 
          "HOME=/root" 
          "TERM=xterm-256color" 
        ];
        
        # Optional but highly recommended: Drop the user directly into /app
        # since your build script mounts the local directory there!
        WorkingDir = "/app"; 
      };
    };

  in {
    # Keep the package definition for 'nix build'
    packages.${system}.default = myImage;

    # Tell 'nix run' exactly what file to execute
    apps.${system}.default = {
      type = "app";
      program = "${myImage}";
    };
  };
}
