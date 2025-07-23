# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a modular Bootstrap script system for creating Python projects with integrated Claude TDD + Scrumban workflow. The codebase consists of:

- **Original monolithic bootstrap script** (`bootstrap-claude-python.sh`) - Single-file implementation
- **Modular bootstrap system** (`bootstrap-claude-python-modular.sh` + `lib/` modules) - Refactored for flexibility
- **Usage examples** (`examples/custom-bootstrap.sh`) - Demonstrates modular usage patterns

## Core Architecture 

The modular system has a `core.sh` base layer with four independent modules: `python.sh`, `git.sh`, `claude.sh`, and `templates.sh`. All modules depend on `core.sh` for shared utilities and communicate through global variables set by `parse_arguments()`.

## Key Commands

### Testing the Bootstrap Scripts

#### Windows (PowerShell)
```powershell
# Test PowerShell versions
.\bootstrap-claude-python.ps1 test-project -Description "Test description"
.\bootstrap-claude-python-modular.ps1 test-project -Description "Test description"

# Test individual module usage
.\examples\custom-bootstrap.ps1 simple test-simple -Description "Simple project"
.\examples\custom-bootstrap.ps1 python-only test-env -Description "Python only"
```

#### Linux/macOS/WSL (Bash)
```bash
# Test bash versions
./bootstrap-claude-python.sh test-project -d "Test description"
./bootstrap-claude-python-modular.sh test-project -d "Test description"

# Test individual module usage
./examples/custom-bootstrap.sh simple test-simple "Simple project"  
./examples/custom-bootstrap.sh python-only test-env "Python only"
```

### Development and Testing

#### PowerShell Development
```powershell
# Test module sourcing (for development)
. .\lib\powershell\core.ps1
Test-ProjectName "test-name"

# Source individual modules for testing
. .\lib\powershell\core.ps1
. .\lib\powershell\python.ps1
# Test specific functions...
```

#### Bash Development  
```bash
# Make scripts executable
chmod +x bootstrap-claude-python.sh bootstrap-claude-python-modular.sh examples/custom-bootstrap.sh

# Test module sourcing (for development)
source lib/core.sh && validate_project_name "test-name"

# Source individual modules for testing
source lib/core.sh
source lib/python.sh
# Test specific functions...

# Check module dependencies
grep -r "source.*lib/" lib/  # Find inter-module dependencies
```

### Cross-Platform Testing
```bash
# Verify both PowerShell and bash scripts produce equivalent output
# (Directory structures should be identical, only script syntax differs)
```

## Architecture Details

The scripts follow a **Parse & Validate → Setup Structure → Module Setup → Documentation** pattern. Each module has both granular functions and orchestrator functions. 

**Platform Differences:**
- **PowerShell**: Functions return `$true`/`$false`, uses `$ErrorActionPreference = "Stop"`
- **Bash**: Functions return 0/1, uses `set -e` error handling
- **Generated Content**: Identical project structures across platforms

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

**Individual Module Usage**: Always source `lib/core.sh` first, then required modules. Use orchestrator functions (`setup_*_environment()`) for complete setups or granular functions for specific tasks.

**Custom Workflows**: The `examples/custom-bootstrap.sh` demonstrates three patterns - Simple (Python + Git), Add Claude (retrofit workflow), and Python-only (no Git/Claude).

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
- Update `README.md` with new function documentation

### Testing Strategy
- Create test projects with both scripts and compare outputs
- Test individual module functions in isolation
- Verify the generated projects actually work (run their tests, quality checks)
- Test custom workflow examples in `examples/custom-bootstrap.sh`