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
}
