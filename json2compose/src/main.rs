use std::collections::*;
use std::io;
use xkbcommon::xkb;
use serde::Deserialize;

#[derive(Deserialize)]
struct Compose {
  keysyms: BTreeMap<String, String>,
  entries: BTreeMap<String, String>,
}

impl Compose {
  fn char_to_keysym(&self, c: char) -> String {
    if let Some(sym) = self.keysyms.get(&c.to_string()) {
      sym.clone()
    } else {
      xkb::keysym_get_name(xkb::utf32_to_keysym(u32::from(c)))
    }
  }
}

fn main() -> serde_json::Result<()> {
  let compose: Compose = serde_json::from_reader(io::stdin())?;

  for (key, value) in &compose.entries {
    let sequence: String = key
      .chars()
      .map(|c| format!("<{}>", compose.char_to_keysym(c)))
      .collect::<Vec<String>>()
      .join(" ");

    // assumes Compose string literals are close enough to JSON string literals
    let output = serde_json::to_string(&value)?;

    println!("{} : {}", sequence, output);
  }
  Ok(())
}
