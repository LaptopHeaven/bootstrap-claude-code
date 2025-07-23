# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a modular Bootstrap script system for creating Python projects with integrated Claude TDD + Scrumban workflow. The codebase consists of:

- **Original monolithic bootstrap script** (`bootstrap-claude-python.sh`) - Single-file implementation
- **Modular bootstrap system** (`bootstrap-claude-python-modular.sh` + `lib/` modules) - Refactored for flexibility
- **Usage examples** (`examples/custom-bootstrap.sh`) - Demonstrates modular usage patterns

## Core Architecture 

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
- Exported functions (though currently not used)

## Key Commands

### Testing the Bootstrap Scripts
```bash
# Test original monolithic version
./bootstrap-claude-python.sh test-project -d "Test description"

# Test modular version (should produce identical results)
./bootstrap-claude-python-modular.sh test-project -d "Test description"

# Test individual module usage
./examples/custom-bootstrap.sh simple test-simple "Simple project"
./examples/custom-bootstrap.sh python-only test-env "Python only"
```

### Development and Testing
```bash
# Make scripts executable
chmod +x bootstrap-claude-python.sh bootstrap-claude-python-modular.sh examples/custom-bootstrap.sh

# Test module sourcing (for development)
source lib/core.sh && validate_project_name "test-name"

# Verify both scripts produce identical output
diff -r project1/ project2/  # After creating with both scripts
```

### Module Development
```bash
# Source individual modules for testing
source lib/core.sh
source lib/python.sh
# Test specific functions...

# Check module dependencies
grep -r "source.*lib/" lib/  # Find inter-module dependencies
```

## Architecture Details

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

## Generated Project Structure

The bootstrap scripts generate projects with this architecture:
```
project-name/
├── .claude/           # Claude agent workflow system
│   ├── *.md          # Domain contexts, scrumban board, PRD
│   └── logs/         # Structured logging system  
├── src/package_name/  # Main Python package
├── tests/            # Pytest test suite (unit + integration)
├── scripts/          # Utility scripts (test.sh, quality.sh)
├── lib dependencies  # requirements.txt, pyproject.toml, pytest.ini
└── git integration   # Hooks, .gitignore, initial commit
```

## Modular Usage Patterns

### Individual Module Usage
Source `lib/core.sh` first, then any required modules:
```bash
source lib/core.sh
source lib/python.sh  
setup_python_environment "project" "description" "3.12"
```

### Custom Workflow Composition
The `examples/custom-bootstrap.sh` demonstrates three patterns:
- **Simple**: Python + Git, no Claude workflow
- **Add Claude**: Retrofit Claude workflow to existing project
- **Python-only**: Just Python environment, no Git or Claude

### Function Granularity
Each module provides both granular functions and all-in-one orchestrators:
- Granular: `create_virtual_environment()`, `create_pytest_config()`
- Orchestrator: `setup_python_environment()` (calls multiple granular functions)

## Development Guidelines

### Adding New Modules
1. Follow the naming pattern: `lib/module_name.sh`
2. Source `lib/core.sh` at the top for shared utilities
3. Provide both granular functions and one main orchestrator function
4. Follow the error handling pattern (return codes + `set -e`)
5. Use the established color output functions

### Modifying Existing Modules  
- Maintain backward compatibility for orchestrator functions
- New functionality should be additive, not breaking
- Test both modular and monolithic scripts still produce identical results
- Update `MODULE_USAGE.md` with new function documentation

### Testing Strategy
- Create test projects with both scripts and compare outputs
- Test individual module functions in isolation
- Verify the generated projects actually work (run their tests, quality checks)
- Test custom workflow examples in `examples/custom-bootstrap.sh`