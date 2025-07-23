# Bootstrap Claude Python - Module Usage Guide

## Overview

The bootstrap script has been refactored into a modular architecture that allows you to use individual components or create custom workflows.

## Module Structure

```
lib/
├── core.sh          # Shared utilities, validation, colors
├── python.sh        # Python environment setup
├── git.sh           # Git repository management  
├── claude.sh        # Claude workflow files
└── templates.sh     # README and documentation templates
```

## Basic Usage

### Full Bootstrap (Same as Original)
```bash
./bootstrap-claude-python-modular.sh my-project -d "My awesome project"
```

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

## Module Functions

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

## Running the Examples

The `examples/custom-bootstrap.sh` script demonstrates these patterns:

```bash
# Create simple Python project
./examples/custom-bootstrap.sh simple my-api "REST API project"

# Add Claude workflow to existing project  
./examples/custom-bootstrap.sh add-claude existing-project

# Python-only setup
./examples/custom-bootstrap.sh python-only test-lib "Library project"
```

## Module Dependencies

- **core.sh** - No dependencies (base module)
- **python.sh** - Requires core.sh
- **git.sh** - Requires core.sh  
- **claude.sh** - Requires core.sh
- **templates.sh** - Requires core.sh

Always source core.sh first, then any other modules you need.

## Benefits of Modular Approach

1. **Flexibility** - Use only what you need
2. **Reusability** - Compose custom workflows
3. **Maintainability** - Each module has single responsibility
4. **Testing** - Can test individual modules
5. **Extensibility** - Easy to add new modules

## Integration with Original Script

The original `bootstrap-claude-python.sh` remains unchanged and fully functional. The new modular version (`bootstrap-claude-python-modular.sh`) provides the same functionality but with a cleaner, more maintainable architecture.

Both scripts produce identical results - the modular version just offers more flexibility for custom use cases.