# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **dual-platform** modular Bootstrap script system for creating Python projects with integrated Claude TDD + Scrumban workflow. The codebase consists of:

### Bash Implementation (Linux/macOS/WSL)
- **Original monolithic bootstrap script** (`bootstrap-claude-python.sh`) - Single-file implementation
- **Modular bootstrap system** (`bootstrap-claude-python-modular.sh` + `lib/` modules) - Refactored for flexibility
- **Usage examples** (`examples/custom-bootstrap.sh`) - Demonstrates modular usage patterns

### PowerShell Implementation (Windows)
- **PowerShell bootstrap scripts** (`bootstrap-claude-python.ps1`, `bootstrap-claude-python-modular.ps1`) - Native Windows versions
- **PowerShell modules** (`lib/powershell/` modules) - PowerShell-native implementations
- **PowerShell examples** (`examples/custom-bootstrap.ps1`) - Windows-specific usage patterns

**Critical**: Both implementations must be maintained in parallel. Any feature changes, bug fixes, or new functionality MUST be implemented in both bash and PowerShell versions.

## Core Architecture 

The modular system has parallel implementations:

### Bash Architecture (`lib/`)
- `core.sh` base layer with four independent modules: `python.sh`, `git.sh`, `claude.sh`, and `templates.sh`
- All modules depend on `core.sh` for shared utilities and communicate through global variables set by `parse_arguments()`

### PowerShell Architecture (`lib/powershell/`)
- `core.ps1` base layer with four independent modules: `python.ps1`, `git.ps1`, `claude.ps1`, and `templates.ps1`
- All modules depend on `core.ps1` for shared utilities and communicate through script-scoped variables set by `Set-ProjectArguments`

**Both architectures must remain functionally equivalent and produce identical project structures.**

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

### Bash Module Usage
- Always source `lib/core.sh` first, then required modules
- Use orchestrator functions (`setup_*_environment()`) for complete setups or granular functions for specific tasks
- Example: `source lib/core.sh && source lib/python.sh`

### PowerShell Module Usage  
- Always dot-source `lib/powershell/core.ps1` first, then required modules
- Use orchestrator functions (`Initialize-*Environment`) for complete setups or granular functions for specific tasks
- Example: `. .\lib\powershell\core.ps1; . .\lib\powershell\python.ps1`

### Custom Workflows
Both `examples/custom-bootstrap.sh` (bash) and `examples/custom-bootstrap.ps1` (PowerShell) demonstrate three patterns:
- **Simple**: Python + Git, no Claude workflow
- **Add Claude**: Retrofit workflow to existing project  
- **Python-only**: Just Python environment, no Git/Claude

## Development Guidelines

### ⚠️ CRITICAL: Dual-Platform Development Rules

**ALWAYS implement changes in BOTH platforms:**
1. **Any new feature** → Add to both `lib/module.sh` AND `lib/powershell/module.ps1`
2. **Any bug fix** → Fix in both bash and PowerShell versions
3. **Any function change** → Update both implementations with equivalent functionality
4. **Any new module** → Create both `.sh` and `.ps1` versions

### Adding New Modules
**Bash Version (`lib/`):**
1. Follow the naming pattern: `lib/module_name.sh`
2. Source `lib/core.sh` at the top for shared utilities
3. Provide both granular functions and one main orchestrator function
4. Follow the error handling pattern (return codes + `set -e`)
5. Use the established color output functions

**PowerShell Version (`lib/powershell/`):**
1. Follow the naming pattern: `lib/powershell/module_name.ps1`
2. Dot-source `lib/powershell/core.ps1` at the top for shared utilities
3. Provide both granular functions and one main orchestrator function (use `Initialize-*` naming)
4. Follow the error handling pattern (`$true`/`$false` returns + `$ErrorActionPreference = "Stop"`)
5. Use the established colored output functions (`Write-Status`, etc.)

### Modifying Existing Modules  
- **Maintain parallel functionality** across both bash and PowerShell versions
- **Maintain backward compatibility** for orchestrator functions in both platforms
- **New functionality should be additive, not breaking** in both implementations
- **Test both bash and PowerShell scripts** produce identical project structures
- **Update `README.md`** with platform-specific function documentation for both versions

### Testing Strategy (BOTH PLATFORMS REQUIRED)
- **Create test projects with both bash and PowerShell scripts** and compare outputs
- **Test individual module functions in isolation** for both platforms
- **Verify the generated projects actually work** (run their tests, quality checks) on both platforms
- **Test custom workflow examples** in both `examples/custom-bootstrap.sh` AND `examples/custom-bootstrap.ps1`
- **Cross-platform testing**: Ensure bash and PowerShell versions create equivalent projects

### Function Naming Conventions
**Bash (`lib/`):** 
- `validate_project_name()`, `setup_python_environment()`, `create_*()`, `check_*()`

**PowerShell (`lib/powershell/`):**
- `Test-ProjectName`, `Initialize-PythonEnvironment`, `New-*`, `Test-*`

### Error Handling Patterns
**Bash:** Functions return 0 (success) or 1 (failure), use `set -e`
**PowerShell:** Functions return `$true` (success) or `$false` (failure), use `$ErrorActionPreference = "Stop"`

### Output Functions
**Bash:** `print_status`, `print_success`, `print_warning`, `print_error`
**PowerShell:** `Write-Status`, `Write-Success`, `Write-Warning`, `Write-Error`