An [XCompose](https://linux.die.net/man/3/xcompose) file for [Agda's Unicode input](https://agda.readthedocs.io/en/latest/tools/emacs-mode.html#unicode-input).

```shell-session
$ nix build github:ncfavier/agda-compose#agda-compose -o ~/.XCompose
```

Every input sequence is prefixed with <kbd>Compose</kbd><kbd>\\</kbd>.

This is generated from [agda-symbols](https://github.com/4e554c4c/agda-symbols) using jq and json2compose (see below).

## json2compose

A small Rust program that converts a JSON object to a Compose file.
The input JSON is read on standard input and has two fields:

- `keysyms` defines custom character-to-keysym mappings, as an extension of the
  standard mapping defined by `utf32_to_keysym`. Use non-typable characters to avoid collisions.
- `entries` maps input strings (sequences of characters interpreted as keysyms via
  the previous field and `utf32_to_keysym`) to output strings.

**Example**:

```shell-session
$ nix run github:ncfavier/agda-compose#json2compose <<'EOF'
{
  "keysyms": {
    "⋆": "Multi_key",
    "→": "Right"
  },
  "entries": {
    "⋆→": "→",
    "⋆==": "≡",
    "⋆shrug": "¯\\_(ツ)_/¯"
  }
}
EOF
<Multi_key> <equal> <equal> : "≡"
<Multi_key> <s> <h> <r> <u> <g> : "¯\\_(ツ)_/¯"
<Multi_key> <Right> : "→"
```
