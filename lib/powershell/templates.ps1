# Templates module for Claude Python Bootstrap - PowerShell Version  
# Creates README and other documentation templates

# Dot-source core utilities
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir\core.ps1"

# Function to create README.md
function New-ReadmeTemplate {
    param(
        [string]$ProjectName,
        [string]$ProjectDescription,
        [string]$PythonVersion,
        [string]$PackageName
    )
    
    Write-Status "Creating README.md..."
    
    $readmeContent = @"
# $ProjectName

$ProjectDescription

## Overview

This project is managed using the Claude TDD + Scrumban workflow for systematic, test-driven development with clear progress tracking.

## Getting Started

### Prerequisites
- Python $PythonVersion or higher
- Git
- PowerShell (Windows) or Bash (Linux/macOS)

### Setup

#### Windows (PowerShell)
``````powershell
# Clone the repository
git clone <repository-url>
Set-Location $ProjectName

# Activate virtual environment
.\.venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt -r requirements-dev.txt

# Verify setup
python -m pytest tests\ -v
``````

#### Linux/macOS/WSL (Bash)
``````bash
# Clone the repository
git clone <repository-url>
cd $ProjectName

# Activate virtual environment
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt -r requirements-dev.txt

# Verify setup
python -m pytest tests/ -v
``````

### Running Tests

#### Windows (PowerShell)
``````powershell
# Run all tests
python -m pytest tests\ -v

# Run with coverage
python -m pytest tests\ -v --cov=src --cov-report=html

# Run only unit tests
python -m pytest tests\unit\ -v

# Run only integration tests
python -m pytest tests\integration\ -v

# Use utility script
.\scripts\test.ps1
``````

#### Linux/macOS/WSL (Bash)
``````bash
# Run all tests
python -m pytest tests/ -v

# Run with coverage
python -m pytest tests/ -v --cov=src --cov-report=html

# Run only unit tests
python -m pytest tests/unit/ -v

# Run only integration tests
python -m pytest tests/integration/ -v

# Use utility script
./scripts/test.sh
``````

### Code Quality

#### Windows (PowerShell)
``````powershell  
# Format code
python -m black src\ tests\

# Lint code
python -m flake8 src\ tests\

# Sort imports
python -m isort src\ tests\

# Type checking
python -m mypy src\

# Run all quality checks
.\scripts\quality.ps1
``````

#### Linux/macOS/WSL (Bash)
``````bash
# Format code
python -m black src/ tests/

# Lint code
python -m flake8 src/ tests/

# Sort imports
python -m isort src/ tests/

# Type checking
python -m mypy src/

# Run all quality checks
./scripts/quality.sh
``````

## Development Workflow

This project follows the Claude TDD + Scrumban workflow:

1. **Read the PRD:** See ``.claude/prd.md`` for requirements
2. **Check the Board:** See ``.claude/scrumban.md`` for current status  
3. **Follow TDD:** Red → Green → Refactor cycle
4. **Commit Frequently:** Use structured commit messages
5. **Review Progress:** Update scrumban board after changes

### Commit Message Format
``````
[Type]: [Feature] - [Description]
``````

Types: Red, Green, Refactor, Reset, Docs, Setup

### TDD Cycle
1. **Red:** Write failing test (``python -m pytest tests\ -v`` or ``python -m pytest tests/ -v``)
2. **Green:** Implement minimal code to pass (``python -m pytest tests\ -v`` or ``python -m pytest tests/ -v``)
3. **Refactor:** Clean up code (``python -m pytest tests\ -v`` or ``python -m pytest tests/ -v``)

## Project Structure
``````
├── .claude\              # Claude agent tracking and state files
│   ├── scrumban.md       # Current work status board
│   ├── prd.md            # Product requirements document
│   ├── decisions.md      # Technical decisions log
│   ├── project.md        # Overall project context and status
│   ├── frontend.md       # Frontend domain context
│   ├── backend.md        # Backend domain context  
│   ├── reviewer.md       # Review domain context
│   └── logs\             # Organized logging system
│       ├── system.md     # Infrastructure and setup logs
│       ├── project.md    # Project-level changes and decisions
│       └── debug.md      # Development issues and debugging
├── src\
│   └── ${PackageName}\   # Main application code
├── tests\
│   ├── unit\             # Unit tests
│   └── integration\      # Integration tests
├── docs\                 # Documentation
├── scripts\              # Utility scripts (PowerShell and Bash versions)
├── requirements.txt      # Production dependencies
├── requirements-dev.txt  # Development dependencies
├── pytest.ini           # Test configuration
├── pyproject.toml        # Project configuration
├── CLAUDE.md             # Main Claude agent workflow instructions
└── README.md             # This file
``````

## Quality Gates

All code must pass:
- [ ] Tests (``python -m pytest tests\ -v`` or ``python -m pytest tests/ -v``)
- [ ] Formatting (``python -m black --check src\ tests\`` or ``python -m black --check src/ tests/``)
- [ ] Linting (``python -m flake8 src\ tests\`` or ``python -m flake8 src/ tests/``)
- [ ] Import sorting (``python -m isort --check-only src\ tests\`` or ``python -m isort --check-only src/ tests/``)
- [ ] Type checking (``python -m mypy src\`` or ``python -m mypy src/``)
- [ ] Coverage ≥ 80%

## Cross-Platform Support

This project supports both Windows (PowerShell) and Unix-like systems (Bash):

- **Windows:** Use ``.ps1`` scripts and PowerShell commands
- **Linux/macOS/WSL:** Use ``.sh`` scripts and bash commands
- **Git Bash on Windows:** Use bash syntax with Windows paths

## Contributing

1. Follow the TDD workflow outlined in ``CLAUDE.md``
2. Ensure all quality gates pass before committing
3. Update the scrumban board as work progresses
4. Use structured commit messages
5. Test on your target platform (Windows/PowerShell or Unix/Bash)

## License

[Add your license here]
"@
    
    $readmeContent | Out-File -FilePath "README.md" -Encoding UTF8
    Write-Success "README.md created"
    return $true
}

