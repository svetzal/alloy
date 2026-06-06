//! Output rendering: every command speaks either the machine `{success, data,
//! error}` envelope (under `--json`) or a human-readable rendering.

use serde::Serialize;

/// Prints a success result.
///
/// Under `json`, emits `{"success":true,"data":<data>,"error":null}`. Otherwise
/// prints `human` as-is. `data` is serialized only in JSON mode, so the human
/// path never pays for it.
pub fn emit_success<T: Serialize>(json: bool, data: &T, human: impl FnOnce() -> String) {
    if json {
        let envelope = serde_json::json!({
            "success": true,
            "data": data,
            "error": null,
        });
        println!(
            "{}",
            serde_json::to_string_pretty(&envelope).unwrap_or_else(|_| "{}".to_string())
        );
    } else {
        println!("{}", human());
    }
}

/// Prints a failure to stderr (human) or stdout (JSON envelope).
pub fn emit_error(json: bool, message: &str) {
    if json {
        let envelope = serde_json::json!({
            "success": false,
            "data": null,
            "error": { "message": message },
        });
        println!(
            "{}",
            serde_json::to_string_pretty(&envelope).unwrap_or_else(|_| "{}".to_string())
        );
    } else {
        eprintln!("Error: {message}");
    }
}

/// Renders an optional field for human output, showing `—` when absent.
pub fn or_dash(value: &Option<String>) -> &str {
    match value {
        Some(s) if !s.is_empty() => s,
        _ => "—",
    }
}
