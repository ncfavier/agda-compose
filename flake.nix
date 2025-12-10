{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    agda-symbols = {
      url = "github:4e554c4c/agda-symbols";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, naersk, agda-symbols }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib;
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        packages = {
          default = self.packages.${system}.agda-compose;

          json2compose = naersk-lib.buildPackage {
            src = ./json2compose;
            nativeBuildInputs = with pkgs; [ libxkbcommon ];
          };

          agda-compose = let
            script = ''
              with_entries((.key |= "\\" + .) | (.value |= first(.. | strings)))
            '';
          in pkgs.runCommand "agda.compose" {
            nativeBuildInputs = with pkgs; [ jq self.packages.${system}.json2compose ];
          } ''
            jq ${lib.escapeShellArg script} ${agda-symbols}/symbols.json | json2compose > "$out"
          '';

          agda-gboard = let
            script = ''
              "# Gboard Dictionary version:2",
              "# Gboard Dictionary format:shortcut\tword\tlanguage_tag\tpos_tag",
              ( to_entries[]
              | select(.key | test("^\\w+$"))
              | "\(.key)\t\(.value | .. | strings)\t\t")
            '';
          in pkgs.runCommand "agda-gboard.txt" {
            nativeBuildInputs = with pkgs; [ jq ];
          } ''
            jq -r ${lib.escapeShellArg script} ${agda-symbols}/symbols.json > "$out"
          '';
        };

        devShell = with pkgs; mkShell {
          inputsFrom = [ self.packages.${system}.json2compose ];
          packages = [ cargo rustfmt rustPackages.clippy ];
        };
      }
    );
}
