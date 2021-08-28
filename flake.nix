{
  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    naersk = {
      url = "github:nmattia/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs, flake-utils, naersk, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        naersk-lib = naersk.lib."${system}";
        pkgs = nixpkgs.legacyPackages."${system}";
        package-name = "hello-world";
      in
      {
        devShell = nixpkgs.legacyPackages.${system}.mkShell {
          nativeBuildInputs = with pkgs; [ cargo clippy rustc rustfmt ];
        };
        packages.${package-name} = naersk-lib.buildPackage {
          pname = package-name;
          root = ./.;
        };
        defaultPackage = self.packages.${system}.${package-name};
        apps.${package-name} = flake-utils.lib.mkApp {
          drv = self.packages.${system}.${package-name};
        };
        defaultApp = self.apps.${system}.${package-name};
      }
    );
}
