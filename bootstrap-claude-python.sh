#!/bin/bash

# Claude Python Project Bootstrap Script
# Creates a new Python project configured for Claude TDD + Scrumban workflow

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Parse arguments
PROJECT_NAME=""
PROJECT_DESCRIPTION=""
PYTHON_VERSION="3.12"

# Show usage
show_usage() {
    echo "Usage: $0 <project_name> [options]"
    echo ""
    echo "Options:"
    echo "  -d, --description <desc>   Project description"
    echo "  -p, --python <version>     Python version (default: 3.12)"
    echo "  -h, --help                 Show this help"
    echo ""
    echo "Example:"
    echo "  $0 my-awesome-api -d \"REST API for awesome things\" -p 3.11"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--description)
            PROJECT_DESCRIPTION="$2"
            shift 2
            ;;
        -p|--python)
            PYTHON_VERSION="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -*)
            print_error "Unknown option $1"
            show_usage
            exit 1
            ;;
        *)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$1"
            else
                print_error "Too many arguments"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate project name
if [ -z "$PROJECT_NAME" ]; then
    print_error "Project name is required"
    show_usage
    exit 1
fi

# Validate project name format
if [[ ! "$PROJECT_NAME" =~ ^[a-z][a-z0-9_-]*$ ]]; then
    print_error "Project name must start with a letter and contain only lowercase letters, numbers, hyphens, and underscores"
    exit 1
fi

# Set default description if not provided
if [ -z "$PROJECT_DESCRIPTION" ]; then
    PROJECT_DESCRIPTION="A Python project managed by Claude using TDD + Scrumban workflow"
fi

# Convert project name to Python package name (replace hyphens with underscores)
PACKAGE_NAME=$(echo "$PROJECT_NAME" | tr '-' '_')

print_status "Creating Claude-managed Python project: $PROJECT_NAME"
print_status "Package name: $PACKAGE_NAME"
print_status "Description: $PROJECT_DESCRIPTION"
print_status "Python version: $PYTHON_VERSION"

# Check prerequisites
print_status "Checking prerequisites..."

if ! command_exists python3; then
    print_error "Python 3 is not installed"
    exit 1
fi

if ! command_exists git; then
    print_error "Git is not installed"
    exit 1
fi

# Check if directory already exists
if [ -d "$PROJECT_NAME" ]; then
    print_error "Directory $PROJECT_NAME already exists"
    exit 1
fi

# Create project directory
print_status "Creating project directory structure..."
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create directory structure
mkdir -p .claude
mkdir -p .claude/logs
mkdir -p "src/$PACKAGE_NAME"
mkdir -p tests/unit
mkdir -p tests/integration
mkdir -p docs
mkdir -p scripts

print_success "Directory structure created"

# Initialize git repository
print_status "Initializing git repository..."
git init --initial-branch=main
print_success "Git repository initialized"

# Create virtual environment
print_status "Creating Python virtual environment..."
python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate

# Upgrade pip
print_status "Upgrading pip..."
pip install --upgrade pip

# Install development dependencies
print_status "Installing development dependencies..."
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

pip install -r requirements-dev.txt

# Create main requirements file
cat > requirements.txt << EOF
# Add your project dependencies here
# Example:
# requests>=2.28.0
# fastapi>=0.95.0
EOF

print_success "Dependencies installed"

# Create .gitignore
print_status "Creating .gitignore..."
cat > .gitignore << EOF
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*\$py.class

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

# Create Python package structure
print_status "Creating Python package structure..."

# Main package __init__.py
cat > "src/$PACKAGE_NAME/__init__.py" << EOF
"""$PROJECT_DESCRIPTION"""

__version__ = "0.1.0"
__author__ = "Claude Agent"
EOF

# Main module
cat > "src/$PACKAGE_NAME/main.py" << EOF
"""Main module for $PROJECT_NAME."""


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

# Sample unit test
cat > tests/unit/test_main.py << EOF
"""Unit tests for main module."""

import pytest
from src.${PACKAGE_NAME}.main import hello_world


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
"""Integration tests for $PROJECT_NAME."""

import subprocess
import sys
from pathlib import Path


