# Bootstrap Claude Code

A modular, cross-platform bootstrap system for creating development projects with integrated Claude TDD + Scrumban workflows. Currently supports Python and .NET 8 with a flexible architecture designed for easy extension to other languages and project types.

## Quick Start

### Python Projects

#### Create a New Python Project

#### Windows (PowerShell)
```powershell
# Using the modular version (recommended)
.\bootstrap-claude-code-python-modular.ps1 my-awesome-project -Description "My awesome Python project"

# Using the original version (same result)
.\bootstrap-claude-code-python.ps1 my-awesome-project -Description "My awesome Python project"
```

#### Linux/macOS/WSL (Bash)
```bash
# Using the modular version (recommended)
./bootstrap-claude-code-python-modular.sh my-awesome-project -d "My awesome Python project"

# Using the original version (same result)
./bootstrap-claude-code-python.sh my-awesome-project -d "My awesome Python project"
```

### .NET 8 Projects

#### Create a New .NET Project

#### Windows (PowerShell)
```powershell
# Using the modular version (recommended)
.\bootstrap-claude-code-dotnet-modular.ps1 MyAwesomeLibrary -Description "My awesome .NET library"

# Using the original version (same result)
.\bootstrap-claude-code-dotnet.ps1 MyAwesomeLibrary -Description "My awesome .NET library"

# Create different project types
.\bootstrap-claude-code-dotnet.ps1 MyConsoleApp -Description "Console application" -ProjectType console
.\bootstrap-claude-code-dotnet.ps1 MyWebApi -Description "REST API service" -ProjectType webapi
```

#### Linux/macOS/WSL (Bash)
```bash
# Using the modular version (recommended)
./bootstrap-claude-code-dotnet-modular.sh my-awesome-library -d "My awesome .NET library"

# Using the original version (same result)
./bootstrap-claude-code-dotnet.sh my-awesome-library -d "My awesome .NET library"

# Create different project types
./bootstrap-claude-code-dotnet.sh my-console-app -d "Console application" -t console
./bootstrap-claude-code-dotnet.sh my-web-api -d "REST API service" -t webapi
```

### Options

#### Python Options (PowerShell)
```powershell
-Description <desc>    # Project description
-PythonVersion <ver>   # Python version (default: 3.12)
-Help                  # Show help
```

#### Python Options (Bash)
```bash
-d, --description <desc>   # Project description
-p, --python <version>     # Python version (default: 3.12)
-h, --help                 # Show help
```

#### .NET Options (PowerShell)
```powershell
-Description <desc>    # Project description
-ProjectType <type>    # Project type (classlib, console, webapi, mvc, api) [default: classlib]
-Help                  # Show help
```

#### .NET Options (Bash)
```bash
-d, --description <desc>   # Project description
-t, --type <type>          # Project type (classlib, console, webapi) [default: classlib]
-h, --help                 # Show help
```

## What Gets Created

### Python Projects

The Python bootstrap modules create a complete project with:

- **Python Environment**: Virtual environment, dependencies, pytest configuration
- **Code Quality**: Black, flake8, mypy, isort with pre-commit hooks
- **Git Integration**: Repository, structured commit hooks, utility scripts
- **Claude Workflow**: Complete TDD + Scrumban workflow system in `.claude/` directory
- **Documentation**: README, usage guides, development documentation

### .NET 8 Projects

The .NET bootstrap modules create a complete project with:

- **.NET Environment**: .NET 8 solution with class library/console/webapi templates
- **Testing Framework**: xUnit with FluentAssertions, Moq, and code coverage
- **Code Quality**: EditorConfig, code analyzers, consistent formatting
- **Configuration**: Global.json, Directory.Build.props for shared settings
- **Git Integration**: Repository, .NET-specific .gitignore, utility scripts
- **Claude Workflow**: Complete TDD + Scrumban workflow system in `.claude/` directory
- **Documentation**: README, API documentation, development guides

## Architecture Overview

### Modular Design Philosophy

Bootstrap Claude Code uses a **language-agnostic modular architecture** where:
- **Core modules** provide shared functionality across all project types
- **Language-specific modules** handle technology-specific setup
- **Workflow modules** add development processes (Claude TDD, Git, etc.)

### Current Architecture (Multi-Language Implementation)

```
core.sh (base layer - universal)
├── python.sh (Python-specific environment)
├── dotnet.sh (.NET 8-specific environment)
├── git.sh (Git repository management - universal)  
├── claude.sh (Claude workflow files - universal)
└── templates.sh (Documentation generation - universal)
```

### Future Architecture Vision

