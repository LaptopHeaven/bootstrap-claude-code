#!/bin/bash

# Example: Custom Bootstrap Using Individual Modules
# This demonstrates how to use the modular components separately

set -e

# Get the parent directory to find lib modules
PARENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source required modules
source "$PARENT_DIR/lib/core.sh"
source "$PARENT_DIR/lib/python.sh"
source "$PARENT_DIR/lib/git.sh"

# Example 1: Simple Python project without Claude workflow
create_simple_python_project() {
    local project_name="$1"
    local description="${2:-Simple Python project}"
    local python_version="${3:-3.12}"
    
    print_status "Creating simple Python project: $project_name"
    
    # Validate and setup
    validate_project_name "$project_name" || return 1
    check_prerequisites || return 1
    check_directory_exists "$project_name" || return 1
    
    local package_name
    package_name=$(get_package_name "$project_name")
    
    # Create structure and setup Python environment
    create_basic_structure "$project_name" "$package_name" || return 1
    cd "$project_name" || return 1
    
    setup_python_environment "$project_name" "$description" "$python_version" || return 1
    
    # Simple README without Claude workflow
    cat > README.md << EOF
# $project_name

$description

## Setup
\`\`\`bash
source .venv/bin/activate
pip install -r requirements.txt -r requirements-dev.txt
pytest tests/ -v
\`\`\`

## Development
Follow standard Python development practices with TDD.
EOF
    
    # Setup git
    setup_git_environment "$project_name" || return 1
    
    print_success "Simple Python project created: $project_name"
}

# Example 2: Add Claude workflow to existing project
add_claude_to_existing() {
    local project_name="$1"
    local description="${2:-Existing project with Claude workflow}"
    local python_version="${3:-3.12}"
    
    if [ ! -d "$project_name" ]; then
        print_error "Project directory $project_name does not exist"
        return 1
    fi
    
    print_status "Adding Claude workflow to existing project: $project_name"
    
    cd "$project_name" || return 1
    
    # Source Claude module
    source "$PARENT_DIR/lib/claude.sh"
    
    # Create Claude workflow files
    create_claude_workflow_files "$project_name" "$description" "$python_version" || return 1
    
    print_success "Claude workflow added to: $project_name"
}

# Example 3: Python-only setup (no git, no Claude)
setup_python_only() {
    local project_name="$1"
    local description="${2:-Python-only project}"
    local python_version="${3:-3.12}"
    
    print_status "Setting up Python-only environment: $project_name"
    
    validate_project_name "$project_name" || return 1
    check_directory_exists "$project_name" || return 1
    
    local package_name
    package_name=$(get_package_name "$project_name")
    
    create_basic_structure "$project_name" "$package_name" || return 1
    cd "$project_name" || return 1
    
    # Only Python setup, no git or Claude
    create_virtual_environment || return 1
    upgrade_pip || return 1
    create_requirements_files "$python_version" || return 1
    install_dev_dependencies || return 1
    create_pytest_config || return 1
    create_pyproject_config "$project_name" "$description" "$python_version" || return 1
    create_gitignore || return 1
    create_python_package "$package_name" "$project_name" "$description" || return 1
    create_sample_tests "$package_name" "$project_name" || return 1
    verify_python_setup || return 1
    
    print_success "Python-only setup complete: $project_name"
}

# Main function to demonstrate usage
main() {
    case "${1:-help}" in
        "simple")
            create_simple_python_project "$2" "$3" "$4"
            ;;
        "add-claude")
            add_claude_to_existing "$2" "$3" "$4"
            ;;
        "python-only")
            setup_python_only "$2" "$3" "$4"
            ;;
        "help"|*)
            echo "Custom Bootstrap Examples"
            echo ""
            echo "Usage:"
            echo "  $0 simple <project_name> [description] [python_version]"
            echo "    Creates a simple Python project without Claude workflow"
            echo ""
            echo "  $0 add-claude <existing_project> [description] [python_version]"
            echo "    Adds Claude workflow to an existing project"
            echo ""
            echo "  $0 python-only <project_name> [description] [python_version]"
            echo "    Sets up Python environment only (no git, no Claude)"
            echo ""
            echo "Examples:"
            echo "  $0 simple my-api \"REST API project\" 3.11"
            echo "  $0 add-claude existing-project \"Add Claude to existing\""
            echo "  $0 python-only test-project \"Just Python setup\""
            ;;
    esac
}

# Run main with all arguments
main "$@"