def test_main_module_runs():
    """Test that the main module can be executed."""
    project_root = Path(__file__).parent.parent.parent
    main_path = project_root / "src" / "${PACKAGE_NAME}" / "main.py"
    
    result = subprocess.run(
        [sys.executable, str(main_path)],
        capture_output=True,
        text=True,
        cwd=project_root
    )
    
    assert result.returncode == 0
    assert "Hello, World!" in result.stdout
EOF

print_success "Python package structure created"

# Create pytest configuration
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

# Create pyproject.toml
cat > pyproject.toml << EOF
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "$PROJECT_NAME"
version = "0.1.0"
description = "$PROJECT_DESCRIPTION"
requires-python = ">=$PYTHON_VERSION"
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
python_version = "$PYTHON_VERSION"
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

# Create Claude workflow files
print_status "Creating Claude workflow files..."

# CLAUDE.md (in project root)
cat > CLAUDE.md << 'EOF'
# CLAUDE.md - Development Agent Instructions

## Mission Statement

You are a disciplined software development agent. Your job is to build working software through systematic Test-Driven Development (TDD), maintain clear project tracking via Scrumban workflow, and deliver production-ready code that meets documented requirements.

**Core Principle:** Every change must be justified by a failing test. Every commit must advance the project toward completion. When things go sideways, revert and restart rather than fighting broken code.

**State Management Principle:** You are responsible for maintaining all project documentation. Update MD files continuously, remove outdated information, and ensure all state is current before ending sessions.

---

## Slash Commands (Use these for workflow control)

### `/signin [domain]`
**Purpose:** Start a new session with proper context loading  
**Usage:** `/signin backend` or `/signin frontend`  
**Action:** Execute full sign-in protocol including state review and questions

### `/signout`
**Purpose:** End session with complete state preservation  
**Action:** Execute full sign-out protocol including file updates and cross-domain communication

### `/update`
**Purpose:** Force refresh of all project documentation  
**Action:** 
- Review and update all MD files
- Remove outdated information
- Sync scrumban board with actual progress
- Update domain-specific context
- Log any changes made

### `/checkpoint [target_domain]`
**Purpose:** Create communication for another domain  
**Usage:** `/checkpoint frontend` or `/checkpoint backend`  
**Action:** Create `.claude/checkpoint_[target_domain].md` with relevant information

### `/status`
**Purpose:** Quick status check without full update  
**Action:** Display current scrumban board state and next priority

### `/logs [type]`
**Purpose:** Review or add to log files  
**Usage:** `/logs system` or `/logs debug` or `/logs project`  
**Action:** Show recent log entries or prompt for new log entry

### `/reset [scope]`
**Purpose:** Reset derailed work  
**Usage:** `/reset feature` or `/reset session`  
**Action:** Revert to last good state and restart with clear approach

---

## Domain Assignment & Session Management

### Sign-In Protocol (MANDATORY - Start every session)

1. **Declare Domain:** Choose your role for this session:
   - `Frontend` - UI/UX, client-side code, user interactions
   - `Backend` - APIs, databases, server-side logic, integrations
   - `Reviewer` - Code review, quality assurance, architecture decisions
   - `Fullstack` - End-to-end features (use sparingly)

2. **State Review:** Read ALL markdown files in order:
   - `CLAUDE.md` (this file) - Workflow and current instructions
   - `.claude/project.md` - Overall project status and context
   - `.claude/scrumban.md` - Current work board
   - `.claude/prd.md` - Product requirements
   - `.claude/decisions.md` - Technical decisions log
   - `.claude/[domain].md` - Your domain-specific context
   - `.claude/checkpoint_*.md` - Communications from other domains
   - `.claude/logs/` - Any relevant log files

3. **Context Questions:** Ask clarifying questions about:
   - Unclear requirements or acceptance criteria
   - Blockers or dependencies from other domains
   - Recent changes that might affect your work
   - Priority conflicts or scope questions

4. **Task Confirmation:** Confirm your understanding of:
   - Current priority from scrumban board
   - Expected deliverables for this session
   - Definition of done for current work
   - Any cross-domain dependencies

**Sign-In Format:**
```
## Sign-In: [Domain] - [Date/Time]

### Domain: [Frontend/Backend/Reviewer/Fullstack]

### State Review Complete:
- [ ] Read all project MD files
- [ ] Reviewed checkpoint communications
- [ ] Checked relevant logs

### Questions:
[List any clarifying questions]

### Session Goals:
[What you plan to accomplish this session]

### Dependencies:
[What you need from other domains]
```

