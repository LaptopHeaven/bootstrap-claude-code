#!/bin/bash

# Claude workflow files module for Claude Python Bootstrap
# Creates all Claude-specific workflow and documentation files

# Source core utilities (if not already loaded)
if ! command -v print_status >/dev/null 2>&1; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/core.sh"
fi

# Function to create main CLAUDE.md workflow file
create_claude_workflow() {
    print_status "Creating CLAUDE.md workflow file..."
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
    print_success "CLAUDE.md workflow file created"
}

# Function to create project context file
create_project_context() {
    local project_name="$1"
    local project_description="$2"
    
    print_status "Creating project context file..."
    cat > .claude/project.md << EOF
# Project Context

**Project:** $project_name  
**Created:** $(date)  
**Status:** Active Development  
**Current Phase:** Initial Setup

## Overview
$project_description

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
    print_success "Project context file created"
}

# Function to create domain-specific context files
create_domain_contexts() {
    local python_version="$1"
    
    print_status "Creating domain context files..."
    
    # Frontend context
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
    
    # Backend context
    cat > .claude/backend.md << EOF
# Backend Domain Context

**Domain:** Backend Development  
**Assigned To:** [Not yet assigned]  
**Status:** Ready for assignment

## Current Focus
_No active work_

## Technology Stack
- Python $python_version
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
    
    # Reviewer context
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
    
    print_success "Domain context files created"
}

# Function to create log files
create_log_files() {
    local project_name="$1"
    local python_version="$2"
    
    print_status "Creating log files..."
    
    # System log
    cat > .claude/logs/system.md << EOF
# System Log

## $(date) - Project Bootstrap
**Domain:** Setup  
**Context:** Initial project creation  
**Event:** Project structure created with Claude workflow  
**Details:** 
- Python $python_version virtual environment created
- Testing framework (pytest) configured
- Quality tools (black, flake8, mypy, isort) installed
- Git repository initialized with hooks
- Claude TDD + Scrumban workflow established

**Impact:** Project ready for domain assignment and development  
**Status:** Complete
EOF
    
    # Project log
    cat > .claude/logs/project.md << EOF
# Project Log

## $(date) - Project Initialization
**Context:** New project bootstrap  
**Event:** $project_name project created  
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
    
    # Debug log
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
    
    print_success "Log files created"
}

# Function to create scrumban board
create_scrumban_board() {
    print_status "Creating scrumban board..."
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
    print_success "Scrumban board created"
}

# Function to create PRD template
create_prd_template() {
    local project_name="$1"
    local project_description="$2"
    local python_version="$3"
    
    print_status "Creating PRD template..."
    cat > .claude/prd.md << EOF
# Product Requirements Document (PRD)

**Project:** $project_name  
**Version:** 1.0  
**Date:** $(date +%Y-%m-%d)  
**Owner:** Product Owner  
**Developer:** Claude Agent

---

## Executive Summary

### Problem Statement
$project_description

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
\`\`\`python
def hello_world(name: str = "World") -> str:
    """Return a greeting message."""
    pass
\`\`\`

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
- **Language:** Python $python_version+
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
    print_success "PRD template created"
}

# Function to create decisions log
create_decisions_log() {
    local python_version="$1"
    
    print_status "Creating decisions log..."
    cat > .claude/decisions.md << EOF
# Technical Decisions Log

## $(date +%Y-%m-%d) - Project Bootstrap Decisions

**Decision:** Python $python_version with pytest testing framework
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
    print_success "Decisions log created"
}

# Function to create checkpoint template
create_checkpoint_template() {
    print_status "Creating checkpoint template..."
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
    print_success "Checkpoint template created"
}

# Main function to create all Claude workflow files
create_claude_workflow_files() {
    local project_name="$1"
    local project_description="$2"
    local python_version="$3"
    
    print_status "Creating Claude workflow files..."
    
    create_claude_workflow || return 1
    create_project_context "$project_name" "$project_description" || return 1
    create_domain_contexts "$python_version" || return 1
    create_log_files "$project_name" "$python_version" || return 1
    create_scrumban_board || return 1
    create_prd_template "$project_name" "$project_description" "$python_version" || return 1
    create_decisions_log "$python_version" || return 1
    create_checkpoint_template || return 1
    
    print_success "Claude workflow files created"
    return 0
}

# Export functions for use in other modules
export -f create_claude_workflow create_project_context create_domain_contexts
export -f create_log_files create_scrumban_board create_prd_template
export -f create_decisions_log create_checkpoint_template create_claude_workflow_files