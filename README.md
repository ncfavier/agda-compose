An [XCompose](https://linux.die.net/man/3/xcompose) file for [Agda's Unicode input](https://agda.readthedocs.io/en/latest/tools/emacs-mode.html#unicode-input).

```shell-session
$ nix build github:ncfavier/agda-compose#agda-compose -o ~/.XCompose
```

Every input sequence starts with <kbd>Compose</kbd><kbd>\\</kbd>.

This is generated from [agda-symbols](https://github.com/4e554c4c/agda-symbols) using jq and a small Rust program that converts a JSON object to a Compose file:

```shell-session
$ nix run github:ncfavier/agda-compose#json2compose <<'EOF'
{
  "→": "→",
  "==": "≡",
  "shrug": "¯\\_(ツ)_/¯"
}
EOF
<Multi_key> <equal> <equal> : "≡"
<Multi_key> <s> <h> <r> <u> <g> : "¯\\_(ツ)_/¯"
<Multi_key> <rightarrow> : "→"
```