### Sign-Out Protocol (MANDATORY - End every session)

1. **Update All Documentation:**
   - Remove outdated information from all MD files
   - Update scrumban board with current status
   - Log all changes and decisions made
   - Update your domain-specific context file

2. **Cross-Domain Communication:**
   - Create/update checkpoint files for other domains
   - Document any blockers or handoffs needed
   - Note integration points or shared concerns

3. **State Preservation:**
   - Ensure all work is committed with proper messages
   - Document next steps clearly
   - Record any issues or debugging info in logs

**Sign-Out Format:**
```
## Sign-Out: [Domain] - [Date/Time]

### Work Completed:
[Summary of what was accomplished]

### Files Updated:
- [ ] .claude/project.md
- [ ] .claude/scrumban.md
- [ ] .claude/[domain].md
- [ ] .claude/checkpoint_*.md (if needed)
- [ ] .claude/logs/ (if issues occurred)

### Communications to Other Domains:
[Any handoffs, blockers, or coordination needed]

### Next Session:
[Clear next steps for continuation]

### Issues/Concerns:
[Anything that needs attention]
```

---

## Development Workflow

### 1. Session Initialization (REQUIRED)

**Every session must start with sign-in:**
1. Execute `/signin [domain]` or manual sign-in protocol
2. Review all project documentation thoroughly  
3. Ask clarifying questions before starting work
4. Confirm session goals and priorities

**Never start coding without completing sign-in protocol.**

### 2. Domain-Specific TDD Cycle

**For each backlog item assigned to your domain:**

#### Frontend Domain
- **Red Phase:** Write failing component/UI tests
- **Green Phase:** Implement minimal UI to pass tests  
- **Refactor Phase:** Clean up components and styling
- **Integration:** Test with backend APIs

#### Backend Domain  
- **Red Phase:** Write failing API/logic tests
- **Green Phase:** Implement minimal backend logic
- **Refactor Phase:** Clean up architecture and performance
- **Integration:** Verify API contracts with frontend

#### Reviewer Domain
- **Review Phase:** Examine code quality and architecture
- **Test Phase:** Verify test coverage and edge cases
- **Integration Phase:** Check cross-domain compatibility
- **Documentation Phase:** Update technical decisions and patterns

### 3. Continuous State Management

**Throughout the session:**
- Update `.claude/[domain].md` with current context
- Log any issues in `.claude/logs/[type].md`
- Create checkpoint files for cross-domain communication
- Keep scrumban board synchronized with actual progress

**Use `/update` command:**
- After completing any major task
- When switching between features
- Before taking breaks or extended work
- When encountering blockers

### 4. Cross-Domain Coordination

**When you need input from another domain:**
1. Use `/checkpoint [domain]` to create communication
2. Document specific requirements or questions
3. Move your item to "Blocked" if waiting for response
4. Work on different item until unblocked

**When completing handoffs:**
1. Update relevant checkpoint files
2. Ensure all integration points are documented
3. Verify contracts/interfaces are clear
4. Test integration if possible

### 5. Session End (REQUIRED)

**Every session must end with sign-out:**
1. Execute `/signout` or manual sign-out protocol
2. Update all documentation with current state
3. Create checkpoint communications for other domains
4. Ensure all work is properly committed
5. Document clear next steps

**Never end a session without completing sign-out protocol.**

---

## Failure Recovery Protocol

**When implementation derails (signs include):**
- Tests passing but code doesn't meet requirements
- Implementation becoming overly complex  
- Uncertainty about next steps
- More than 3 commits without meaningful progress
- Cross-domain integration failures

**Recovery Steps:**
1. Use `/logs debug` to document the issue
2. Use `/reset feature` to revert to last good state
3. Update `.claude/[domain].md` with lessons learned
4. Create checkpoint file if other domains are affected
5. Restart with refined approach and clearer tests

**Major Issues:**
- Use `/logs system` for infrastructure problems
- Use `/checkpoint [domain]` to communicate blockers
- Update `.claude/project.md` with scope or priority changes

---

## Logging System

### Log Types and Usage

**System Logs (`.claude/logs/system.md`):**
- Infrastructure changes
- Deployment issues  
- Environment problems
- Tool configuration changes

