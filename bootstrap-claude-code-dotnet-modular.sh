#!/bin/bash

# Claude .NET Project Bootstrap Script - Bash Modular Version
# Creates a new .NET 8 project configured for Claude TDD + Scrumban workflow
# Uses modular architecture for flexibility and reusability

set -e  # Exit on any error

# Show usage information
show_usage() {
    echo "Usage: $0 <project_name> [options]"
    echo ""
    echo "Creates a new .NET 8 project with Claude TDD + Scrumban workflow (Modular Version)"
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
    echo ""
    echo "Modular Features:"
    echo "  - Uses independent modules for .NET, Git, Claude workflow, and templates"
    echo "  - Same functionality as bootstrap-claude-code-dotnet.sh but with modular architecture"
    echo "  - Enables custom workflows by combining different modules"
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

# Source required modules with error handling
source_module() {
    local module_path="$1"
    local module_name="$2"
    
    if [ -f "$module_path" ]; then
        source "$module_path" || {
            echo "Failed to load $module_name module from $module_path" >&2
            return 1
        }
    else
        echo "Module not found: $module_path" >&2
        return 1
    fi
}

# Load all required modules
echo "Loading Bootstrap Claude Code modules..."

if ! source_module "$SCRIPT_DIR/lib/core.sh" "core"; then
    echo "Make sure you're running this script from the bootstrap-claude-code directory" >&2
    echo "Required modules:" >&2
    echo "  - lib/core.sh" >&2
    echo "  - lib/dotnet.sh" >&2
    echo "  - lib/git.sh" >&2
    echo "  - lib/claude.sh" >&2
    echo "  - lib/templates.sh" >&2
    exit 1
fi

if ! source_module "$SCRIPT_DIR/lib/dotnet.sh" "dotnet"; then
    exit 1
fi

if ! source_module "$SCRIPT_DIR/lib/git.sh" "git"; then
    exit 1
fi

if ! source_module "$SCRIPT_DIR/lib/claude.sh" "claude"; then
    exit 1
fi

if ! source_module "$SCRIPT_DIR/lib/templates.sh" "templates"; then
    exit 1
fi

print_success "All modules loaded successfully"

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

# Main modular bootstrap function
main() {
    print_status "🔧 Starting modular .NET project bootstrap..."
    print_status "Creating Claude-managed .NET project: $PROJECT_NAME"
    print_status "Description: $PROJECT_DESCRIPTION"
    print_status "Project type: $PROJECT_TYPE"
    print_status "Using modular architecture for flexible development workflow"
    
    # Validate project name using core module
    if ! validate_project_name "$PROJECT_NAME"; then
        exit 1
    fi
    
    # Check if directory already exists using core module
    if ! check_directory_exists "$PROJECT_NAME"; then
        exit 1
    fi
    
    # Get package name (for directory structure) using core module
    PACKAGE_NAME=$(get_package_name "$PROJECT_NAME")
    print_status "Package name: $PACKAGE_NAME"
    
    # Create basic project structure using core module
    print_status "📁 Creating project structure..."
    if ! create_basic_structure "$PROJECT_NAME" "$PACKAGE_NAME"; then
        print_error "Failed to create basic project structure"
        exit 1
    fi
    
    # Note: create_basic_structure already changes to the project directory
    
    # Setup .NET environment using dotnet module
    print_status "🏗️  Setting up .NET environment..."
    if ! setup_dotnet_environment "$PROJECT_NAME" "$PROJECT_DESCRIPTION" "$PROJECT_TYPE"; then
        print_error "Failed to setup .NET environment"
        exit 1
    fi
    
    # Setup Git environment using git module
    print_status "📋 Setting up Git repository..."
    if ! setup_git_environment "$PROJECT_NAME"; then
        print_error "Failed to setup Git environment"
        exit 1
    fi
    
    # Create Claude workflow files using claude module
    print_status "🤖 Creating Claude TDD + Scrumban workflow..."
    if ! create_claude_workflow_files "$PROJECT_NAME" "$PROJECT_DESCRIPTION" "net8.0"; then
        print_error "Failed to create Claude workflow files"
        exit 1
    fi
    
    # Create documentation templates (adapted for .NET)
    print_status "📚 Creating documentation templates..."
    if ! create_dotnet_templates "$PROJECT_NAME" "$PROJECT_DESCRIPTION" "$PROJECT_TYPE" "$PACKAGE_NAME"; then
        print_error "Failed to create documentation templates"
        exit 1
    fi
    
    # Final verification using dotnet module
    print_status "✅ Running final verification..."
    if ! verify_dotnet_setup; then
        print_warning "Some verification checks failed, but project was created"
    fi
    
    print_success "🎉 .NET project '$PROJECT_NAME' created successfully!"
    print_status ""
    print_status "📋 Next steps:"
    print_status "1. cd $PROJECT_NAME"
    print_status "2. Review .claude/CLAUDE.md for development workflow"
    print_status "3. ./scripts/test.sh    # Run tests"
    print_status "4. ./scripts/build.sh   # Build solution"
    print_status "5. ./scripts/quality.sh # Run quality checks"
    print_status ""
    print_status "🚀 Happy coding with Claude using modular architecture!"
    print_status ""
    print_status "💡 Modular Features Used:"
    print_status "   - Core module: Project validation and structure"
    print_status "   - .NET module: Solution and project setup"
    print_status "   - Git module: Repository initialization"
    print_status "   - Claude module: TDD + Scrumban workflow"
    print_status "   - Templates module: Documentation generation"
}

# Run the main function
main "$@"