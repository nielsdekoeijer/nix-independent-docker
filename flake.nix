{
  description = "Example development environment built by streaming an image";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    
    developmentEnvironment = pkgs.dockerTools.streamLayeredImage {
      name = "development-environment";
      tag = "latest";
      
      contents = with pkgs; [ 
        bashInteractive 
        coreutils 
        git 

        gcc15
      ];
      
      config = {
        Cmd = [ "/bin/bash" ];
      };
    };

  in {
    apps.${system}.default = {
      type = "app";
      program = "${developmentEnvironment}";
    };
  };
}
