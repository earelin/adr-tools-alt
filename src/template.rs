use chrono::{DateTime, Local};

/// Default ADR template
pub const DEFAULT_TEMPLATE: &str = r#"# NUMBER. TITLE

Date: DATE

## Status

STATUS

## Context

The issue motivating this decision, and any context that influences or constrains the decision.

## Decision

The change that we're proposing or have agreed to implement.

## Alternatives

What other options were considered and why they were rejected.

## Consequences

What becomes easier or more difficult to do and any risks introduced by the change that will need to be mitigated.
"#;

/// Template for the initial ADR created during init
pub const INIT_TEMPLATE: &str = r#"# NUMBER. Record architecture decisions

Date: DATE

## Status

STATUS

## Context

We need to record the architectural decisions made on this project.

## Decision

We will use Architecture Decision Records, as [described by Michael Nygard](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions).

## Alternatives

Other options considered:
- No documentation of decisions
- Informal documentation in wiki or README files
- Decision logs in issue tracking systems

These were rejected because they lack the structure and discoverability that ADRs provide.

## Consequences

See Michael Nygard's article, linked above. For a lightweight ADR toolset, see Nat Pryce's [adr-tools](https://github.com/npryce/adr-tools).
"#;

/// Fill template with actual values
pub fn fill_template(template: &str, number: u16, title: &str, status: &str) -> String {
    let now: DateTime<Local> = Local::now();
    let date = now.format("%Y-%m-%d").to_string();

    template
        .replace("NUMBER", &number.to_string())
        .replace("TITLE", title)
        .replace("DATE", &date)
        .replace("STATUS", status)
}

/// Convert title to filename slug
pub fn title_to_slug(title: &str) -> String {
    title
        .to_lowercase()
        .chars()
        .map(|c| if c.is_alphanumeric() { c } else { '-' })
        .collect::<String>()
        .split('-')
        .filter(|s| !s.is_empty())
        .collect::<Vec<_>>()
        .join("-")
}

/// Generate filename for ADR
pub fn generate_filename(number: u16, title: &str) -> String {
    let slug = title_to_slug(title);
    format!("{:04}-{}.md", number, slug)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_title_to_slug() {
        assert_eq!(
            title_to_slug("Use Rust for CLI tools"),
            "use-rust-for-cli-tools"
        );
        assert_eq!(
            title_to_slug("Record architecture decisions"),
            "record-architecture-decisions"
        );
        assert_eq!(
            title_to_slug("API Design & Security"),
            "api-design-security"
        );
    }

    #[test]
    fn test_generate_filename() {
        assert_eq!(generate_filename(1, "Use Rust"), "0001-use-rust.md");
        assert_eq!(generate_filename(42, "API Design"), "0042-api-design.md");
    }

    #[test]
    fn test_template_structure() {
        // Test that the default template contains all required sections
        assert!(DEFAULT_TEMPLATE.contains("## Status"));
        assert!(DEFAULT_TEMPLATE.contains("## Context"));
        assert!(DEFAULT_TEMPLATE.contains("## Decision"));
        assert!(DEFAULT_TEMPLATE.contains("## Alternatives"));
        assert!(DEFAULT_TEMPLATE.contains("## Consequences"));

        // Test that sections are in the correct order
        let status_pos = DEFAULT_TEMPLATE.find("## Status").unwrap();
        let context_pos = DEFAULT_TEMPLATE.find("## Context").unwrap();
        let decision_pos = DEFAULT_TEMPLATE.find("## Decision").unwrap();
        let alternatives_pos = DEFAULT_TEMPLATE.find("## Alternatives").unwrap();
        let consequences_pos = DEFAULT_TEMPLATE.find("## Consequences").unwrap();

        assert!(status_pos < context_pos);
        assert!(context_pos < decision_pos);
        assert!(decision_pos < alternatives_pos);
        assert!(alternatives_pos < consequences_pos);

        // Test the init template also has the Alternatives section
        assert!(INIT_TEMPLATE.contains("## Alternatives"));
        assert!(INIT_TEMPLATE.contains("Other options considered:"));
    }
}
