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

## Architecture Overview

### Core Architecture 

The modular system follows a layered dependency architecture:

```
core.sh (base layer)
├── python.sh (Python environment setup)
├── git.sh (Git repository management)  
├── claude.sh (Claude workflow files)
└── templates.sh (Documentation generation)
```

**Dependency Rule**: All modules depend on `core.sh`. Modules at the same level are independent of each other.

**Module Communication**: Modules communicate through:
- Shared global variables set by `parse_arguments()` in core.sh
- Function return values and exit codes
- Standard bash error handling patterns

### Function Orchestration Pattern
The main bootstrap functions follow this orchestration pattern:
1. **Parse & Validate** - `parse_arguments()` → `validate_inputs()`
2. **Setup Structure** - `create_basic_structure()` 
3. **Module Setup** - Each `setup_*_environment()` function handles its domain
4. **Documentation** - Template generation as final step

### Module Responsibilities
- **core.sh**: Argument parsing, validation, basic structure, shared utilities
- **python.sh**: Virtual environments, dependencies, pytest config, package structure  
- **git.sh**: Repository initialization, hooks, utility scripts, initial commit
- **claude.sh**: Complete Claude workflow file ecosystem (.claude/ directory structure)
- **templates.sh**: README, usage docs, development guides

### State Management
Modules communicate through global variables set in `core.sh`:
- `PROJECT_NAME` - Validated project name
- `PROJECT_DESCRIPTION` - Project description  
- `PYTHON_VERSION` - Target Python version
- `PACKAGE_NAME` - Python package name (derived from project name)

### Error Handling Pattern
All modules follow consistent error handling:
- Functions return 0 for success, 1 for failure
- `set -e` ensures script exits on any error
- Colored output functions (`print_error`, `print_success`) provide user feedback

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

### Module Dependencies

- **core.sh** - No dependencies (base module)
- **python.sh** - Requires core.sh
- **git.sh** - Requires core.sh  
- **claude.sh** - Requires core.sh
- **templates.sh** - Requires core.sh

Always source core.sh first, then any other modules you need.

### Using Individual Modules

```bash
# Source the modules you need
source lib/core.sh
source lib/python.sh
source lib/claude.sh

# Use specific functions
validate_project_name "my-project"
create_basic_structure "my-project" "my_project"
cd my-project
setup_python_environment "my-project" "Description" "3.12"
create_claude_workflow_files "my-project" "Description" "3.12"
```

## Module Function Reference

### lib/core.sh - Shared Utilities
```bash
# Color output functions
print_status "message"    # Blue info message
print_success "message"   # Green success message
print_warning "message"   # Yellow warning message  
print_error "message"     # Red error message

# Validation functions
validate_project_name "project-name"
check_prerequisites
check_directory_exists "project-name"

# Project setup
create_basic_structure "project-name" "package_name"
get_package_name "project-name"  # Converts hyphens to underscores

# Argument parsing
parse_arguments "$@"  # Sets PROJECT_NAME, PROJECT_DESCRIPTION, PYTHON_VERSION
show_usage
```

### lib/python.sh - Python Environment
```bash
# Virtual environment
create_virtual_environment
upgrade_pip

# Dependencies and configuration  
create_requirements_files "3.12"
install_dev_dependencies
create_pytest_config
create_pyproject_config "project" "description" "3.12"

# Package structure
create_python_package "package_name" "project" "description"
create_sample_tests "package_name" "project"
create_gitignore

# Verification
verify_python_setup

# All-in-one function
setup_python_environment "project" "description" "3.12"
```

### lib/git.sh - Git Management
```bash
# Git initialization
initialize_git_repository

# Hooks and scripts
setup_git_hooks
create_utility_scripts

# Initial commit
create_initial_commit "project-name"

# All-in-one function  
setup_git_environment "project-name"
```