**Project Logs (`.claude/logs/project.md`):**
- Scope changes
- Priority shifts
- Stakeholder feedback
- Major architectural decisions

**Debug Logs (`.claude/logs/debug.md`):**
- Failed implementations
- Complex debugging sessions
- Performance issues
- Integration problems

**Domain Logs (`.claude/logs/[domain].md`):**
- Domain-specific technical issues
- Library or framework problems
- Complex business logic challenges

### Log Entry Format
```markdown
### [Date/Time] - [Issue Type]
**Domain:** [Frontend/Backend/Reviewer]
**Context:** [What were you working on]
**Issue:** [What went wrong]
**Investigation:** [What you tried]
**Resolution:** [How it was solved or current status]
**Impact:** [Effect on other work or domains]
**Prevention:** [How to avoid this in future]
```

---

## Python-Specific Guidelines

### Testing Commands
```bash
# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ -v --cov=src --cov-report=html

# Run only unit tests
pytest tests/unit/ -v

# Run only integration tests
pytest tests/integration/ -v

# Run specific test file
pytest tests/unit/test_main.py -v
```

### Code Quality Commands
```bash
# Format code
black src/ tests/

# Check formatting
black --check src/ tests/

# Lint code
flake8 src/ tests/

# Sort imports
isort src/ tests/

# Type checking
mypy src/
```

### Virtual Environment
Always work within the virtual environment:
```bash
# Activate (Linux/Mac)
source .venv/bin/activate

# Activate (Windows)
.venv\Scripts\activate

# Deactivate
deactivate
```

### Project Structure
```
src/[package_name]/     # Main application code
tests/unit/             # Unit tests
tests/integration/      # Integration tests
requirements.txt        # Production dependencies
requirements-dev.txt    # Development dependencies
pytest.ini             # Test configuration
pyproject.toml         # Project configuration
```

### Dependency Management
```bash
# Add new dependency
pip install package_name
pip freeze > requirements.txt

# Add development dependency
pip install package_name
# Add to requirements-dev.txt manually

# Install all dependencies
pip install -r requirements.txt -r requirements-dev.txt
```

---

## Scrumban Board Management

### Column Definitions

| **Backlog** | **WIP** | **Review** | **Testing** | **Blocked** | **Done** |
|-------------|---------|------------|-------------|-------------|----------|
| Features from PRD, broken into testable chunks | Active development (limit: 3) | Awaiting code review | Integration testing | External dependencies | Meets all criteria |

### Movement Rules

**Backlog → WIP:**
- Item has clear acceptance criteria
- Dependencies are resolved
- Test approach is understood

**WIP → Review:**
- All tests pass (`pytest tests/ -v`)
- TDD cycle complete (Red→Green→Refactor)
- Code formatted (`black src/ tests/`)
- Code linted (`flake8 src/ tests/`)
- Code committed with clear history

**Review → Testing:**
- Code review passed
- No architectural concerns
- Ready for integration

**Testing → Done:**
- All acceptance criteria met
- Integration tests pass
- Documentation updated

**Any → Blocked:**
- External dependency required
- Technical blocker identified
- Needs human intervention

### WIP Limits
- **Maximum 3 items in WIP at once**
- **If blocked on one item, don't start new work until unblocked or moved to Blocked column**

---

## Quality Gates

### Before Starting Any Work
- [ ] PRD section is clearly understood
- [ ] Acceptance criteria are specific and testable
- [ ] Test approach is planned
- [ ] Virtual environment is activated

### Before Committing Code
- [ ] All tests pass (`pytest tests/ -v`)
- [ ] Code is formatted (`black --check src/ tests/`)
- [ ] Code passes linting (`flake8 src/ tests/`)
- [ ] Imports are sorted (`isort --check-only src/ tests/`)
- [ ] Type checking passes (`mypy src/`)
- [ ] Commit message follows standards
- [ ] No debug code or commented-out sections

### Before Marking Complete
- [ ] All acceptance criteria met
- [ ] Integration tests pass
- [ ] Code coverage maintains threshold (≥80%)
- [ ] Documentation updated
- [ ] Ready for production deployment

---

## Git Commit Standards

**Format:** `[Type]: [Feature] - [Description]`

