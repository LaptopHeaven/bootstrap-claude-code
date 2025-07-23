#!/bin/bash

# Python environment setup module for Claude Python Bootstrap
# Handles virtual environment creation, dependency installation, and Python configuration

# Source core utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

# Function to create Python virtual environment
create_virtual_environment() {
    print_status "Creating Python virtual environment..."
    python3 -m venv .venv
    
    # Activate virtual environment
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        source .venv/Scripts/activate
    else
        source .venv/bin/activate
    fi
    
    print_success "Virtual environment created and activated"
}

# Function to upgrade pip
upgrade_pip() {
    print_status "Upgrading pip..."
    pip install --upgrade pip
    print_success "Pip upgraded"
}

# Function to create requirements files
create_requirements_files() {
    local python_version="$1"
    
    print_status "Creating requirements files..."
    
    # Development requirements
    cat > requirements-dev.txt << EOF
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
EOF

    # Main requirements file
    cat > requirements.txt << EOF
# Add your project dependencies here
# Example:
# requests>=2.28.0
# fastapi>=0.95.0
EOF

    print_success "Requirements files created"
}

# Function to install development dependencies
install_dev_dependencies() {
    print_status "Installing development dependencies..."
    pip install -r requirements-dev.txt
    print_success "Development dependencies installed"
}

# Function to create pytest configuration
create_pytest_config() {
    print_status "Creating pytest configuration..."
    cat > pytest.ini << EOF
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
EOF
    print_success "Pytest configuration created"
}

# Function to create pyproject.toml
create_pyproject_config() {
    local project_name="$1"
    local project_description="$2"
    local python_version="$3"
    
    print_status "Creating pyproject.toml..."
    cat > pyproject.toml << EOF
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "$project_name"
version = "0.1.0"
description = "$project_description"
requires-python = ">=$python_version"
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
include = '\\.pyi?$'
extend-exclude = '''
/(
  # directories
  \\.eggs
  | \\.git
  | \\.hg
  | \\.mypy_cache
  | \\.tox
  | \\.venv
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
python_version = "$python_version"
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
EOF
    print_success "Project configuration created"
}

# Function to create Python package structure
create_python_package() {
    local package_name="$1"
    local project_name="$2"
    local project_description="$3"
    
    print_status "Creating Python package structure..."
    
    # Main package __init__.py
    cat > "src/$package_name/__init__.py" << EOF
"""$project_description"""

__version__ = "0.1.0"
__author__ = "Claude Agent"
EOF
    
    # Main module
    cat > "src/$package_name/main.py" << EOF
"""Main module for $project_name."""


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
EOF
    
    # Test __init__.py files
    touch tests/__init__.py
    touch tests/unit/__init__.py
    touch tests/integration/__init__.py
    
    print_success "Python package structure created"
}

# Function to create sample tests
create_sample_tests() {
    local package_name="$1"
    local project_name="$2"
    
    print_status "Creating sample tests..."
    
    # Sample unit test
    cat > tests/unit/test_main.py << EOF
"""Unit tests for main module."""

import pytest
from src.${package_name}.main import hello_world


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
EOF
    
    # Sample integration test
    cat > tests/integration/test_integration.py << EOF
"""Integration tests for $project_name."""

import subprocess
import sys
from pathlib import Path


def test_main_module_runs():
    """Test that the main module can be executed."""
    project_root = Path(__file__).parent.parent.parent
    main_path = project_root / "src" / "${package_name}" / "main.py"
    
    result = subprocess.run(
        [sys.executable, str(main_path)],
        capture_output=True,
        text=True,
        cwd=project_root
    )
    
    assert result.returncode == 0
    assert "Hello, World!" in result.stdout
EOF
    
    print_success "Sample tests created"
}

# Function to create .gitignore
create_gitignore() {
    print_status "Creating .gitignore..."
    cat > .gitignore << 'EOF'
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
EOF
    print_success ".gitignore created"
}

# Function to run initial test verification
verify_python_setup() {
    print_status "Verifying Python setup..."
    pytest tests/ -v
    if [ $? -eq 0 ]; then
        print_success "Python setup verification passed"
        return 0
    else
        print_error "Python setup verification failed"
        return 1
    fi
}

# Main function to setup complete Python environment
setup_python_environment() {
    local project_name="$1"
    local project_description="$2"
    local python_version="$3"
    local package_name
    
    package_name=$(get_package_name "$project_name")
    
    print_status "Setting up Python environment for: $project_name"
    print_status "Package name: $package_name"
    print_status "Description: $project_description"
    print_status "Python version: $python_version"
    
    create_virtual_environment || return 1
    upgrade_pip || return 1
    create_requirements_files "$python_version" || return 1
    install_dev_dependencies || return 1
    create_pytest_config || return 1
    create_pyproject_config "$project_name" "$project_description" "$python_version" || return 1
    create_gitignore || return 1
    create_python_package "$package_name" "$project_name" "$project_description" || return 1
    create_sample_tests "$package_name" "$project_name" || return 1
    verify_python_setup || return 1
    
    return 0
}

# Export functions for use in other modules
export -f create_virtual_environment upgrade_pip create_requirements_files
export -f install_dev_dependencies create_pytest_config create_pyproject_config
export -f create_python_package create_sample_tests create_gitignore
export -f verify_python_setup setup_python_environment