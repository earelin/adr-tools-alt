use anyhow::{anyhow, Result};
use regex::Regex;
use std::fs;
use std::path::Path;
use std::process::Command;

use crate::config;
use crate::template;

/// Initialize ADR directory
pub fn init(directory: Option<&str>) -> Result<()> {
    let adr_dir = match directory {
        Some(dir) => {
            // If directory is specified, create .adr-dir file
            config::set_adr_dir(dir)?;
            dir.to_string()
        }
        None => config::get_adr_dir()?.to_string_lossy().to_string(),
    };

    let adr_path = Path::new(&adr_dir);
    config::ensure_adr_dir(adr_path)?;

    // Create initial ADR
    let initial_adr = template::fill_template(
        template::INIT_TEMPLATE,
        1,
        "Record architecture decisions",
        "Accepted",
    );

    let filename = template::generate_filename(1, "Record architecture decisions");
    let filepath = adr_path.join(filename);

    fs::write(&filepath, initial_adr)?;

    println!("ADR directory initialized in: {}", adr_dir);
    println!("Created initial ADR: {}", filepath.display());

    Ok(())
}

/// Create a new ADR
pub fn new(title: &str, supersede: Option<u16>) -> Result<()> {
    if !config::is_initialized() {
        return Err(anyhow!(
            "ADR directory not initialized. Run 'adr init' first."
        ));
    }

    let adr_dir = config::get_adr_dir()?;
    let next_number = get_next_number(&adr_dir)?;

    let status = "Accepted";

    let content = template::fill_template(template::DEFAULT_TEMPLATE, next_number, title, status);

    let filename = template::generate_filename(next_number, title);
    let filepath = adr_dir.join(&filename);

    fs::write(&filepath, &content)?;

    // Handle superseding previous ADR
    if let Some(superseded_number) = supersede {
        update_superseded_adr(&adr_dir, superseded_number, next_number)?;
    }

    println!("Created ADR: {}", filepath.display());

    // Open in editor if available
    if let Some(editor) = get_editor() {
        let _ = Command::new(editor).arg(&filepath).status();
    }

    Ok(())
}

/// List all ADRs
pub fn list() -> Result<()> {
    if !config::is_initialized() {
        return Err(anyhow!(
            "ADR directory not initialized. Run 'adr init' first."
        ));
    }

    let adr_dir = config::get_adr_dir()?;
    let mut adrs = Vec::new();

    for entry in fs::read_dir(&adr_dir)? {
        let entry = entry?;
        let filename = entry.file_name().to_string_lossy().to_string();

        if is_adr_file(&filename) {
            adrs.push(filename);
        }
    }

    adrs.sort();

    for adr in adrs {
        let path = adr_dir.join(&adr);
        let title = extract_title(&path)?;
        println!("{}: {}", adr, title);
    }

    Ok(())
}

/// Generate documentation (toc or graph)
pub fn generate(output_type: &str) -> Result<()> {
    match output_type {
        "toc" => generate_toc(),
        "graph" => generate_graph(),
        _ => Err(anyhow!("Unsupported output type: {}", output_type)),
    }
}

/// Generate table of contents
fn generate_toc() -> Result<()> {
    if !config::is_initialized() {
        return Err(anyhow!(
            "ADR directory not initialized. Run 'adr init' first."
        ));
    }

    println!("# Architecture Decision Records\n");

    let adr_dir = config::get_adr_dir()?;
    let mut adrs = Vec::new();

    for entry in fs::read_dir(&adr_dir)? {
        let entry = entry?;
        let filename = entry.file_name().to_string_lossy().to_string();

        if is_adr_file(&filename) {
            adrs.push(filename);
        }
    }

    adrs.sort();

    for adr in adrs {
        let path = adr_dir.join(&adr);
        let title = extract_title(&path)?;
        let adr_path = path.strip_prefix(std::env::current_dir()?).unwrap_or(&path);
        println!("* [{}]({})", title, adr_path.display());
    }

    Ok(())
}

/// Generate graph (placeholder)
fn generate_graph() -> Result<()> {
    println!("Graph generation not implemented yet");
    Ok(())
}

/// Get the next ADR number
fn get_next_number(adr_dir: &Path) -> Result<u16> {
    let mut max_number = 0u16;

    for entry in fs::read_dir(adr_dir)? {
        let entry = entry?;
        let filename = entry.file_name().to_string_lossy().to_string();

        if let Some(number) = extract_number_from_filename(&filename) {
            max_number = max_number.max(number);
        }
    }

    Ok(max_number + 1)
}

/// Extract number from ADR filename
fn extract_number_from_filename(filename: &str) -> Option<u16> {
    let re = Regex::new(r"^(\d{4})-.*\.md$").ok()?;
    let captures = re.captures(filename)?;
    captures.get(1)?.as_str().parse().ok()
}

/// Check if filename is an ADR file
fn is_adr_file(filename: &str) -> bool {
    extract_number_from_filename(filename).is_some()
}

/// Extract title from ADR file
fn extract_title(path: &Path) -> Result<String> {
    let content = fs::read_to_string(path)?;
    let lines: Vec<&str> = content.lines().collect();

    for line in lines {
        if line.starts_with("# ") {
            let title = line.trim_start_matches("# ");
            // Remove number prefix if present
            if let Some(dot_pos) = title.find(". ") {
                return Ok(title[dot_pos + 2..].to_string());
            }
            return Ok(title.to_string());
        }
    }

    Err(anyhow!("Could not extract title from {}", path.display()))
}

/// Update superseded ADR with deprecation notice
fn update_superseded_adr(adr_dir: &Path, superseded_number: u16, new_number: u16) -> Result<()> {
    for entry in fs::read_dir(adr_dir)? {
        let entry = entry?;
        let filename = entry.file_name().to_string_lossy().to_string();

        if let Some(number) = extract_number_from_filename(&filename) {
            if number == superseded_number {
                let filepath = adr_dir.join(&filename);
                let mut content = fs::read_to_string(&filepath)?;

                // Replace status with superseded notice
                content =
                    content.replace("Accepted", &format!("Superseded by ADR-{:04}", new_number));

                fs::write(&filepath, content)?;
                println!("Updated ADR-{:04} status to superseded", superseded_number);
                break;
            }
        }
    }

    Ok(())
}

/// Get editor from environment variables
fn get_editor() -> Option<String> {
    std::env::var("VISUAL")
        .or_else(|_| std::env::var("EDITOR"))
        .ok()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_extract_number_from_filename() {
        assert_eq!(extract_number_from_filename("0001-use-rust.md"), Some(1));
        assert_eq!(extract_number_from_filename("0042-api-design.md"), Some(42));
        assert_eq!(extract_number_from_filename("invalid.md"), None);
        assert_eq!(extract_number_from_filename("001-short.md"), None);
    }

    #[test]
    fn test_is_adr_file() {
        assert!(is_adr_file("0001-use-rust.md"));
        assert!(is_adr_file("0042-api-design.md"));
        assert!(!is_adr_file("README.md"));
        assert!(!is_adr_file("001-short.md"));
    }
}