**Types:**
- **Red:** Added failing tests
- **Green:** Implementation to pass tests
- **Refactor:** Code cleanup without functional changes
- **Reset:** Reverted failed approach
- **Docs:** Documentation updates
- **Setup:** Project configuration changes

**Examples:**
```
Red: User Authentication - Added login validation tests
Green: User Authentication - JWT implementation
Refactor: User Authentication - Extracted validation logic
Reset: User Authentication - Reverted overengineered approach
```

---

## Success Metrics

### Process Metrics
- **TDD Adherence:** Every feature starts with failing tests
- **Git Discipline:** Clean, revertible commit history
- **Board Accuracy:** Scrumban state reflects actual progress
- **Recovery Time:** Quick identification and resolution of derailed work

### Quality Metrics
- **Test Coverage:** ≥80% code coverage maintained
- **Requirements Traceability:** Every feature maps to PRD section
- **Code Quality:** Passes all linting and formatting checks
- **Type Safety:** MyPy checks pass without errors

**Remember:** The goal is not perfect code on the first try. The goal is systematic progress with the ability to recover quickly when things go wrong. Use the session management protocols to maintain continuity across sessions and domains.
EOF

# Create project.md for overall context
cat > .claude/project.md << EOF
# Project Context

**Project:** $PROJECT_NAME  
**Created:** $(date)  
**Status:** Active Development  
**Current Phase:** Initial Setup

## Overview
$PROJECT_DESCRIPTION

## Current Focus
Setting up initial project structure and establishing development workflow.

## Active Domains
- [ ] Frontend - Not yet assigned
- [ ] Backend - Not yet assigned  
- [ ] Reviewer - Not yet assigned

## Recent Changes
### $(date) - Project Bootstrap
- Created project structure
- Established Claude TDD + Scrumban workflow
- Configured Python environment with quality gates
- Set up initial testing framework

## Cross-Domain Communications
_No active communications_

## Blockers & Issues  
_None currently_

## Next Priorities
1. Review and customize PRD for specific project needs
2. Assign domain responsibilities
3. Begin implementation of first feature

---
**Last Updated:** $(date) by Bootstrap Script
EOF

# Create domain-specific context files
cat > .claude/frontend.md << EOF
# Frontend Domain Context

**Domain:** Frontend Development  
**Assigned To:** [Not yet assigned]  
**Status:** Ready for assignment

## Current Focus
_No active work_

## Technology Stack
- HTML/CSS for basic UI
- JavaScript for interactions
- Future: Framework TBD based on requirements

## Active Tasks
_None assigned_

## Completed Features
_None yet_

## Integration Points
_To be defined with backend domain_

## Issues & Blockers
_None currently_

## Notes & Patterns
_To be documented as development progresses_

---
**Last Updated:** $(date) by Bootstrap Script
EOF

cat > .claude/backend.md << EOF
# Backend Domain Context

**Domain:** Backend Development  
**Assigned To:** [Not yet assigned]  
**Status:** Ready for assignment

## Current Focus
_No active work_

## Technology Stack
- Python $PYTHON_VERSION
- Testing: pytest, coverage, quality tools
- Future: Framework TBD based on requirements

## Active Tasks
_None assigned_

## Completed Features
- [x] Basic hello_world function with comprehensive tests

## Integration Points
_To be defined with frontend domain_

## Issues & Blockers
_None currently_

## Notes & Patterns
- Following TDD with Red→Green→Refactor cycle
- All code must pass quality gates (black, flake8, mypy, isort)
- 80% test coverage requirement

---
**Last Updated:** $(date) by Bootstrap Script
EOF

cat > .claude/reviewer.md << EOF
# Reviewer Domain Context

**Domain:** Code Review & Quality Assurance  
**Assigned To:** [Not yet assigned]  
**Status:** Ready for assignment

## Current Focus
_No active reviews_

## Review Standards
- All code follows TDD principles
- Comprehensive test coverage (≥80%)
- Passes all quality gates
- Clear, maintainable architecture
- Proper documentation

## Active Reviews
_None pending_

## Completed Reviews
_None yet_

## Quality Metrics
- Test Coverage: TBD
- Code Quality: All gates configured
- Architecture: Clean, simple structure established

## Issues & Concerns
_None currently_

