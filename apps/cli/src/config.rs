//! Per-project CLI configuration, loaded from a single `.alloy_env` file.
//!
//! Mirroring the sibling product's `.et_env` convention: a `KEY=VALUE` file read
//! from the current working directory **only** (no directory-tree walk), holding
//! the backend host and a per-project bearer token. It is gitignored because it
//! holds a secret.

use std::collections::HashMap;
use std::path::Path;

use anyhow::{anyhow, Context, Result};

/// The config file name read from the current working directory.
pub const ENV_FILE: &str = ".alloy_env";

/// The environment key naming the backend base URL.
pub const HOST_KEY: &str = "ALLOY_API_HOST";

/// The environment key naming the per-project bearer token.
pub const TOKEN_KEY: &str = "ALLOY_API_TOKEN";

/// A resolved CLI configuration: where the backend is and how to authenticate.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Config {
    /// Backend base URL with any trailing slash removed.
    pub host: String,
    /// Per-project bearer token.
    pub token: String,
}

impl Config {
    /// Loads configuration from `.alloy_env` in the current working directory.
    ///
    /// Returns a friendly, actionable error when the file is missing or when
    /// either required key is absent.
    pub fn load() -> Result<Config> {
        let cwd = std::env::current_dir().context("could not determine current directory")?;
        Config::load_from_dir(&cwd)
    }

    /// Loads configuration from `.alloy_env` in `dir` (no parent traversal).
    pub fn load_from_dir(dir: &Path) -> Result<Config> {
        let path = dir.join(ENV_FILE);

        let contents = std::fs::read_to_string(&path).map_err(|_| missing_file_error(&path))?;

        Config::from_env_string(&contents)
    }

    /// Parses a `Config` from the raw contents of an `.alloy_env` file.
    pub fn from_env_string(contents: &str) -> Result<Config> {
        let map = parse_env(contents);

        let host = map
            .get(HOST_KEY)
            .filter(|v| !v.is_empty())
            .ok_or_else(|| missing_key_error(HOST_KEY))?;
        let token = map
            .get(TOKEN_KEY)
            .filter(|v| !v.is_empty())
            .ok_or_else(|| missing_key_error(TOKEN_KEY))?;

        Ok(Config {
            host: host.trim_end_matches('/').to_string(),
            token: token.clone(),
        })
    }
}

/// Parses `KEY=VALUE` lines into a map. Blank lines and `#` comments are
/// skipped; surrounding whitespace on keys and values is trimmed; lines without
/// `=` are ignored. The first `=` separates key from value, so values may
/// themselves contain `=`.
fn parse_env(contents: &str) -> HashMap<String, String> {
    let mut map = HashMap::new();

    for line in contents.lines() {
        let trimmed = line.trim();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            continue;
        }

        let Some((key, value)) = trimmed.split_once('=') else {
            continue;
        };

        map.insert(key.trim().to_string(), value.trim().to_string());
    }

    map
}

fn missing_file_error(path: &Path) -> anyhow::Error {
    anyhow!(
        "No {file} found in this directory.\n\n\
         Create {file} in your project root with:\n\n\
         \x20 {host}=https://alloy.example.com\n\
         \x20 {token}=alloy_your-token-here\n\n\
         Mint a token in the Alloy web console (Projects → a project → Generate token).\n\
         Looked for: {path}",
        file = ENV_FILE,
        host = HOST_KEY,
        token = TOKEN_KEY,
        path = path.display(),
    )
}

fn missing_key_error(key: &str) -> anyhow::Error {
    anyhow!(
        "{file} is missing {key}.\n\n\
         It must define both {host} and {token}.",
        file = ENV_FILE,
        key = key,
        host = HOST_KEY,
        token = TOKEN_KEY,
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_host_and_token() {
        let cfg = Config::from_env_string(
            "ALLOY_API_HOST=https://alloy.example.com\nALLOY_API_TOKEN=alloy_secret\n",
        )
        .unwrap();

        assert_eq!(cfg.host, "https://alloy.example.com");
        assert_eq!(cfg.token, "alloy_secret");
    }

    #[test]
    fn strips_trailing_slash_from_host() {
        let cfg =
            Config::from_env_string("ALLOY_API_HOST=https://alloy.example.com/\nALLOY_API_TOKEN=t")
                .unwrap();
        assert_eq!(cfg.host, "https://alloy.example.com");
    }

    #[test]
    fn skips_comments_and_blanks_and_trims() {
        let cfg = Config::from_env_string(
            "# a comment\n\n  ALLOY_API_HOST = https://h  \n\tALLOY_API_TOKEN=\tt\t\n",
        )
        .unwrap();
        assert_eq!(cfg.host, "https://h");
        assert_eq!(cfg.token, "t");
    }

    #[test]
    fn value_may_contain_equals() {
        let cfg =
            Config::from_env_string("ALLOY_API_HOST=https://h\nALLOY_API_TOKEN=ab=cd=ef").unwrap();
        assert_eq!(cfg.token, "ab=cd=ef");
    }

    #[test]
    fn ignores_lines_without_equals_and_unknown_keys() {
        let cfg = Config::from_env_string(
            "garbage line\nOTHER_KEY=ignored\nALLOY_API_HOST=https://h\nALLOY_API_TOKEN=t",
        )
        .unwrap();
        assert_eq!(cfg.host, "https://h");
    }

    #[test]
    fn errors_when_host_missing() {
        let err = Config::from_env_string("ALLOY_API_TOKEN=t").unwrap_err();
        assert!(err.to_string().contains("ALLOY_API_HOST"));
    }

    #[test]
    fn errors_when_token_missing() {
        let err = Config::from_env_string("ALLOY_API_HOST=https://h").unwrap_err();
        assert!(err.to_string().contains("ALLOY_API_TOKEN"));
    }

    #[test]
    fn errors_when_value_is_blank() {
        let err = Config::from_env_string("ALLOY_API_HOST=\nALLOY_API_TOKEN=t").unwrap_err();
        assert!(err.to_string().contains("ALLOY_API_HOST"));
    }

    #[test]
    fn missing_file_error_is_actionable() {
        let dir = std::env::temp_dir().join("alloy_cli_nonexistent_dir_xyz");
        let err = Config::load_from_dir(&dir).unwrap_err();
        let msg = err.to_string();
        assert!(msg.contains(".alloy_env"));
        assert!(msg.contains("ALLOY_API_HOST"));
    }
}