### lib/claude.sh - Claude Workflow
```bash
# Individual file creation
create_claude_workflow          # Main CLAUDE.md
create_project_context "project" "description"
create_domain_contexts "3.12"
create_log_files "project" "3.12"
create_scrumban_board
create_prd_template "project" "description" "3.12"
create_decisions_log "3.12"
create_checkpoint_template

# All-in-one function
create_claude_workflow_files "project" "description" "3.12"
```

### lib/templates.sh - Documentation
```bash
# Template creation
create_readme "project" "description" "3.12" "package_name"
create_usage_examples "project" "package_name"
create_development_guide

# All-in-one function
create_all_templates "project" "description" "3.12" "package_name"
```

## Custom Workflow Examples

### 1. Simple Python Project (No Claude Workflow)
```bash
#!/bin/bash
source lib/core.sh
source lib/python.sh
source lib/git.sh

PROJECT_NAME="simple-project"
PACKAGE_NAME=$(get_package_name "$PROJECT_NAME")

validate_project_name "$PROJECT_NAME"
create_basic_structure "$PROJECT_NAME" "$PACKAGE_NAME"
cd "$PROJECT_NAME"

setup_python_environment "$PROJECT_NAME" "Simple Python project" "3.12"
setup_git_environment "$PROJECT_NAME"

echo "Simple Python project created!"
```

### 2. Add Claude Workflow to Existing Project
```bash
#!/bin/bash
source lib/core.sh
source lib/claude.sh

if [ -d "existing-project" ]; then
    cd existing-project
    create_claude_workflow_files "existing-project" "Add Claude workflow" "3.12"
    echo "Claude workflow added!"
else
    echo "Project directory not found"
fi
```

### 3. Python Environment Only (No Git/Claude)
```bash
#!/bin/bash
source lib/core.sh
source lib/python.sh

PROJECT_NAME="python-only"
PACKAGE_NAME=$(get_package_name "$PROJECT_NAME")

create_basic_structure "$PROJECT_NAME" "$PACKAGE_NAME"
cd "$PROJECT_NAME"

# Individual Python setup functions
create_virtual_environment
upgrade_pip
create_requirements_files "3.12"
install_dev_dependencies
create_python_package "$PACKAGE_NAME" "$PROJECT_NAME" "Python-only project"
create_sample_tests "$PACKAGE_NAME" "$PROJECT_NAME"

echo "Python environment ready!"
```

### 4. Documentation Only
```bash
#!/bin/bash
source lib/core.sh
source lib/templates.sh

cd existing-project
create_all_templates "existing-project" "Add documentation" "3.12" "existing_project"
echo "Documentation added!"
```

### Running the Examples

The `examples/custom-bootstrap.sh` script demonstrates these patterns:

```bash
# Create simple Python project
./examples/custom-bootstrap.sh simple my-api "REST API project"

# Add Claude workflow to existing project  
./examples/custom-bootstrap.sh add-claude existing-project

# Python-only setup
./examples/custom-bootstrap.sh python-only test-lib "Library project"
```

### Function Granularity
Each module provides both granular functions and all-in-one orchestrators:
- **Granular**: `create_virtual_environment()`, `create_pytest_config()`
- **Orchestrator**: `setup_python_environment()` (calls multiple granular functions)

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

## Benefits of Modular Approach

1. **Flexibility** - Use only what you need
2. **Reusability** - Compose custom workflows
3. **Maintainability** - Each module has single responsibility
4. **Testing** - Can test individual modules
5. **Extensibility** - Easy to add new modules

## Integration with Original Script

The original `bootstrap-claude-python.sh` remains unchanged and fully functional. The new modular version (`bootstrap-claude-python-modular.sh`) provides the same functionality but with a cleaner, more maintainable architecture.

Both scripts produce identical results - the modular version just offers more flexibility for custom use cases.

## Documentation

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
4. Update documentation with new functions
5. Test integration with existing modules

## License

[Add your license here]

## Contributing

1. Test both monolithic and modular scripts produce identical results
2. Update documentation when adding new features
3. Follow the established error handling and output patterns
4. Provide examples of new functionality