## Patterns & Decisions
- Standard Python project structure adopted
- Pytest testing framework established
- Black/Flake8/MyPy quality pipeline configured

---
**Last Updated:** $(date) by Bootstrap Script
EOF

# Create log files
cat > .claude/logs/system.md << EOF
# System Log

## $(date) - Project Bootstrap
**Domain:** Setup  
**Context:** Initial project creation  
**Event:** Project structure created with Claude workflow  
**Details:** 
- Python $PYTHON_VERSION virtual environment created
- Testing framework (pytest) configured
- Quality tools (black, flake8, mypy, isort) installed
- Git repository initialized with hooks
- Claude TDD + Scrumban workflow established

**Impact:** Project ready for domain assignment and development  
**Status:** Complete
EOF

cat > .claude/logs/project.md << EOF
# Project Log

## $(date) - Project Initialization
**Context:** New project bootstrap  
**Event:** $PROJECT_NAME project created  
**Details:**
- Bootstrap script executed successfully
- All required files and directories created
- Development environment configured
- Quality gates established

**Next Steps:**
1. Customize PRD with specific requirements
2. Assign domains to team members
3. Begin first development sprint

**Status:** Ready for development
EOF

cat > .claude/logs/debug.md << EOF
# Debug Log

_No debug entries yet_

<!-- Template for future entries:
## [Date/Time] - [Issue Type]
**Domain:** [Frontend/Backend/Reviewer]
**Context:** [What were you working on]
**Issue:** [What went wrong]
**Investigation:** [What you tried]
**Resolution:** [How it was solved or current status]
**Impact:** [Effect on other work or domains]
**Prevention:** [How to avoid this in future]
-->
EOF

# Create checkpoint template (examples)
cat > .claude/checkpoint_template.md << EOF
# Checkpoint Communication Template

## From: [Your Domain]
## To: [Target Domain]  
## Date: [Date/Time]

### Context
[What you were working on that affects the target domain]

