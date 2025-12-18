use clap::{Parser, Subcommand};

mod adr;
mod config;
mod template;

#[derive(Parser)]
#[command(name = "adr")]
#[command(about = "Architecture Decision Records tools", long_about = None)]
#[command(version = "0.1.0")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Initialize a new ADR directory
    Init {
        /// Directory to store ADRs (default: doc/adr)
        directory: Option<String>,
    },
    /// Create a new Architecture Decision Record
    New {
        /// Title of the ADR
        title: String,
        /// Supersede a previous ADR
        #[arg(short, long)]
        supersede: Option<u16>,
    },
    /// List all Architecture Decision Records
    List,
    /// Generate table of contents for ADRs
    Generate {
        /// Type of output to generate
        #[arg(value_parser(["toc", "graph"]))]
        output_type: String,
    },
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Init { directory } => {
            adr::init(directory.as_deref())?;
        }
        Commands::New { title, supersede } => {
            adr::new(&title, supersede)?;
        }
        Commands::List => {
            adr::list()?;
        }
        Commands::Generate { output_type } => {
            adr::generate(&output_type)?;
        }
    }

    Ok(())
}
