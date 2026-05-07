{
  description = "Example development environment with Docker stream and Nix shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    
    sharedPackages = with pkgs; [ 
      bashInteractive 
      coreutils 
      git 
      gcc15
    ];
    
    developmentEnvironment = pkgs.dockerTools.streamLayeredImage {
      name = "development-environment";
      tag = "latest";
      
      contents = sharedPackages;
      
      config = {
        Cmd = [ "/bin/bash" ];
      };
    };

  in {
    # Run the stream output: `nix run`
    apps.${system}.default = {
      type = "app";
      program = "${developmentEnvironment}";
    };

    # Run the local shell: `nix develop`
    devShells.${system}.default = pkgs.mkShell {
      packages = sharedPackages;
    };
  };
}
