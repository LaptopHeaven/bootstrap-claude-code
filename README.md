# Bootstrap Claude Python

A modular bootstrap script system for creating Python projects with integrated Claude TDD + Scrumban workflow.

## Quick Start

### Create a New Project (Full Bootstrap)
```bash
# Using the modular version (recommended)
./bootstrap-claude-python-modular.sh my-awesome-project -d "My awesome Python project"

# Using the original version (same result)
./bootstrap-claude-python.sh my-awesome-project -d "My awesome Python project"
```

### Options
```bash
-d, --description <desc>   # Project description
-p, --python <version>     # Python version (default: 3.12)
-h, --help                 # Show help
```

## What Gets Created

The bootstrap scripts create a complete Python project with:

- **Python Environment**: Virtual environment, dependencies, pytest configuration
- **Code Quality**: Black, flake8, mypy, isort with pre-commit hooks
- **Git Integration**: Repository, structured commit hooks, utility scripts
- **Claude Workflow**: Complete TDD + Scrumban workflow system in `.claude/` directory
- **Documentation**: README, usage guides, development documentation

## Modular Architecture

The system is built with a modular architecture for flexibility:

```
lib/
├── core.sh      # Shared utilities, validation, colors
├── python.sh    # Python environment setup
├── git.sh       # Git repository management
├── claude.sh    # Claude workflow files
└── templates.sh # Documentation templates
```

### Using Individual Modules

```bash
# Source the modules you need
source lib/core.sh
source lib/python.sh
source lib/claude.sh

# Use specific functions
validate_project_name "my-project"
setup_python_environment "my-project" "Description" "3.12"
create_claude_workflow_files "my-project" "Description" "3.12"
```

### Custom Workflows

See `examples/custom-bootstrap.sh` for examples:

```bash
# Simple Python project (no Claude workflow)
./examples/custom-bootstrap.sh simple my-api "REST API project"

# Add Claude workflow to existing project
./examples/custom-bootstrap.sh add-claude existing-project

# Python environment only
./examples/custom-bootstrap.sh python-only test-lib "Library project"
```

## Generated Project Features

Projects created by this bootstrap include:

### Claude TDD + Scrumban Workflow
- **Domain-based development** (Frontend/Backend/Reviewer)
- **Session management** with sign-in/sign-out protocols
- **Scrumban board** for work tracking
- **Structured logging** system
- **Cross-domain communication** via checkpoint files

### Quality Gates
- **Testing**: pytest with coverage reporting
- **Formatting**: Black code formatter
- **Linting**: flake8 with mypy type checking
- **Import sorting**: isort
- **Pre-commit hooks**: Automated quality checks

### Development Tools
- **Utility scripts**: `scripts/test.sh`, `scripts/quality.sh`
- **Git hooks**: Enforce commit message format and quality
- **Virtual environment**: Isolated dependencies
- **Comprehensive documentation**: Usage guides and development docs

## Documentation

- **MODULE_USAGE.md** - Detailed module usage and API reference
- **CLAUDE.md** - Guidance for Claude Code when working with this repository
- **examples/** - Working examples of custom usage patterns

## Requirements

- Python 3.12+ (configurable)
- Git
- Bash shell

## Development

### Testing the Bootstrap Scripts

```bash
# Test both versions produce identical results
./bootstrap-claude-python.sh test1 -d "Test project"
./bootstrap-claude-python-modular.sh test2 -d "Test project"
diff -r test1/ test2/

# Test custom workflows
./examples/custom-bootstrap.sh simple test-simple "Simple project"
```

### Adding New Modules

1. Create `lib/new_module.sh`
2. Source `lib/core.sh` for shared utilities
3. Follow the established patterns (error handling, function naming)
4. Update `MODULE_USAGE.md` with new functions
5. Test integration with existing modules

## License

[Add your license here]

## Contributing

1. Test both monolithic and modular scripts produce identical results
2. Update documentation when adding new features
3. Follow the established error handling and output patterns
4. Provide examples of new functionality