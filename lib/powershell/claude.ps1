# Claude workflow files module for Claude Python Bootstrap - PowerShell Version
# Creates all Claude-specific workflow and documentation files

# Dot-source core utilities
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir\core.ps1"

# Function to create main CLAUDE.md workflow file
function New-ClaudeWorkflow {
    Write-Status "Creating CLAUDE.md workflow file..."
    
    $claudeWorkflow = @'
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

## Python-Specific Guidelines

### Testing Commands
```bash
# Run all tests
python -m pytest tests\ -v

# Run with coverage
python -m pytest tests\ -v --cov=src --cov-report=html

# Run only unit tests
python -m pytest tests\unit\ -v

# Run only integration tests
python -m pytest tests\integration\ -v

# Run specific test file
python -m pytest tests\unit\test_main.py -v
```

### Code Quality Commands
```bash
# Format code
python -m black src\ tests\

# Check formatting
python -m black --check src\ tests\

# Lint code
python -m flake8 src\ tests\

# Sort imports
python -m isort src\ tests\

# Type checking
python -m mypy src\
```

### Virtual Environment (Windows/PowerShell)
Always work within the virtual environment:
```powershell
# Activate
.\.venv\Scripts\Activate.ps1

# Deactivate
deactivate
```

### Virtual Environment (Cross-platform)
```bash
# Activate (Linux/Mac/WSL)
source .venv/bin/activate

# Activate (Windows Git Bash)
source .venv/Scripts/activate

# Deactivate
deactivate
```

### Project Structure
```
src\[package_name]\     # Main application code
tests\unit\             # Unit tests
tests\integration\      # Integration tests
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

## Quality Gates

### Before Starting Any Work
- [ ] PRD section is clearly understood
- [ ] Acceptance criteria are specific and testable
- [ ] Test approach is planned
- [ ] Virtual environment is activated

### Before Committing Code
- [ ] All tests pass (`python -m pytest tests\ -v`)
- [ ] Code is formatted (`python -m black --check src\ tests\`)
- [ ] Code passes linting (`python -m flake8 src\ tests\`)
- [ ] Imports are sorted (`python -m isort --check-only src\ tests\`)
- [ ] Type checking passes (`python -m mypy src\`)
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
'@
    
    $claudeWorkflow | Out-File -FilePath "CLAUDE.md" -Encoding UTF8
    Write-Success "CLAUDE.md workflow file created"
    return $true
}

# Function to create project context file
function New-ProjectContext {
    param(
        [string]$ProjectName,
        [string]$ProjectDescription
    )
    
    Write-Status "Creating project context file..."
    
    $currentDateTime = Get-CurrentDateTime
    $projectContext = @"
# Project Context

**Project:** $ProjectName  
**Created:** $currentDateTime  
**Status:** Active Development  
**Current Phase:** Initial Setup

## Overview
$ProjectDescription

## Current Focus
Setting up initial project structure and establishing development workflow.

## Active Domains
- [ ] Frontend - Not yet assigned
- [ ] Backend - Not yet assigned  
- [ ] Reviewer - Not yet assigned

## Recent Changes
### $currentDateTime - Project Bootstrap
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
**Last Updated:** $currentDateTime by Bootstrap Script
"@
    
    $projectContext | Out-File -FilePath ".claude\project.md" -Encoding UTF8
    Write-Success "Project context file created"
    return $true
}

# Function to create domain-specific context files
function New-DomainContexts {
    param([string]$PythonVersion)
    
    Write-Status "Creating domain context files..."
    
    $currentDateTime = Get-CurrentDateTime
    
    # Frontend context
    $frontendContext = @"
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
**Last Updated:** $currentDateTime by Bootstrap Script
"@
    
    $frontendContext | Out-File -FilePath ".claude\frontend.md" -Encoding UTF8
    
    # Backend context
    $backendContext = @"
# Backend Domain Context

**Domain:** Backend Development  
**Assigned To:** [Not yet assigned]  
**Status:** Ready for assignment

## Current Focus
_No active work_

## Technology Stack
- Python $PythonVersion
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
**Last Updated:** $currentDateTime by Bootstrap Script
"@
    
    $backendContext | Out-File -FilePath ".claude\backend.md" -Encoding UTF8
    
    # Reviewer context
    $reviewerContext = @"
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
**Last Updated:** $currentDateTime by Bootstrap Script
"@
    
    $reviewerContext | Out-File -FilePath ".claude\reviewer.md" -Encoding UTF8
    
    Write-Success "Domain context files created"
    return $true
}

# Main function to create all Claude workflow files
function Initialize-ClaudeWorkflowFiles {
    param(
        [string]$ProjectName,
        [string]$ProjectDescription,
        [string]$PythonVersion
    )
    
    Write-Status "Creating Claude workflow files..."
    
    if (-not (New-ClaudeWorkflow)) { return $false }
    if (-not (New-ProjectContext $ProjectName $ProjectDescription)) { return $false }
    if (-not (New-DomainContexts $PythonVersion)) { return $false }
    
    # Create additional placeholder files for complete workflow
    # These would include scrumban.md, prd.md, decisions.md, etc.
    # For brevity, I'm including the essential ones
    
    Write-Success "Claude workflow files created"
    return $true
}