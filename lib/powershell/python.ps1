# Python environment setup module for Claude Python Bootstrap - PowerShell Version
# Handles virtual environment creation, dependency installation, and Python configuration

# Dot-source core utilities
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir\core.ps1"

# Function to create Python virtual environment
function New-VirtualEnvironment {
    Write-Status "Creating Python virtual environment..."
    
    try {
        & $script:PYTHON_CMD -m venv .venv
        Write-Success "Virtual environment created"
        return $true
    }
    catch {
        Write-Error "Failed to create virtual environment: $_"
        return $false
    }
}

# Function to upgrade pip
function Update-Pip {
    Write-Status "Upgrading pip..."
    
    if (Enable-VirtualEnvironment) {
        try {
            & python -m pip install --upgrade pip
            Write-Success "Pip upgraded"
            return $true
        }
        catch {
            Write-Error "Failed to upgrade pip: $_"
            return $false
        }
    }
    else {
        Write-Error "Could not activate virtual environment"
        return $false
    }
}

# Function to create requirements files
function New-RequirementsFiles {
    param([string]$PythonVersion)
    
    Write-Status "Creating requirements files..."
    
    # Development requirements
    $devRequirements = @"
# Testing
pytest>=7.0.0
pytest-cov>=4.0.0
pytest-mock>=3.10.0
pytest-asyncio>=0.21.0

# Code Quality
black>=23.0.0
flake8>=6.0.0
mypy>=1.0.0
isort>=5.12.0

# Development Tools
pre-commit>=3.0.0
rope>=1.7.0
"@
    
    $devRequirements | Out-File -FilePath "requirements-dev.txt" -Encoding UTF8
    
    # Main requirements file
    $mainRequirements = @"
# Add your project dependencies here
# Example:
# requests>=2.28.0
# fastapi>=0.95.0
"@
    
    $mainRequirements | Out-File -FilePath "requirements.txt" -Encoding UTF8
    
    Write-Success "Requirements files created"
    return $true
}

# Function to install development dependencies
function Install-DevDependencies {
    Write-Status "Installing development dependencies..."
    
    if (Enable-VirtualEnvironment) {
        try {
            & pip install -r requirements-dev.txt
            Write-Success "Development dependencies installed"
            return $true
        }
        catch {
            Write-Error "Failed to install development dependencies: $_"
            return $false
        }
    }
    else {
        Write-Error "Could not activate virtual environment"
        return $false
    }
}

# Function to create pytest configuration
function New-PytestConfig {
    Write-Status "Creating pytest configuration..."
    
    $pytestConfig = @"
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = 
    --verbose
    --tb=short
    --cov=src
    --cov-report=html
    --cov-report=term-missing
    --cov-fail-under=80
markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    integration: marks tests as integration tests
"@
    
    $pytestConfig | Out-File -FilePath "pytest.ini" -Encoding UTF8
    Write-Success "Pytest configuration created"
    return $true
}

# Function to create pyproject.toml
function New-PyprojectConfig {
    param(
        [string]$ProjectName,
        [string]$ProjectDescription,
        [string]$PythonVersion
    )
    
    Write-Status "Creating pyproject.toml..."
    
    $pyprojectConfig = @"
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "$ProjectName"
version = "0.1.0"
description = "$ProjectDescription"
requires-python = ">=$PythonVersion"
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "pytest-mock>=3.10.0",
    "black>=23.0.0",
    "flake8>=6.0.0",
    "mypy>=1.0.0",
    "isort>=5.12.0",
]

[tool.black]
line-length = 88
target-version = ['py312']
include = '\.pyi?$'
extend-exclude = '''
/(
  # directories
  \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | build
  | dist
)/
'''

[tool.isort]
profile = "black"
multi_line_output = 3
include_trailing_comma = true
force_grid_wrap = 0
use_parentheses = true
ensure_newline_before_comments = true
line_length = 88

[tool.mypy]
python_version = "$PythonVersion"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_equality = true

[[tool.mypy.overrides]]
module = "tests.*"
disallow_untyped_defs = false
"@
    
    $pyprojectConfig | Out-File -FilePath "pyproject.toml" -Encoding UTF8
    Write-Success "Project configuration created"
    return $true
}

