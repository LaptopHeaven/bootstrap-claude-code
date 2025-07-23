#!/bin/bash

# Templates module for Claude Python Bootstrap
# Creates README and other documentation templates

# Source core utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

# Function to create README.md
create_readme() {
    local project_name="$1"
    local project_description="$2"
    local python_version="$3"
    local package_name="$4"
    
    print_status "Creating README.md..."
    cat > README.md << EOF
# $project_name

$project_description

## Overview

This project is managed using the Claude TDD + Scrumban workflow for systematic, test-driven development with clear progress tracking.

## Getting Started

### Prerequisites
- Python $python_version or higher
- Git

### Setup
\`\`\`bash
# Clone the repository
git clone <repository-url>
cd $project_name

# Activate virtual environment
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt -r requirements-dev.txt

# Verify setup
pytest tests/ -v
\`\`\`

### Running Tests
\`\`\`bash
# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ -v --cov=src --cov-report=html

# Run only unit tests
pytest tests/unit/ -v

# Run only integration tests
pytest tests/integration/ -v
\`\`\`

### Code Quality
\`\`\`bash
# Format code
black src/ tests/

# Lint code
flake8 src/ tests/

# Sort imports
isort src/ tests/

# Type checking
mypy src/

# Run all quality checks
black src/ tests/ && flake8 src/ tests/ && isort src/ tests/ && mypy src/
\`\`\`

## Development Workflow

This project follows the Claude TDD + Scrumban workflow:

1. **Read the PRD:** See \`.claude/prd.md\` for requirements
2. **Check the Board:** See \`.claude/scrumban.md\` for current status  
3. **Follow TDD:** Red → Green → Refactor cycle
4. **Commit Frequently:** Use structured commit messages
5. **Review Progress:** Update scrumban board after changes

### Commit Message Format
\`\`\`
[Type]: [Feature] - [Description]
\`\`\`

Types: Red, Green, Refactor, Reset, Docs, Setup

### TDD Cycle
1. **Red:** Write failing test (\`pytest tests/ -v\`)
2. **Green:** Implement minimal code to pass (\`pytest tests/ -v\`)
3. **Refactor:** Clean up code (\`pytest tests/ -v\`)

## Project Structure
\`\`\`
├── .claude/              # Claude agent tracking and state files
│   ├── scrumban.md       # Current work status board
│   ├── prd.md            # Product requirements document
│   ├── decisions.md      # Technical decisions log
│   ├── project.md        # Overall project context and status
│   ├── frontend.md       # Frontend domain context
│   ├── backend.md        # Backend domain context  
│   ├── reviewer.md       # Review domain context
│   ├── checkpoint_template.md  # Template for cross-domain communication
│   └── logs/             # Organized logging system
│       ├── system.md     # Infrastructure and setup logs
│       ├── project.md    # Project-level changes and decisions
│       └── debug.md      # Development issues and debugging
├── src/
│   └── ${package_name}/  # Main application code
├── tests/
│   ├── unit/             # Unit tests
│   └── integration/      # Integration tests
├── docs/                 # Documentation
├── scripts/              # Utility scripts
├── requirements.txt      # Production dependencies
├── requirements-dev.txt  # Development dependencies
├── pytest.ini           # Test configuration
├── pyproject.toml        # Project configuration
├── CLAUDE.md             # Main Claude agent workflow instructions
└── README.md             # This file
\`\`\`

## Quality Gates

All code must pass:
- [ ] Tests (\`pytest tests/ -v\`)
- [ ] Formatting (\`black --check src/ tests/\`)
- [ ] Linting (\`flake8 src/ tests/\`)
- [ ] Import sorting (\`isort --check-only src/ tests/\`)
- [ ] Type checking (\`mypy src/\`)
- [ ] Coverage ≥ 80%

## Claude Agent Instructions

This project uses domain-specific Claude agents with session management:

### Getting Started with Claude
1. **Assign Domain:** Choose Frontend, Backend, or Reviewer focus
2. **Sign In:** Claude must execute sign-in protocol (read all MD files, ask questions)
3. **Work:** Follow TDD cycle within assigned domain
4. **Update:** Use /update command regularly to maintain state
5. **Sign Out:** Claude must execute sign-out protocol (update all MD files)

### Session Commands for Claude
\`\`\`
/signin [domain]     # Start session with context loading
/signout            # End session with state preservation  
/update             # Force refresh of all documentation
/checkpoint [domain] # Communicate with other domains
/status             # Quick status check
/logs [type]        # Review or add to logs
\`\`\`

### Domain Assignment
- **Frontend:** UI/UX, client-side code, user interactions
- **Backend:** APIs, databases, server-side logic  
- **Reviewer:** Code review, quality assurance, architecture

### Quick Start for Claude
\`\`\`bash
# Activate environment
source .venv/bin/activate

# Read main instructions
cat CLAUDE.md

# Execute sign-in protocol
/signin backend

# Check current status
cat .claude/scrumban.md

# Start working on highest priority item using TDD
\`\`\`

## Contributing

1. Follow the TDD workflow outlined in \`CLAUDE.md\`
2. Ensure all quality gates pass before committing
3. Update the scrumban board as work progresses
4. Use structured commit messages

## License

[Add your license here]
EOF
    print_success "README.md created"
}

# Function to create example usage documentation
create_usage_examples() {
    local project_name="$1"
    local package_name="$2"
    
    print_status "Creating usage examples..."
    mkdir -p docs
    
    cat > docs/USAGE.md << EOF
# Usage Examples

## Basic Usage

### Using the Hello World Function

\`\`\`python
from src.${package_name}.main import hello_world

# Basic usage
print(hello_world())  # Output: Hello, World!

# With custom name
print(hello_world("Alice"))  # Output: Hello, Alice!

# Empty string handling
print(hello_world(""))  # Output: Hello, !
\`\`\`

### Running as Module

\`\`\`bash
# Run the main module directly
python -m src.${package_name}.main

# Or run the main.py file
python src/${package_name}/main.py
\`\`\`

## Development Usage

### Using Individual Modules

If you want to use the bootstrap modules individually:

\`\`\`bash
# Source individual modules
source lib/core.sh
source lib/python.sh
source lib/claude.sh

# Use specific functions
validate_project_name "my-project"
create_python_package "my_project" "My Project" "A test project"
create_claude_workflow_files "my-project" "A test project" "3.12"
\`\`\`

### Custom Bootstrap Workflow

\`\`\`bash
#!/bin/bash
# Custom bootstrap example

# Source required modules
source lib/core.sh
source lib/python.sh
source lib/git.sh

# Setup basic project without Claude workflow
PROJECT_NAME="simple-project"
PACKAGE_NAME=\$(get_package_name "\$PROJECT_NAME")

validate_project_name "\$PROJECT_NAME"
create_basic_structure "\$PROJECT_NAME" "\$PACKAGE_NAME"
cd "\$PROJECT_NAME"
setup_python_environment "\$PROJECT_NAME" "Simple Python project" "3.12"
setup_git_environment "\$PROJECT_NAME"
\`\`\`

## Testing Examples

### Running Specific Tests

\`\`\`bash
# Run a specific test file
pytest tests/unit/test_main.py -v

# Run a specific test function
pytest tests/unit/test_main.py::TestHelloWorld::test_hello_world_default -v

# Run tests with specific markers
pytest -m "not slow" -v

# Run integration tests only
pytest tests/integration/ -v
\`\`\`

### Code Coverage Examples

\`\`\`bash
# Generate HTML coverage report
pytest tests/ --cov=src --cov-report=html
# View report: open htmlcov/index.html

# Generate terminal coverage report
pytest tests/ --cov=src --cov-report=term-missing

# Set coverage threshold
pytest tests/ --cov=src --cov-fail-under=80
\`\`\`

## Quality Assurance Examples

### Code Formatting

\`\`\`bash
# Check if code needs formatting
black --check src/ tests/

# Format code
black src/ tests/

# Show what would be changed without making changes
black --diff src/ tests/
\`\`\`

### Linting and Type Checking

\`\`\`bash
# Run flake8 linting
flake8 src/ tests/

# Run mypy type checking
mypy src/

# Check import sorting
isort --check-only src/ tests/

# Fix import sorting
isort src/ tests/
\`\`\`

## Claude Workflow Examples

### Starting a Development Session

\`\`\`bash
# Read the main workflow instructions
cat CLAUDE.md

# Review current project state
cat .claude/project.md
cat .claude/scrumban.md

# Start a backend development session
# (This would be done by Claude agent)
# /signin backend
\`\`\`

### Updating Project Documentation

\`\`\`bash
# Review all project documentation
ls -la .claude/
cat .claude/*.md

# Check logs for any issues
cat .claude/logs/*.md
\`\`\`

## Troubleshooting

### Common Issues

1. **Virtual Environment Not Activated**
   \`\`\`bash
   # Activate the virtual environment first
   source .venv/bin/activate  # On Linux/Mac
   .venv\\Scripts\\activate    # On Windows
   \`\`\`

2. **Import Errors in Tests**
   \`\`\`bash
   # Make sure you're running from project root
   pwd  # Should show your project directory
   pytest tests/ -v
   \`\`\`

3. **Code Quality Issues**
   \`\`\`bash
   # Run the quality script to fix most issues
   ./scripts/quality.sh
   \`\`\`

4. **Test Failures**
   \`\`\`bash
   # Run tests with more verbose output
   pytest tests/ -v -s
   
   # Run a specific failing test
   pytest tests/unit/test_main.py::test_specific_function -v -s
   \`\`\`

### Getting Help

- Read \`CLAUDE.md\` for complete workflow instructions
- Check \`.claude/logs/debug.md\` for development issues
- Review \`.claude/prd.md\` for requirements and acceptance criteria
- Look at \`.claude/decisions.md\` for technical decisions made
EOF
    print_success "Usage examples created"
}

# Function to create development guide
create_development_guide() {
    print_status "Creating development guide..."
    
    cat > docs/DEVELOPMENT.md << EOF
# Development Guide

## Project Architecture

This project follows a modular architecture with clear separation of concerns:

### Module Structure

- **lib/core.sh** - Shared utilities, validation, and common functions
- **lib/python.sh** - Python environment setup and package management
- **lib/git.sh** - Git repository initialization and hook setup
- **lib/claude.sh** - Claude workflow files and documentation generation
- **lib/templates.sh** - README and documentation template creation

### Claude Workflow Integration

The project includes a comprehensive Claude agent workflow system:

#### Domain-Based Development
- **Frontend Domain** - UI/UX, client-side code
- **Backend Domain** - APIs, business logic, data management
- **Reviewer Domain** - Code review and quality assurance

#### Session Management
Each Claude session follows a structured protocol:

1. **Sign-In Protocol**
   - Domain assignment
   - State review (read all .claude/*.md files)
   - Context questions
   - Task confirmation

2. **Development Workflow**
   - TDD cycle (Red → Green → Refactor)
   - Continuous state management
   - Cross-domain coordination
   - Progress tracking

3. **Sign-Out Protocol**
   - Documentation updates
   - Cross-domain communication
   - State preservation

## Development Process

### Test-Driven Development (TDD)

1. **Red Phase** - Write a failing test
   \`\`\`bash
   # Write test that describes desired behavior
   pytest tests/unit/test_new_feature.py -v  # Should fail
   \`\`\`

2. **Green Phase** - Make the test pass
   \`\`\`bash
   # Implement minimal code to pass the test
   pytest tests/unit/test_new_feature.py -v  # Should pass
   \`\`\`

3. **Refactor Phase** - Clean up the code
   \`\`\`bash
   # Improve code while maintaining test passage
   pytest tests/ -v  # All tests should still pass
   \`\`\`

### Quality Gates

Before any commit, ensure:

\`\`\`bash
# All tests pass
pytest tests/ -v

# Code is properly formatted
black --check src/ tests/

# Code passes linting
flake8 src/ tests/

# Imports are sorted
isort --check-only src/ tests/

# Type checking passes
mypy src/

# Coverage threshold is met
pytest tests/ --cov=src --cov-fail-under=80
\`\`\`

### Commit Standards

Follow structured commit messages:

\`\`\`
[Type]: [Feature] - [Description]

Types:
- Red: Added failing tests
- Green: Implementation to pass tests  
- Refactor: Code cleanup without functional changes
- Reset: Reverted failed approach
- Docs: Documentation updates
- Setup: Project configuration changes
\`\`\`

## Scrumban Workflow

### Board Management

The project uses a Scrumban board with these columns:

| Backlog | WIP (max 3) | Review | Testing | Blocked | Done |
|---------|-------------|--------|---------|---------|------|
| Prioritized features | Active development | Code review | Integration testing | External blockers | Completed items |

### Movement Criteria

**Backlog → WIP:**
- Clear acceptance criteria
- Dependencies resolved
- Test approach planned

**WIP → Review:**
- All tests pass
- Code formatted and linted
- Clean commit history

**Review → Testing:**
- Code review approved
- No architectural concerns
- Integration ready

**Testing → Done:**
- All acceptance criteria met
- Integration tests pass
- Documentation updated

## File Organization

### Core Project Files

\`\`\`
src/[package]/          # Main application code
├── __init__.py         # Package initialization
├── main.py            # Main application entry point
└── [modules].py       # Additional modules

tests/                  # Test suite
├── __init__.py
├── unit/              # Unit tests
│   ├── __init__.py
│   └── test_*.py
└── integration/       # Integration tests
    ├── __init__.py
    └── test_*.py
\`\`\`

### Claude Workflow Files

\`\`\`
.claude/               # Claude agent state and workflow
├── project.md         # Overall project context
├── scrumban.md        # Work board state
├── prd.md            # Product requirements
├── decisions.md       # Technical decisions log
├── frontend.md        # Frontend domain context
├── backend.md         # Backend domain context
├── reviewer.md        # Review domain context
├── checkpoint_template.md  # Cross-domain communication template
└── logs/             # Organized logging
    ├── system.md     # Infrastructure logs
    ├── project.md    # Project changes
    └── debug.md      # Development issues
\`\`\`

### Configuration Files

\`\`\`
pytest.ini            # Test configuration
pyproject.toml        # Project metadata and tool config
requirements.txt      # Production dependencies
requirements-dev.txt  # Development dependencies
.gitignore           # Git ignore patterns
\`\`\`

## Working with Claude Agents

### Starting a Session

1. **Review Current State**
   \`\`\`bash
   # Check project status
   cat .claude/project.md
   cat .claude/scrumban.md
   \`\`\`

2. **Assign Domain**
   Choose between Frontend, Backend, or Reviewer

3. **Execute Sign-In Protocol**
   - Read all documentation files
   - Ask clarifying questions
   - Confirm session goals

### During Development

1. **Follow TDD Cycle**
   - Write failing tests first
   - Implement minimal passing code
   - Refactor for quality

2. **Update Documentation**
   - Keep scrumban board current
   - Log decisions and issues
   - Update domain context

3. **Cross-Domain Communication**
   - Use checkpoint files for coordination
   - Document integration points
   - Communicate blockers clearly

### Ending a Session

1. **Update All Documentation**
   - Refresh all .claude/*.md files
   - Remove outdated information
   - Log session outcomes

2. **Create Checkpoints**
   - Document handoffs to other domains
   - Note integration requirements
   - Communicate blockers

3. **Preserve State**
   - Commit all changes
   - Document next steps
   - Update project status

## Troubleshooting

### Common Development Issues

1. **Import Errors**
   - Ensure virtual environment is activated
   - Check PYTHONPATH if necessary
   - Verify package structure

2. **Test Failures**
   - Run tests with verbose output
   - Check test isolation
   - Verify test data setup

3. **Quality Gate Failures**
   - Use automated formatting tools
   - Address linting issues systematically
   - Add type hints for mypy

4. **Git Hook Failures**
   - Run quality checks manually first
   - Fix issues before committing
   - Use --no-verify only in emergencies

### Recovery Procedures

1. **Derailed Implementation**
   - Document issue in debug log
   - Revert to last good state
   - Restart with clearer approach

2. **Cross-Domain Conflicts**
   - Create checkpoint communication
   - Schedule coordination session
   - Update integration documentation

3. **Quality Degradation**
   - Run full quality check suite
   - Address issues systematically
   - Update quality standards if needed

## Best Practices

### Code Quality
- Write descriptive test names
- Keep functions small and focused
- Use type hints consistently
- Write clear docstrings

### Documentation
- Update documentation continuously
- Remove outdated information promptly
- Keep state files current
- Log decisions and rationale

### Workflow
- Follow TDD cycle strictly
- Update scrumban board frequently
- Communicate across domains clearly
- Commit small, focused changes

### Error Handling
- Log issues promptly and clearly
- Revert problematic changes quickly
- Learn from failures and update process
- Share lessons across domains
EOF
    print_success "Development guide created"
}

# Main function to create all templates
create_all_templates() {
    local project_name="$1"
    local project_description="$2"
    local python_version="$3"
    local package_name="$4"
    
    create_readme "$project_name" "$project_description" "$python_version" "$package_name" || return 1
    create_usage_examples "$project_name" "$package_name" || return 1
    create_development_guide || return 1
    
    return 0
}

# Export functions for use in other modules
export -f create_readme create_usage_examples create_development_guide create_all_templates