# Function to create usage examples
function New-UsageExamples {
    param(
        [string]$ProjectName,
        [string]$PackageName
    )
    
    Write-Status "Creating usage examples..."
    
    # Ensure docs directory exists
    if (-not (Test-Path "docs")) {
        New-Item -ItemType Directory -Path "docs" -Force | Out-Null
    }
    
    $usageContent = @"
# Usage Examples

## Basic Usage

### Using the Hello World Function

``````python
from src.${PackageName}.main import hello_world

# Basic usage
print(hello_world())  # Output: Hello, World!

# With custom name
print(hello_world("Alice"))  # Output: Hello, Alice!

# Empty string handling
print(hello_world(""))  # Output: Hello, !
``````

### Running as Module

#### Windows (PowerShell)
``````powershell
# Run the main module directly
python -m src.${PackageName}.main

# Or run the main.py file
python src\${PackageName}\main.py
``````

#### Linux/macOS/WSL (Bash)
``````bash
# Run the main module directly
python -m src.${PackageName}.main

# Or run the main.py file
python src/${PackageName}/main.py
``````

## Testing Examples

### Running Specific Tests

#### Windows (PowerShell)
``````powershell
# Run a specific test file
python -m pytest tests\unit\test_main.py -v

# Run a specific test function
python -m pytest tests\unit\test_main.py::TestHelloWorld::test_hello_world_default -v

# Run tests with specific markers
python -m pytest -m "not slow" -v

# Run integration tests only
python -m pytest tests\integration\ -v
``````

#### Linux/macOS/WSL (Bash)
``````bash
# Run a specific test file
python -m pytest tests/unit/test_main.py -v

# Run a specific test function
python -m pytest tests/unit/test_main.py::TestHelloWorld::test_hello_world_default -v

# Run tests with specific markers
python -m pytest -m "not slow" -v

# Run integration tests only
python -m pytest tests/integration/ -v
``````

### Code Coverage Examples

#### Windows (PowerShell)
``````powershell
# Generate HTML coverage report
python -m pytest tests\ --cov=src --cov-report=html
# View report: open htmlcov\index.html

# Generate terminal coverage report
python -m pytest tests\ --cov=src --cov-report=term-missing

# Set coverage threshold
python -m pytest tests\ --cov=src --cov-fail-under=80
``````

#### Linux/macOS/WSL (Bash)
``````bash
# Generate HTML coverage report
python -m pytest tests/ --cov=src --cov-report=html
# View report: open htmlcov/index.html

# Generate terminal coverage report
python -m pytest tests/ --cov=src --cov-report=term-missing

# Set coverage threshold
python -m pytest tests/ --cov=src --cov-fail-under=80
``````

## Quality Assurance Examples

### Code Formatting

#### Windows (PowerShell)
``````powershell
# Check if code needs formatting
python -m black --check src\ tests\

# Format code
python -m black src\ tests\

# Show what would be changed without making changes
python -m black --diff src\ tests\
``````

#### Linux/macOS/WSL (Bash)
``````bash
# Check if code needs formatting
python -m black --check src/ tests/

# Format code
python -m black src/ tests/

# Show what would be changed without making changes
python -m black --diff src/ tests/
``````

### Linting and Type Checking

#### Windows (PowerShell)
``````powershell
# Run flake8 linting
python -m flake8 src\ tests\

# Run mypy type checking
python -m mypy src\

# Check import sorting
python -m isort --check-only src\ tests\

# Fix import sorting
python -m isort src\ tests\
``````

#### Linux/macOS/WSL (Bash)
``````bash
# Run flake8 linting
python -m flake8 src/ tests/

# Run mypy type checking
python -m mypy src/

# Check import sorting
python -m isort --check-only src/ tests/

# Fix import sorting
python -m isort src/ tests/
``````

## Troubleshooting

### Common Issues

1. **Virtual Environment Not Activated**
   
   **Windows (PowerShell):**
   ``````powershell
   # Activate the virtual environment first
   .\.venv\Scripts\Activate.ps1
   ``````
   
   **Linux/macOS/WSL (Bash):**
   ``````bash
   # Activate the virtual environment first
   source .venv/bin/activate
   ``````

2. **Import Errors in Tests**
   ``````powershell
   # Make sure you're running from project root
   Get-Location  # Should show your project directory
   python -m pytest tests\ -v
   ``````

3. **Code Quality Issues**
   
   **Windows:**
   ``````powershell
   # Run the quality script to fix most issues
   .\scripts\quality.ps1
   ``````
   
   **Linux/macOS/WSL:**
   ``````bash
   # Run the quality script to fix most issues
   ./scripts/quality.sh
   ``````

4. **PowerShell Execution Policy (Windows)**
   ``````powershell
   # If you can't run .ps1 scripts, set execution policy
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ``````

### Platform-Specific Notes

- **Windows:** Use backslashes (``\``) in paths for scripts
- **Linux/macOS/WSL:** Use forward slashes (``/``) in paths
- **Git Bash on Windows:** Use forward slashes but may need Windows-style activation
- **PowerShell:** Use ``.ps1`` script extensions
- **Bash:** Use ``.sh`` script extensions or no extension
"@
    
    $usageContent | Out-File -FilePath "docs\USAGE.md" -Encoding UTF8
    Write-Success "Usage examples created"
    return $true
}

# Main function to create all templates
function New-AllTemplates {
    param(
        [string]$ProjectName,
        [string]$ProjectDescription,
        [string]$PythonVersion,
        [string]$PackageName
    )
    
    if (-not (New-ReadmeTemplate $ProjectName $ProjectDescription $PythonVersion $PackageName)) { return $false }
    if (-not (New-UsageExamples $ProjectName $PackageName)) { return $false }
    
    return $true
}