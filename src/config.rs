use anyhow::{anyhow, Result};
use std::fs;
use std::path::{Path, PathBuf};

const ADR_DIR_FILE: &str = ".adr-dir";
const DEFAULT_ADR_DIR: &str = "doc/adr";

/// Get the ADR directory path
/// First checks for .adr-dir file, then falls back to default
pub fn get_adr_dir() -> Result<PathBuf> {
    // Check if .adr-dir file exists
    if Path::new(ADR_DIR_FILE).exists() {
        let content = fs::read_to_string(ADR_DIR_FILE)?;
        let dir = content.trim();
        if !dir.is_empty() {
            return Ok(PathBuf::from(dir));
        }
    }

    // Fall back to default directory
    Ok(PathBuf::from(DEFAULT_ADR_DIR))
}

/// Set the ADR directory by writing to .adr-dir file
pub fn set_adr_dir(dir: &str) -> Result<()> {
    fs::write(ADR_DIR_FILE, dir)?;
    Ok(())
}

/// Ensure ADR directory exists
pub fn ensure_adr_dir(dir: &Path) -> Result<()> {
    if !dir.exists() {
        fs::create_dir_all(dir)
            .map_err(|e| anyhow!("Failed to create ADR directory '{}': {}", dir.display(), e))?;
    }
    Ok(())
}

/// Check if ADR directory exists and is properly initialized
pub fn is_initialized() -> bool {
    match get_adr_dir() {
        Ok(dir) => dir.exists(),
        Err(_) => false,
    }
}
