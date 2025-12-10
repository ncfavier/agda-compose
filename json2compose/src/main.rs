use std::collections::*;
use std::io;
use xkbcommon::xkb;

fn char_to_keysym(c: char) -> String {
  xkb::keysym_get_name(xkb::utf32_to_keysym(u32::from(c)))
}

fn main() -> serde_json::Result<()> {
  let entries: BTreeMap<String, String> = serde_json::from_reader(io::stdin())?;

  for (key, value) in entries {
    let sequence: String = key
      .chars()
      .map(|c| format!("<{}>", char_to_keysym(c)))
      .collect::<Vec<String>>()
      .join(" ");

    // assumes Compose strings are close enough to JSON strings
    let output = serde_json::to_string(&value)?;

    println!("<Multi_key> {} : {}", sequence, output);
  }
  Ok(())
}
