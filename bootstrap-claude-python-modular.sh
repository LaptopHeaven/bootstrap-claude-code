#!/bin/bash

# Claude Python Project Bootstrap Script - Modular Version
# Creates a new Python project configured for Claude TDD + Scrumban workflow
# Uses modular architecture for flexibility and reusability

set -e  # Exit on any error

# Get script directory for sourcing modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source required modules
source "$SCRIPT_DIR/lib/core.sh"
source "$SCRIPT_DIR/lib/python.sh"
source "$SCRIPT_DIR/lib/git.sh"
source "$SCRIPT_DIR/lib/claude.sh"
source "$SCRIPT_DIR/lib/templates.sh"

# Main bootstrap function
main() {
    # Parse command line arguments (sets global variables)
    parse_arguments "$@"
    
    # Validate all inputs
    validate_inputs || exit 1
    
    # Convert project name to package name
    PACKAGE_NAME=$(get_package_name "$PROJECT_NAME")
    
    print_status "Creating Claude-managed Python project: $PROJECT_NAME"
    print_status "Package name: $PACKAGE_NAME"
    print_status "Description: $PROJECT_DESCRIPTION"
    print_status "Python version: $PYTHON_VERSION"
    
    # Create basic project structure
    create_basic_structure "$PROJECT_NAME" "$PACKAGE_NAME" || exit 1
    
    # Setup Python environment
    setup_python_environment "$PROJECT_NAME" "$PROJECT_DESCRIPTION" "$PYTHON_VERSION" || exit 1
    
    # Create Claude workflow files
    create_claude_workflow_files "$PROJECT_NAME" "$PROJECT_DESCRIPTION" "$PYTHON_VERSION" || exit 1
    
    # Create documentation templates
    create_all_templates "$PROJECT_NAME" "$PROJECT_DESCRIPTION" "$PYTHON_VERSION" "$PACKAGE_NAME" || exit 1
    
    # Setup git environment (includes initial commit)
    setup_git_environment "$PROJECT_NAME" || exit 1
    
    # Final status and instructions
    show_completion_message
}

# Function to show completion message and next steps
show_completion_message() {
    print_success "Project $PROJECT_NAME created successfully!"
    echo ""
    print_status "Next steps:"
    echo "  1. cd $PROJECT_NAME"
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "  2. .venv\\Scripts\\activate"
    else
        echo "  2. source .venv/bin/activate"
    fi
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
    echo ""
    print_status "Modular usage:"
    echo "  Source individual modules from lib/ for custom workflows"
    echo "  See docs/USAGE.md for examples of using modules separately"
}

# Run main function with all arguments
main "$@"