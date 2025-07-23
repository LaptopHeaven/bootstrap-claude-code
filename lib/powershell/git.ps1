# Git repository management module for Claude Python Bootstrap - PowerShell Version
# Handles git initialization, hooks setup, and initial commit

# Dot-source core utilities
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir\core.ps1"

# Function to initialize git repository
function Initialize-GitRepository {
    Write-Status "Initializing git repository..."
    
    try {
        & git init --initial-branch=main
        Write-Success "Git repository initialized"
        return $true
    }
    catch {
        Write-Error "Failed to initialize git repository: $_"
        return $false
    }
}

# Function to create git hooks
function New-GitHooks {
    Write-Status "Setting up git hooks..."
    
    # Ensure .git/hooks directory exists
    if (-not (Test-Path ".git\hooks")) {
        New-Item -ItemType Directory -Path ".git\hooks" -Force | Out-Null
    }
    
    # Create commit-msg hook
    $commitMsgHook = @'
#!/bin/sh
# Enforce commit message format

commit_regex='^(Red|Green|Refactor|Reset|Docs|Setup): .+ - .+'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit message format."
    echo "Expected: [Type]: [Feature] - [Description]"
    echo "Types: Red, Green, Refactor, Reset, Docs, Setup"
    echo ""
    echo "Examples:"
    echo "  Red: User Login - Added authentication tests"
    echo "  Green: User Login - JWT implementation"  
    echo "  Refactor: User Login - Extracted validation logic"
    exit 1
fi
'@
    
    $commitMsgHook | Out-File -FilePath ".git\hooks\commit-msg" -Encoding UTF8
    
    # Create pre-commit hook
    $preCommitHook = @'
#!/bin/sh
# Run quality checks before commit

# Try to activate virtual environment
if [ -f ".venv/Scripts/Activate.ps1" ]; then
    # This is a Windows environment, try PowerShell activation via bash
    if command -v pwsh >/dev/null 2>&1; then
        pwsh -ExecutionPolicy Bypass -Command ". .\.venv\Scripts\Activate.ps1"
    fi
elif [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
fi

echo "Running pre-commit quality checks..."

# Check formatting
if ! python -m black --check src/ tests/ 2>/dev/null; then
    echo "Code formatting issues found. Run 'python -m black src/ tests/' to fix."
    exit 1
fi

# Check imports
if ! python -m isort --check-only src/ tests/ 2>/dev/null; then
    echo "Import sorting issues found. Run 'python -m isort src/ tests/' to fix."
    exit 1
fi

# Check linting
if ! python -m flake8 src/ tests/ 2>/dev/null; then
    echo "Linting issues found. Fix them before committing."
    exit 1
fi

# Run tests
if ! python -m pytest tests/ -q 2>/dev/null; then
    echo "Tests are failing. Fix them before committing."
    exit 1
fi

echo "All pre-commit checks passed!"
'@
    
    $preCommitHook | Out-File -FilePath ".git\hooks\pre-commit" -Encoding UTF8
    
    Write-Success "Git hooks configured"
    return $true
}

# Function to create utility scripts
function New-UtilityScripts {
    Write-Status "Creating utility scripts..."
    
    # Ensure scripts directory exists
    if (-not (Test-Path "scripts")) {
        New-Item -ItemType Directory -Path "scripts" -Force | Out-Null
    }
    
    # Test runner script (PowerShell version)
    $testScript = @'
# Test runner script for Windows/PowerShell

Write-Host "Running test suite..." -ForegroundColor Blue

# Activate virtual environment
$activatePath = ".\.venv\Scripts\Activate.ps1"
if (Test-Path $activatePath) {
    & $activatePath
} else {
    Write-Host "Virtual environment not found" -ForegroundColor Red
    exit 1
}

try {
    # Run tests with coverage
    & python -m pytest tests\ -v --cov=src --cov-report=html --cov-report=term-missing
    Write-Host "Tests completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Tests failed: $_" -ForegroundColor Red
    exit 1
}
'@
    
    $testScript | Out-File -FilePath "scripts\test.ps1" -Encoding UTF8
    
    # Quality checker script (PowerShell version)
    $qualityScript = @'
# Code quality checker script for Windows/PowerShell

Write-Host "Running code quality checks..." -ForegroundColor Blue

# Activate virtual environment
$activatePath = ".\.venv\Scripts\Activate.ps1"
if (Test-Path $activatePath) {
    & $activatePath
} else {
    Write-Host "Virtual environment not found" -ForegroundColor Red
    exit 1
}

try {
    Write-Host "Formatting code..." -ForegroundColor Yellow
    & python -m black src\ tests\

    Write-Host "Sorting imports..." -ForegroundColor Yellow
    & python -m isort src\ tests\

    Write-Host "Linting code..." -ForegroundColor Yellow
    & python -m flake8 src\ tests\

    Write-Host "Type checking..." -ForegroundColor Yellow
    & python -m mypy src\

    Write-Host "All quality checks passed!" -ForegroundColor Green
}
catch {
    Write-Host "Quality checks failed: $_" -ForegroundColor Red
    exit 1
}
'@
    
    $qualityScript | Out-File -FilePath "scripts\quality.ps1" -Encoding UTF8
    
    # Also create bash versions for cross-platform compatibility
    $testScriptBash = @'
#!/bin/bash
# Test runner script

set -e

echo "Running test suite..."

# Activate virtual environment
if [ -f ".venv/Scripts/Activate.ps1" ]; then
    # Windows environment
    if command -v pwsh >/dev/null 2>&1; then
        pwsh -ExecutionPolicy Bypass -Command ". .\.venv\Scripts\Activate.ps1; python -m pytest tests\ -v --cov=src --cov-report=html --cov-report=term-missing"
    else
        echo "PowerShell not found. Please run scripts\test.ps1 instead."
        exit 1
    fi
elif [ -f ".venv/bin/activate" ]; then
    # Unix environment
    source .venv/bin/activate
    python -m pytest tests/ -v --cov=src --cov-report=html --cov-report=term-missing
fi

echo "Tests completed successfully!"
'@
    
    $testScriptBash | Out-File -FilePath "scripts\test.sh" -Encoding UTF8
    
    $qualityScriptBash = @'
#!/bin/bash
# Code quality checker script

set -e

echo "Running code quality checks..."

# Activate virtual environment
if [ -f ".venv/Scripts/Activate.ps1" ]; then
    # Windows environment
    if command -v pwsh >/dev/null 2>&1; then
        pwsh -ExecutionPolicy Bypass -Command ". .\.venv\Scripts\Activate.ps1; python -m black src\ tests\; python -m isort src\ tests\; python -m flake8 src\ tests\; python -m mypy src\"
    else
        echo "PowerShell not found. Please run scripts\quality.ps1 instead."
        exit 1
    fi
elif [ -f ".venv/bin/activate" ]; then
    # Unix environment
    source .venv/bin/activate
    python -m black src/ tests/
    python -m isort src/ tests/
    python -m flake8 src/ tests/
    python -m mypy src/
fi

echo "All quality checks passed!"
'@
    
    $qualityScriptBash | Out-File -FilePath "scripts\quality.sh" -Encoding UTF8
    
    Write-Success "Utility scripts created"
    return $true
}

# Function to create initial commit
function New-InitialCommit {
    param([string]$ProjectName)
    
    Write-Status "Creating initial commit..."
    
    try {
        & git add .
        & git commit -m "Setup: Project initialization - Bootstrap complete with Claude TDD workflow"
        Write-Success "Initial commit created"
        return $true
    }
    catch {
        Write-Error "Failed to create initial commit: $_"
        return $false
    }
}

# Function to setup complete git environment
function Initialize-GitEnvironment {
    param([string]$ProjectName)
    
    if (-not (Initialize-GitRepository)) { return $false }
    if (-not (New-GitHooks)) { return $false }
    if (-not (New-UtilityScripts)) { return $false }
    if (-not (New-InitialCommit $ProjectName)) { return $false }
    
    return $true
}