```
core.sh (base layer)
├── Language Modules:
│   ├── python.sh (Python projects)
│   ├── dotnet.sh (.NET 8 projects)
│   ├── nodejs.sh (Node.js projects) [planned]
│   ├── golang.sh (Go projects) [planned]
│   └── rust.sh (Rust projects) [planned]
├── Universal Modules:
│   ├── git.sh (Git repository management)
│   ├── claude.sh (Claude workflow files)
│   ├── docker.sh (Containerization) [planned]
│   └── templates.sh (Documentation generation)
└── Framework Modules:
    ├── fastapi.sh (FastAPI setup) [planned]
    ├── react.sh (React setup) [planned]
    └── django.sh (Django setup) [planned]
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
- **dotnet.sh**: .NET solutions, NuGet packages, xUnit testing, code analyzers
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
├── dotnet.sh    # .NET 8 environment setup
├── git.sh       # Git repository management
├── claude.sh    # Claude workflow files
└── templates.sh # Documentation templates
```

### Module Dependencies

- **core.sh** - No dependencies (base module)
- **python.sh** - Requires core.sh
- **dotnet.sh** - Requires core.sh
- **git.sh** - Requires core.sh  
- **claude.sh** - Requires core.sh
- **templates.sh** - Requires core.sh

Always source core.sh first, then any other modules you need.

### Using Individual Modules

```bash
# Source the modules you need (Python example)
source lib/core.sh
source lib/python.sh
source lib/claude.sh

# Use specific functions
validate_project_name "my-project"
create_basic_structure "my-project" "my_project"
cd my-project
setup_python_environment "my-project" "Description" "3.12"
create_claude_workflow_files "my-project" "Description" "3.12"

# .NET example
source lib/core.sh
source lib/dotnet.sh
source lib/claude.sh

# Use specific functions
validate_project_name "my-dotnet-project"
PACKAGE_NAME=$(get_package_name "my-dotnet-project")
create_basic_structure "my-dotnet-project" "$PACKAGE_NAME"
cd my-dotnet-project
setup_dotnet_environment "my-dotnet-project" "Description" "classlib"
create_claude_workflow_files "my-dotnet-project" "Description" "net8.0"
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

### lib/dotnet.sh - .NET Environment
```bash
# Prerequisites and project creation
check_dotnet_prerequisites
create_dotnet_project "project" "classlib"

# Configuration files
create_global_json
create_directory_build_props "project" "description"
create_editorconfig

# Dependencies and utilities
setup_dotnet_dependencies "project"
create_dotnet_utility_scripts
create_dotnet_gitignore

# Verification
verify_dotnet_setup

# All-in-one function
setup_dotnet_environment "project" "description" "classlib"
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

### Windows (PowerShell) Examples

#### 1. Simple Python Project (No Claude Workflow)
```powershell
# Source required modules
. .\lib\powershell\core.ps1
. .\lib\powershell\python.ps1
. .\lib\powershell\git.ps1

# Set project parameters
Set-ProjectArguments -ProjectName "simple-project" -Description "Simple Python project"
$packageName = Get-PackageName $script:PROJECT_NAME

# Create and setup
New-BasicStructure $script:PROJECT_NAME $packageName
Set-Location $script:PROJECT_NAME
Initialize-PythonEnvironment $script:PROJECT_NAME $script:PROJECT_DESCRIPTION $script:PYTHON_VERSION
Initialize-GitEnvironment $script:PROJECT_NAME

Write-Host "Simple Python project created!"
```

#### 2. Add Claude Workflow to Existing Project
```powershell
# Source required modules
. .\lib\powershell\core.ps1
. .\lib\powershell\claude.ps1

if (Test-Path "existing-project") {
    Set-Location existing-project
    Initialize-ClaudeWorkflowFiles "existing-project" "Add Claude workflow" "3.12"
    Write-Host "Claude workflow added!"
} else {
    Write-Host "Project directory not found"
}
```

### Linux/macOS/WSL (Bash) Examples

#### 1. Simple Python Project (No Claude Workflow)
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

#### 2. Add Claude Workflow to Existing Project
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

### Running the Examples

#### Windows (PowerShell)
```powershell
# Create simple Python project
.\examples\custom-bootstrap.ps1 simple my-api -Description "REST API project"

# Add Claude workflow to existing project  
.\examples\custom-bootstrap.ps1 add-claude existing-project

# Python-only setup
.\examples\custom-bootstrap.ps1 python-only test-lib -Description "Library project"
```

#### Linux/macOS/WSL (Bash)
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

