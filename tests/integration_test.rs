#![cfg(not(coverage))]

use std::fs;
use std::path::Path;
use std::process::Command;
use tempfile::tempdir;

fn get_binary_path() -> String {
    env!("CARGO_BIN_EXE_adr-tools-alt").to_string()
}

fn run_in_temp_dir<F>(test: F)
where
    F: FnOnce(),
{
    let temp_dir = tempdir().unwrap();
    let temp_path = temp_dir.path();

    let original_dir = std::env::current_dir().unwrap();
    std::env::set_current_dir(temp_path).unwrap();

    test();

    std::env::set_current_dir(original_dir).unwrap();
}

#[test]
fn test_help_command() {
    let output = Command::new(get_binary_path())
        .arg("--help")
        .output()
        .expect("Failed to execute command");

    assert!(output.status.success());
    let stdout = String::from_utf8(output.stdout).unwrap();
    assert!(stdout.contains("Architecture Decision Records tools"));
    assert!(stdout.contains("init"));
    assert!(stdout.contains("new"));
    assert!(stdout.contains("list"));
}

#[test]
fn test_version_command() {
    let output = Command::new(get_binary_path())
        .arg("--version")
        .output()
        .expect("Failed to execute command");

    assert!(output.status.success());
    let stdout = String::from_utf8(output.stdout).unwrap();
    assert!(stdout.contains("adr"));
    assert!(stdout.contains("0.1.0"));
}

#[test]
fn test_init_and_workflow() {
    run_in_temp_dir(|| {
        // Test init command
        let output = Command::new(get_binary_path())
            .arg("init")
            .output()
            .expect("Failed to execute init");

        if !output.status.success() {
            let stderr = String::from_utf8(output.stderr).unwrap();
            panic!("Init command failed: {}", stderr);
        }
        assert!(Path::new("doc/adr").exists());
        assert!(Path::new("doc/adr/0001-record-architecture-decisions.md").exists());

        // Test new command
        let output = Command::new(get_binary_path())
            .args(["new", "Use Rust for performance"])
            .output()
            .expect("Failed to execute new");

        if !output.status.success() {
            let stderr = String::from_utf8(output.stderr).unwrap();
            panic!("New command failed: {}", stderr);
        }
        assert!(Path::new("doc/adr/0002-use-rust-for-performance.md").exists());

        // Test list command
        let output = Command::new(get_binary_path())
            .arg("list")
            .output()
            .expect("Failed to execute list");

        assert!(output.status.success());
        let stdout = String::from_utf8(output.stdout).unwrap();
        assert!(stdout.contains("0001-record-architecture-decisions.md"));
        assert!(stdout.contains("0002-use-rust-for-performance.md"));

        // Test generate toc command
        let output = Command::new(get_binary_path())
            .args(["generate", "toc"])
            .output()
            .expect("Failed to execute generate toc");

        if !output.status.success() {
            let stderr = String::from_utf8(output.stderr).unwrap();
            panic!("Generate toc command failed: {}", stderr);
        }
        let stdout = String::from_utf8(output.stdout).unwrap();
        assert!(stdout.contains("# Architecture Decision Records"));
        assert!(stdout.contains("Record architecture decisions"));
        assert!(stdout.contains("Use Rust for performance"));
    });
}

#[test]
fn test_template_includes_alternatives_section() {
    run_in_temp_dir(|| {
        // Test init command
        let output = Command::new(get_binary_path())
            .arg("init")
            .output()
            .expect("Failed to execute init");

        assert!(output.status.success());
        
        // Read the initial ADR file
        let init_adr_content = fs::read_to_string("doc/adr/0001-record-architecture-decisions.md")
            .expect("Failed to read initial ADR file");
            
        // Check that the initial ADR contains the Alternatives section
        assert!(init_adr_content.contains("## Alternatives"));
        assert!(init_adr_content.contains("Other options considered:"));
        
        // Create a new ADR
        let output = Command::new(get_binary_path())
            .args(["new", "Test new template structure"])
            .output()
            .expect("Failed to execute new");

        assert!(output.status.success());
        
        // Read the new ADR file
        let new_adr_content = fs::read_to_string("doc/adr/0002-test-new-template-structure.md")
            .expect("Failed to read new ADR file");
            
        // Check that the new ADR contains the Alternatives section
        assert!(new_adr_content.contains("## Alternatives"));
        assert!(new_adr_content.contains("What other options were considered"));
        
        // Verify the order of sections (Alternatives should come after Decision)
        let decision_pos = new_adr_content.find("## Decision").unwrap();
        let alternatives_pos = new_adr_content.find("## Alternatives").unwrap();
        let consequences_pos = new_adr_content.find("## Consequences").unwrap();
        
        assert!(decision_pos < alternatives_pos);
        assert!(alternatives_pos < consequences_pos);
    });
}

#[test]
fn test_supersede_functionality() {
    run_in_temp_dir(|| {
        // Initialize and create first ADR
        Command::new(get_binary_path())
            .arg("init")
            .output()
            .expect("Failed to execute init");

        Command::new(get_binary_path())
            .args(["new", "Use Python for scripting"])
            .output()
            .expect("Failed to create first ADR");

        // Supersede the second ADR
        let output = Command::new(get_binary_path())
            .args(["new", "Use Rust for scripting", "--supersede", "2"])
            .output()
            .expect("Failed to supersede ADR");

        if !output.status.success() {
            let stderr = String::from_utf8(output.stderr).unwrap();
            panic!("Supersede command failed: {}", stderr);
        }

        // Check that the superseded ADR was updated
        let superseded_content =
            fs::read_to_string("doc/adr/0002-use-python-for-scripting.md").unwrap();
        assert!(superseded_content.contains("Superseded by ADR-0003"));

        // Check that new ADR was created
        assert!(Path::new("doc/adr/0003-use-rust-for-scripting.md").exists());
    });
}
