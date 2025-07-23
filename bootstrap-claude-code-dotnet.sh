#!/bin/bash

# Claude .NET Project Bootstrap Script - Bash Version
# Creates a new .NET 8 project configured for Claude TDD + Scrumban workflow

set -e  # Exit on any error

# Show usage information
show_usage() {
    echo "Usage: $0 <project_name> [options]"
    echo ""
    echo "Creates a new .NET 8 project with Claude TDD + Scrumban workflow"
    echo ""
    echo "Arguments:"
    echo "  project_name              Name of the project to create"
    echo ""
    echo "Options:"
    echo "  -d, --description <desc>  Project description"
    echo "  -t, --type <type>         Project type (classlib, console, webapi) [default: classlib]"
    echo "  -h, --help                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 my-awesome-library -d \"My awesome .NET library\""
    echo "  $0 my-console-app -d \"Console application\" -t console"
    echo "  $0 my-web-api -d \"REST API service\" -t webapi"
}

# Parse command line arguments
PROJECT_NAME=""
PROJECT_DESCRIPTION=""
PROJECT_TYPE="classlib"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -d|--description)
            PROJECT_DESCRIPTION="$2"
            shift 2
            ;;
        -t|--type)
            PROJECT_TYPE="$2"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1" >&2
            show_usage
            exit 1
            ;;
        *)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$1"
            else
                echo "Multiple project names provided. Use only one." >&2
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if project name was provided
if [ -z "$PROJECT_NAME" ]; then
    echo "Error: Project name is required" >&2
    show_usage
    exit 1
fi

# Set default description if not provided
if [ -z "$PROJECT_DESCRIPTION" ]; then
    PROJECT_DESCRIPTION="A .NET 8 project bootstrapped with Claude TDD + Scrumban workflow"
fi

# Get script directory for sourcing modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source required modules
source "$SCRIPT_DIR/lib/core.sh" || {
    echo "Failed to load core module" >&2
    exit 1
}

source "$SCRIPT_DIR/lib/dotnet.sh" || {
    echo "Failed to load .NET module" >&2
    exit 1
}

source "$SCRIPT_DIR/lib/git.sh" || {
    echo "Failed to load Git module" >&2
    exit 1
}

source "$SCRIPT_DIR/lib/claude.sh" || {
    echo "Failed to load Claude module" >&2
    exit 1
}

source "$SCRIPT_DIR/lib/templates.sh" || {
    echo "Failed to load templates module" >&2
    exit 1
}

# Main bootstrap function
main() {
    print_status "Creating Claude-managed .NET project: $PROJECT_NAME"
    print_status "Description: $PROJECT_DESCRIPTION"
    print_status "Project type: $PROJECT_TYPE"
    
    # Validate project name
    if ! validate_project_name "$PROJECT_NAME"; then
        exit 1
    fi
    
    # Check if directory already exists
    if ! check_directory_exists "$PROJECT_NAME"; then
        exit 1
    fi
    
    # Get package name (for directory structure)
    PACKAGE_NAME=$(get_package_name "$PROJECT_NAME")
    
    # Create basic project structure
    if ! create_basic_structure "$PROJECT_NAME" "$PACKAGE_NAME"; then
        print_error "Failed to create basic project structure"
        exit 1
    fi
    
    # Note: create_basic_structure already changes to the project directory
    
    # Setup .NET environment
    if ! setup_dotnet_environment "$PROJECT_NAME" "$PROJECT_DESCRIPTION" "$PROJECT_TYPE"; then
        print_error "Failed to setup .NET environment"
        exit 1
    fi
    
    # Setup Git environment
    if ! setup_git_environment "$PROJECT_NAME"; then
        print_error "Failed to setup Git environment"
        exit 1
    fi
    
    # Create Claude workflow files
    if ! create_claude_workflow_files "$PROJECT_NAME" "$PROJECT_DESCRIPTION" "net8.0"; then
        print_error "Failed to create Claude workflow files"
        exit 1
    fi
    
    # Create documentation templates (adapted for .NET)
    if ! create_dotnet_templates "$PROJECT_NAME" "$PROJECT_DESCRIPTION" "$PROJECT_TYPE" "$PACKAGE_NAME"; then
        print_error "Failed to create documentation templates"
        exit 1
    fi
    
    # Final verification
    print_status "Running final verification..."
    if ! verify_dotnet_setup; then
        print_warning "Some verification checks failed, but project was created"
    fi
    
    print_success "✅ .NET project '$PROJECT_NAME' created successfully!"
    print_status ""
    print_status "Next steps:"
    print_status "1. cd $PROJECT_NAME"
    print_status "2. Review .claude/CLAUDE.md for development workflow"
    print_status "3. ./scripts/test.sh    # Run tests"
    print_status "4. ./scripts/build.sh   # Build solution"
    print_status "5. ./scripts/quality.sh # Run quality checks"
    print_status ""
    print_status "Happy coding with Claude! 🚀"
}

# Function to create .NET-specific documentation templates
create_dotnet_templates() {
    local project_name="$1"
    local project_description="$2"
    local project_type="$3"
    local package_name="$4"
    
    print_status "Creating .NET documentation templates..."
    
    # Create README.md
    cat > README.md << EOF
# $project_name

$project_description

## Overview

This is a .NET 8 $project_type project bootstrapped with Claude TDD + Scrumban workflow for efficient development.

## Prerequisites

- .NET 8 SDK
- Git

## Getting Started

### Build the project
\`\`\`bash
dotnet build
# or
./scripts/build.sh
\`\`\`

### Run tests
\`\`\`bash
dotnet test
# or  
./scripts/test.sh
\`\`\`

### Run quality checks
\`\`\`bash
./scripts/quality.sh
\`\`\`

## Project Structure

- **src/$project_name/** - Main project source code
- **tests/$project_name.Tests/** - Unit and integration tests
- **scripts/** - Build and development utility scripts
- **.claude/** - Claude TDD + Scrumban workflow files

## Development Workflow

This project uses the Claude TDD + Scrumban workflow. See [.claude/CLAUDE.md](.claude/CLAUDE.md) for details.

### Key Files
- **.claude/CLAUDE.md** - Main Claude workflow documentation
- **.claude/scrumban-board.md** - Development task tracking
- **.claude/logs/** - Session logs and development history

## Quality Standards

- **Code Coverage**: Aim for >80% test coverage
- **Code Analysis**: All analyzer warnings must be resolved
- **Formatting**: Consistent code formatting via EditorConfig
- **Documentation**: All public APIs must be documented

## Contributing

1. Follow the Claude TDD workflow in .claude/CLAUDE.md
2. Write tests for all new functionality
3. Ensure all quality checks pass
4. Update documentation as needed

## License

[Specify your license here]
EOF
    
    print_success ".NET documentation templates created"
    return 0
}

# Run the main function
main "$@"