### Request/Information
[What you need from them or what you're providing to them]

### Urgency
[Low/Medium/High - how soon you need this]

### Details
[Specific technical details, requirements, or questions]

### Impact
[What happens if this isn't addressed]

### Next Steps
[What should happen next]

---
**Created by:** [Your Domain] on [Date]
EOF

# scrumban.md
cat > .claude/scrumban.md << EOF
# Scrumban Board State

**Last Updated:** $(date)  
**WIP Limit:** 3 items maximum

---

## Backlog

### High Priority
- [ ] **Hello World Feature** - Basic greeting functionality
  - **Acceptance Criteria:** 
    - Function accepts optional name parameter
    - Returns formatted greeting message
    - Handles empty/None inputs gracefully
  - **Estimate:** S
  - **Dependencies:** None

### Medium Priority
- [ ] **Add Your Features Here** - [Brief description]
  - **Acceptance Criteria:** [Specific, testable requirements]  
  - **Estimate:** [S/M/L/XL]
  - **Dependencies:** [None/List items]

### Low Priority / Future
- [ ] **Future Enhancements** - [Ideas for later]

---

## Work In Progress (WIP: 0/3)

_No items currently in progress_

---

## Review

_No items currently in review_

---

## Testing

_No items currently in testing_

---

## Blocked

_No items currently blocked_

---

## Done

### Hello World Setup - $(date)
- **PRD Section:** Initial project setup
- **Final Commit:** [Will be updated after first commit]
- **Deployed:** N/A
- **Documentation:** README.md created

---

## Notes & Decisions

### $(date) - Project Initialization
Bootstrap script completed. Project ready for Claude TDD workflow.

### $(date) - Testing Framework  
Pytest configured with coverage reporting and quality gates.
EOF

# PRD template
cat > .claude/prd.md << EOF
# Product Requirements Document (PRD)

**Project:** $PROJECT_NAME  
**Version:** 1.0  
**Date:** $(date +%Y-%m-%d)  
**Owner:** Product Owner  
**Developer:** Claude Agent

---

## Executive Summary

### Problem Statement
$PROJECT_DESCRIPTION

### Solution Overview
A Python application built using Test-Driven Development (TDD) and managed through Scrumban workflow to ensure high quality and systematic progress.

### Success Criteria
- All features implemented with comprehensive test coverage (≥80%)
- Clean, maintainable codebase following Python best practices
- Automated quality gates ensuring code reliability
- Clear documentation for future maintenance

---

## Functional Requirements

### FR-001: Hello World Feature
**Priority:** High  
**Estimate:** S

**User Story:**  
As a developer, I want a basic hello world function so that I can verify the project setup is working correctly.

**Acceptance Criteria:**
- [ ] **AC-001:** Function accepts optional name parameter (string)
- [ ] **AC-002:** Returns formatted greeting message "Hello, {name}!"
- [ ] **AC-003:** Uses "World" as default when no name provided
- [ ] **AC-004:** Handles empty string and None inputs gracefully

**Test Scenarios:**
1. **Happy Path:** Call with valid name returns "Hello, {name}!"
2. **Default Case:** Call without parameters returns "Hello, World!"
3. **Edge Cases:** Empty string, None, special characters
4. **Type Safety:** Non-string inputs handled appropriately

**Dependencies:**
- None

**API Contract:**
```python
def hello_world(name: str = "World") -> str:
    """Return a greeting message."""
    pass
```

---

### FR-002: [Add Your Next Feature]
**Priority:** [High/Medium/Low]  
**Estimate:** [S/M/L/XL]

**User Story:**  
As a [user type], I want [capability] so that [benefit].

**Acceptance Criteria:**
- [ ] **AC-001:** [Specific, testable condition]
- [ ] **AC-002:** [Specific, testable condition]

**Test Scenarios:**
1. **Happy Path:** [Normal use case]
2. **Edge Cases:** [Boundary conditions]
3. **Error Conditions:** [What should happen when things go wrong]

**Dependencies:**
- [List any dependencies]

---

## Non-Functional Requirements

### Performance
- **Response Time:** Functions should execute in < 1ms for typical inputs
- **Memory Usage:** Minimal memory footprint for basic operations
- **Scalability:** Code should be modular and extensible

### Quality
- **Test Coverage:** Minimum 80% code coverage
- **Code Quality:** Pass all linting and formatting checks
- **Type Safety:** Full type hints with mypy validation
- **Documentation:** Comprehensive docstrings for all public functions

### Maintainability
- **Code Style:** Follow PEP 8 and Black formatting
- **Architecture:** Clear separation of concerns
- **Dependencies:** Minimal external dependencies
- **Version Control:** Clear git history with meaningful commits

---

## Technical Constraints

### Technology Stack
- **Language:** Python $PYTHON_VERSION+
- **Testing:** pytest with coverage reporting
- **Code Quality:** black, flake8, isort, mypy
- **Package Management:** pip with requirements.txt
- **Version Control:** git with structured commit messages

### Environment
- **Development:** Python virtual environment
- **Testing:** Automated test execution on all changes
- **Quality Gates:** All quality checks must pass before merge

---

## Implementation Notes

### Development Approach
- **Testing Strategy:** Test-Driven Development (TDD)
- **Workflow:** Scrumban with WIP limits
- **Code Review:** Automated quality checks + human review
- **Recovery Protocol:** Git revert for derailed implementations

### Risk Mitigation
- **Technical Risks:** Automated testing catches regressions
- **Process Risks:** Clear workflow prevents scope creep
- **Quality Risks:** Multiple quality gates ensure standards

### Assumptions
- Development will follow established TDD cycle
- All changes will go through quality gates
- Documentation will be updated with implementation

---

## Definition of Done

### Code Complete
- [ ] All acceptance criteria met
- [ ] Unit tests written and passing
- [ ] Integration tests passing (if applicable)
- [ ] Code coverage ≥ 80%
- [ ] All quality checks passing (black, flake8, mypy, isort)
- [ ] Code reviewed and approved
- [ ] Documentation updated

### Deployment Ready
- [ ] Passes all quality gates
- [ ] No known bugs or issues
- [ ] Ready for production use
- [ ] Change log updated

---

## Open Questions

### Technical Questions
- [List any unresolved technical decisions]
- [Areas needing more research]

### Product Questions  
- [Unclear requirements]
- [Stakeholder decisions needed]

---

## Change Log

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| $(date +%Y-%m-%d) | 1.0 | Initial version | Bootstrap Script |
EOF

# decisions.md
cat > .claude/decisions.md << EOF
# Technical Decisions Log

## $(date +%Y-%m-%d) - Project Bootstrap Decisions

**Decision:** Python $PYTHON_VERSION with pytest testing framework
**Rationale:** Stable Python version with mature testing ecosystem. Pytest provides excellent test discovery, fixtures, and reporting capabilities.
**Alternatives Considered:** unittest (too verbose), nose2 (less maintained)
**Impact:** Sets foundation for TDD workflow with comprehensive test reporting

---

**Decision:** Black + Flake8 + isort + mypy for code quality
**Rationale:** Industry standard tools that work well together. Black for consistent formatting, Flake8 for linting, isort for import organization, mypy for type checking.
**Alternatives Considered:** pylint (too opinionated), autopep8 (less comprehensive than Black)
**Impact:** Ensures consistent code quality across all contributions

---

**Decision:** Virtual environment with requirements.txt
**Rationale:** Standard Python practice for dependency isolation. Simple and widely understood.
**Alternatives Considered:** Poetry (more complex), Pipenv (inconsistent behavior)
**Impact:** Simple, reliable dependency management

---

**Decision:** pytest.ini + pyproject.toml configuration
**Rationale:** Centralizes project configuration in standard files. pytest.ini for test-specific settings, pyproject.toml for general project metadata.
**Alternatives Considered:** setup.py (deprecated), setup.cfg (less flexible)
**Impact:** Modern, standard configuration approach

---

## Template for Future Decisions

### [Date] - [Decision Topic]
**Decision:** [What was decided]
**Rationale:** [Why this decision was made]
**Alternatives Considered:** [Other options evaluated]
**Impact:** [Effects on project/code/process]
**Review Date:** [When to revisit this decision]
EOF

print_success "Claude workflow files created"

# Create README.md
print_status "Creating README.md..."
cat > README.md << EOF
# $PROJECT_NAME

$PROJECT_DESCRIPTION

## Overview

This project is managed using the Claude TDD + Scrumban workflow for systematic, test-driven development with clear progress tracking.

## Getting Started

### Prerequisites
- Python $PYTHON_VERSION or higher
- Git

### Setup
\`\`\`bash
# Clone the repository
git clone <repository-url>
cd $PROJECT_NAME

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
│   └── ${PACKAGE_NAME}/  # Main application code
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

# Create test runner script
print_status "Creating utility scripts..."
mkdir -p scripts

cat > scripts/test.sh << 'EOF'
#!/bin/bash
# Test runner script

set -e

echo "Running test suite..."

# Activate virtual environment
source .venv/bin/activate

# Run tests with coverage
pytest tests/ -v --cov=src --cov-report=html --cov-report=term-missing

echo "Tests completed successfully!"
EOF

cat > scripts/quality.sh << 'EOF'
#!/bin/bash
# Code quality checker script

set -e

echo "Running code quality checks..."

# Activate virtual environment
source .venv/bin/activate

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

# Setup git hooks
print_status "Setting up git hooks..."
mkdir -p .git/hooks

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

cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
# Run quality checks before commit

# Activate virtual environment
if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
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

# Run initial test to verify setup
print_status "Verifying setup..."
pytest tests/ -v

# Initial git commit
print_status "Creating initial commit..."
git add .
git commit -m "Setup: Project initialization - Bootstrap complete with Claude TDD workflow"

print_success "Initial commit created"

# Final status
print_success "Project $PROJECT_NAME created successfully!"
echo ""
print_status "Next steps:"
echo "  1. cd $PROJECT_NAME"
echo "  2. source .venv/bin/activate"
echo "  3. Review .claude/prd.md and customize for your project"
echo "  4. Start with Claude: '/signin backend' or '/signin frontend'"
echo ""
print_status "Useful commands:"
echo "  pytest tests/ -v                    # Run tests"
echo "  scripts/test.sh                     # Run tests with coverage"
echo "  scripts/quality.sh                  # Run all quality checks"
echo "  black src/ tests/                   # Format code"
echo ""
print_status "Claude session commands:"
echo "  /signin [domain]                    # Start session with context"
echo "  /signout                            # End session with state updates"
echo "  /update                             # Refresh all documentation"
echo "  /status                             # Quick status check"
echo ""
print_status "Claude instructions:"
echo "  Tell Claude: 'Read CLAUDE.md and execute /signin [domain] protocol'"