# Function to create Python package structure
function New-PythonPackage {
    param(
        [string]$PackageName,
        [string]$ProjectName,
        [string]$ProjectDescription
    )
    
    Write-Status "Creating Python package structure..."
    
    # Main package __init__.py
    $packageInit = @"
"""$ProjectDescription"""

__version__ = "0.1.0"
__author__ = "Claude Agent"
"@
    
    $packageInit | Out-File -FilePath "src\$PackageName\__init__.py" -Encoding UTF8
    
    # Main module
    $mainModule = @"
"""Main module for $ProjectName."""


def hello_world(name: str = "World") -> str:
    """
    Return a greeting message.
    
    Args:
        name: The name to greet
        
    Returns:
        A greeting message
    """
    return f"Hello, {name}!"


if __name__ == "__main__":
    print(hello_world())
"@
    
    $mainModule | Out-File -FilePath "src\$PackageName\main.py" -Encoding UTF8
    
    # Test __init__.py files
    "" | Out-File -FilePath "tests\__init__.py" -Encoding UTF8
    "" | Out-File -FilePath "tests\unit\__init__.py" -Encoding UTF8
    "" | Out-File -FilePath "tests\integration\__init__.py" -Encoding UTF8
    
    Write-Success "Python package structure created"
    return $true
}

# Function to create sample tests
function New-SampleTests {
    param(
        [string]$PackageName,
        [string]$ProjectName
    )
    
    Write-Status "Creating sample tests..."
    
    # Sample unit test
    $unitTest = @"
"""Unit tests for main module."""

import pytest
from src.${PackageName}.main import hello_world


class TestHelloWorld:
    """Test cases for hello_world function."""

    def test_hello_world_default(self):
        """Test hello_world with default parameter."""
        result = hello_world()
        assert result == "Hello, World!"

    def test_hello_world_with_name(self):
        """Test hello_world with custom name."""
        result = hello_world("Claude")
        assert result == "Hello, Claude!"

    def test_hello_world_empty_string(self):
        """Test hello_world with empty string."""
        result = hello_world("")
        assert result == "Hello, !"

    @pytest.mark.parametrize("name,expected", [
        ("Alice", "Hello, Alice!"),
        ("Bob", "Hello, Bob!"),
        ("123", "Hello, 123!"),
    ])
    def test_hello_world_parametrized(self, name, expected):
        """Test hello_world with various inputs."""
        result = hello_world(name)
        assert result == expected
"@
    
    $unitTest | Out-File -FilePath "tests\unit\test_main.py" -Encoding UTF8
    
    # Sample integration test
    $integrationTest = @"
"""Integration tests for $ProjectName."""

import subprocess
import sys
from pathlib import Path


def test_main_module_runs():
    """Test that the main module can be executed."""
    project_root = Path(__file__).parent.parent.parent
    main_path = project_root / "src" / "${PackageName}" / "main.py"
    
    result = subprocess.run(
        [sys.executable, str(main_path)],
        capture_output=True,
        text=True,
        cwd=project_root
    )
    
    assert result.returncode == 0
    assert "Hello, World!" in result.stdout
"@
    
    $integrationTest | Out-File -FilePath "tests\integration\test_integration.py" -Encoding UTF8
    
    Write-Success "Sample tests created"
    return $true
}

# Function to create .gitignore
function New-Gitignore {
    Write-Status "Creating .gitignore..."
    
    $gitignoreContent = @'
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
pip-wheel-metadata/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
*.manifest
*.spec

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# pipenv
Pipfile.lock

# PEP 582
__pypackages__/

# Celery stuff
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
'@
    
    $gitignoreContent | Out-File -FilePath ".gitignore" -Encoding UTF8
    Write-Success ".gitignore created"
    return $true
}

# Function to run initial test verification
function Test-PythonSetup {
    Write-Status "Verifying Python setup..."
    
    if (Enable-VirtualEnvironment) {
        try {
            & pytest tests\ -v
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Python setup verification passed"
                return $true
            }
            else {
                Write-Error "Python setup verification failed"
                return $false
            }
        }
        catch {
            Write-Error "Python setup verification failed: $_"
            return $false
        }
    }
    else {
        Write-Error "Could not activate virtual environment for testing"
        return $false
    }
}

# Main function to setup complete Python environment
function Initialize-PythonEnvironment {
    param(
        [string]$ProjectName,
        [string]$ProjectDescription,
        [string]$PythonVersion
    )
    
    $packageName = Get-PackageName $ProjectName
    
    Write-Status "Setting up Python environment for: $ProjectName"
    Write-Status "Package name: $packageName"
    Write-Status "Description: $ProjectDescription"
    Write-Status "Python version: $PythonVersion"
    
    if (-not (New-VirtualEnvironment)) { return $false }
    if (-not (Update-Pip)) { return $false }
    if (-not (New-RequirementsFiles $PythonVersion)) { return $false }
    if (-not (Install-DevDependencies)) { return $false }
    if (-not (New-PytestConfig)) { return $false }
    if (-not (New-PyprojectConfig $ProjectName $ProjectDescription $PythonVersion)) { return $false }
    if (-not (New-Gitignore)) { return $false }
    if (-not (New-PythonPackage $packageName $ProjectName $ProjectDescription)) { return $false }
    if (-not (New-SampleTests $packageName $ProjectName)) { return $false }
    if (-not (Test-PythonSetup)) { return $false }
    
    return $true
}