1. **Language Agnostic** - Core system supports any programming language
2. **Flexibility** - Use only the modules you need for your project
3. **Reusability** - Compose custom workflows across different tech stacks
4. **Maintainability** - Each module has single responsibility
5. **Testing** - Can test individual modules in isolation
6. **Extensibility** - Easy to add new languages, frameworks, and tools
7. **Consistency** - Same Claude workflow and quality standards across all project types

## Language Support

### Currently Supported

- **Python** - Full support with virtual environments, pytest, quality tools, and package management
- **.NET 8** - Full support with solutions, xUnit testing, code analyzers, and NuGet package management

### Planned Language Support

- **Node.js** - npm/yarn, Jest/Vitest, ESLint, TypeScript support
- **Go** - Go modules, testing framework, linting tools
- **Rust** - Cargo, testing, clippy integration
- **Java** - Maven/Gradle, JUnit, quality tools

### Integration Philosophy

The original `bootstrap-claude-code-python.sh` remains unchanged and fully functional. The modular version provides the same functionality but with an architecture that supports:

- **Multiple languages** through language-specific modules
- **Custom workflows** by combining different modules
- **Framework-specific setups** (FastAPI, React, Django, etc.)
- **Technology stacks** (full-stack combinations)

## Documentation

- **CLAUDE.md** - Guidance for Claude Code when working with this repository
- **examples/** - Working examples of custom usage patterns

## Requirements

### All Platforms
- Git

### For Python Projects
- Python 3.12+ (configurable, also supports 3.11+)

### For .NET Projects
- .NET 8 SDK

### Platform-Specific Requirements
- **Windows:** PowerShell 5.1+ (PowerShell 7+ recommended)
- **Linux/macOS/WSL:** Bash shell
- **Windows with Git Bash:** Bash shell (alternative to PowerShell)

## Development

### Testing the Bootstrap Scripts

#### Windows (PowerShell)
```powershell
# Test Python versions produce identical results
.\bootstrap-claude-code-python.ps1 test1 -Description "Test project"
.\bootstrap-claude-code-python-modular.ps1 test2 -Description "Test project"

# Test .NET versions produce identical results
.\bootstrap-claude-code-dotnet.ps1 test3 -Description "Test .NET project"
.\bootstrap-claude-code-dotnet-modular.ps1 test4 -Description "Test .NET project"

# Compare directories manually or use tools like WinMerge

# Test custom workflows
.\examples\custom-bootstrap.ps1 simple test-simple -Description "Simple project"
```

#### Linux/macOS/WSL (Bash)
```bash
# Test Python versions produce identical results
./bootstrap-claude-code-python.sh test1 -d "Test project"
./bootstrap-claude-code-python-modular.sh test2 -d "Test project"
diff -r test1/ test2/

# Test .NET versions produce identical results
./bootstrap-claude-code-dotnet.sh test3 -d "Test .NET project"
./bootstrap-claude-code-dotnet-modular.sh test4 -d "Test .NET project"
diff -r test3/ test4/

# Test custom workflows
./examples/custom-bootstrap.sh simple test-simple "Simple project"
```

#### Cross-Platform Testing
```bash
# Test both PowerShell and Bash versions create identical projects

# Python projects
.\bootstrap-claude-code-python.ps1 test-ps -Description "PowerShell test"
./bootstrap-claude-code-python.sh test-bash -d "Bash test"

# .NET projects
.\bootstrap-claude-code-dotnet.ps1 test-dotnet-ps -Description "PowerShell .NET test"
./bootstrap-claude-code-dotnet.sh test-dotnet-bash -d "Bash .NET test"

# Compare the generated projects
```

### Adding New Language Support

#### Adding a New Language Module

1. **Create language module**: `lib/language_name.sh` (e.g., `lib/nodejs.sh`)
2. **Follow the established patterns**:
   ```bash
   source lib/core.sh  # Always source core first
   
   # Implement standard functions:
   setup_language_environment()  # Main orchestrator
   create_language_project_structure()
   install_language_dependencies()
   create_language_config_files()
   verify_language_setup()
   ```
3. **Create bootstrap script**: `bootstrap-claude-code-language-modular.sh`
4. **Add PowerShell equivalent**: `lib/powershell/language.ps1`
5. **Update documentation** with new functions and examples
6. **Test integration** with core and universal modules

#### Adding Framework-Specific Modules

1. **Create framework module**: `lib/framework_name.sh`
2. **Depend on appropriate language module**:
   ```bash
   source lib/core.sh
   source lib/python.sh  # or nodejs.sh, etc.
   ```
3. **Implement framework-specific setup**
4. **Create examples** showing framework usage

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

1. Test both monolithic and modular scripts produce identical results
2. Update documentation when adding new features
3. Follow the established error handling and output patterns
4. Provide examples of new functionality