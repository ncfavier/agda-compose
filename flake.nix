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

          # A simple Rust program for converting JSON to a Compose file
          json2compose = naersk-lib.buildPackage {
            src = ./json2compose;
            nativeBuildInputs = with pkgs; [ libxkbcommon ];
          };

          # A Compose file for Agda's Unicode input
          agda-compose = let
            script = ''
              with_entries((.key |= "\\" + .) | (.value |= first(.. | strings)))
            '';
          in pkgs.runCommand "agda.compose" {
            nativeBuildInputs = with pkgs; [ jq self.packages.${system}.json2compose ];
          } ''
            jq ${lib.escapeShellArg script} ${agda-symbols}/symbols.json | json2compose > "$out"
          '';

          # A Gboard dictionary for Agda's Unicode input
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

          # A command for adding Agda Unicode input sequences to a FUTO Keyboard user dictionary (as a JSON file)
          agda-futo-json = let
            script = ''
              . + ($symbols[0] | to_entries | map(select(.key | test("^\\w+$")) | {
                word: .value | .. | strings, shortcut: .key, frequency: 250, locale: null, appId: 0
              })) |
              unique_by({word, shortcut})
            '';
          in pkgs.writeShellScriptBin "agda-futo-json" ''
            userDict=$1
            tmp=$(mktemp)
            jq --slurpfile symbols ${agda-symbols}/symbols.json ${lib.escapeShellArg script} "$userDict" > "$tmp" &&
              mv -f "$tmp" "$userDict"
          '';

          # Same as agda-futo-json, but operates on a settings backup file
          # (This can be exported and imported from the Miscellaneous menu)
          agda-futo = pkgs.writeShellScriptBin "agda-futo" ''
            settings=$1
            tmp=$(mktemp -d)
            unzip "$settings" userdictionary.json -d "$tmp"
            ${lib.getExe self.packages.${system}.agda-futo-json} "$tmp/userdictionary.json"
            zip -j --update "$settings" "$tmp/userdictionary.json"
          '';
        };

        devShell = with pkgs; mkShell {
          inputsFrom = [ self.packages.${system}.json2compose ];
          packages = [ cargo rustfmt rustPackages.clippy ];
        };
      }
    );
}
