#!/bin/bash

# Git repository management module for Claude Python Bootstrap
# Handles git initialization, hooks setup, and initial commit

# Source core utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

# Function to initialize git repository
initialize_git_repository() {
    print_status "Initializing git repository..."
    git init --initial-branch=main
    print_success "Git repository initialized"
}

# Function to create git hooks
setup_git_hooks() {
    print_status "Setting up git hooks..."
    mkdir -p .git/hooks
    
    # Create commit-msg hook
    cat > .git/hooks/commit-msg << 'EOF'
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
EOF
    
    # Create pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
# Run quality checks before commit

# Activate virtual environment
if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
elif [ -f ".venv/Scripts/activate" ]; then
    source .venv/Scripts/activate
fi

echo "Running pre-commit quality checks..."

# Check formatting
if ! black --check src/ tests/ 2>/dev/null; then
    echo "Code formatting issues found. Run 'black src/ tests/' to fix."
    exit 1
fi

# Check imports
if ! isort --check-only src/ tests/ 2>/dev/null; then
    echo "Import sorting issues found. Run 'isort src/ tests/' to fix."
    exit 1
fi

# Check linting
if ! flake8 src/ tests/ 2>/dev/null; then
    echo "Linting issues found. Fix them before committing."
    exit 1
fi

# Run tests
if ! pytest tests/ -q 2>/dev/null; then
    echo "Tests are failing. Fix them before committing."
    exit 1
fi

echo "All pre-commit checks passed!"
EOF
    
    chmod +x .git/hooks/commit-msg .git/hooks/pre-commit
    print_success "Git hooks configured"
}

# Function to create utility scripts
create_utility_scripts() {
    print_status "Creating utility scripts..."
    mkdir -p scripts
    
    # Test runner script
    cat > scripts/test.sh << 'EOF'
#!/bin/bash
# Test runner script

set -e

echo "Running test suite..."

# Activate virtual environment
if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
elif [ -f ".venv/Scripts/activate" ]; then
    source .venv/Scripts/activate
fi

# Run tests with coverage
pytest tests/ -v --cov=src --cov-report=html --cov-report=term-missing

echo "Tests completed successfully!"
EOF
    
    # Quality checker script
    cat > scripts/quality.sh << 'EOF'
#!/bin/bash
# Code quality checker script

set -e

echo "Running code quality checks..."

# Activate virtual environment
if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
elif [ -f ".venv/Scripts/activate" ]; then
    source .venv/Scripts/activate
fi

echo "Formatting code..."
black src/ tests/

echo "Sorting imports..."
isort src/ tests/

echo "Linting code..."
flake8 src/ tests/

echo "Type checking..."
mypy src/

echo "All quality checks passed!"
EOF
    
    chmod +x scripts/test.sh scripts/quality.sh
    print_success "Utility scripts created"
}

# Function to create initial commit
create_initial_commit() {
    local project_name="$1"
    
    print_status "Creating initial commit..."
    git add .
    git commit -m "Setup: Project initialization - Bootstrap complete with Claude TDD workflow"
    print_success "Initial commit created"
}

# Function to setup complete git environment
setup_git_environment() {
    local project_name="$1"
    
    initialize_git_repository || return 1
    setup_git_hooks || return 1
    create_utility_scripts || return 1
    create_initial_commit "$project_name" || return 1
    
    return 0
}

# Export functions for use in other modules
export -f initialize_git_repository setup_git_hooks create_utility_scripts
export -f create_initial_commit setup_git_environment