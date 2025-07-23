#!/bin/bash

# Example: Custom .NET Bootstrap Using Individual Modules
# This demonstrates how to use the modular .NET components separately

set -e

# Get the parent directory to find lib modules
PARENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source required modules
source "$PARENT_DIR/lib/core.sh"
source "$PARENT_DIR/lib/dotnet.sh"
source "$PARENT_DIR/lib/git.sh"

# Example 1: Simple .NET project without Claude workflow
create_simple_dotnet_project() {
    local project_name="$1"
    local description="${2:-Simple .NET 8 project}"
    local project_type="${3:-classlib}"
    
    print_status "Creating simple .NET project: $project_name"
    
    # Validate and setup
    validate_project_name "$project_name" || return 1
    check_dotnet_prerequisites || return 1
    check_directory_exists "$project_name" || return 1
    
    local package_name
    package_name=$(get_package_name "$project_name")
    
    # Create structure and setup .NET environment
    create_basic_structure "$project_name" "$package_name" || return 1
    cd "$project_name" || return 1
    
    setup_dotnet_environment "$project_name" "$description" "$project_type" || return 1
    
    # Simple README without Claude workflow
    cat > README.md << EOF
# $project_name

$description

## Setup
\`\`\`bash
dotnet restore
dotnet build
dotnet test
\`\`\`

## Development
Follow standard .NET development practices with TDD.

### Project Structure
- **src/$project_name/** - Main project source code
- **tests/$project_name.Tests/** - Unit and integration tests
- **scripts/** - Build and development utility scripts

### Quality Checks
\`\`\`bash
./scripts/build.sh      # Build solution
./scripts/test.sh       # Run tests with coverage
./scripts/quality.sh    # Run all quality checks
\`\`\`
EOF
    
    # Setup git
    setup_git_environment "$project_name" || return 1
    
    print_success "Simple .NET project created: $project_name"
}

# Example 2: Add Claude workflow to existing .NET project
add_claude_to_existing_dotnet() {
    local project_name="$1"
    local description="${2:-Existing .NET project with Claude workflow}"
    local target_framework="${3:-net8.0}"
    
    if [ ! -d "$project_name" ]; then
        print_error "Project directory $project_name does not exist"
        return 1
    fi
    
    print_status "Adding Claude workflow to existing .NET project: $project_name"
    
    cd "$project_name" || return 1
    
    # Source Claude module
    source "$PARENT_DIR/lib/claude.sh"
    
    # Create Claude workflow files
    create_claude_workflow_files "$project_name" "$description" "$target_framework" || return 1
    
    print_success "Claude workflow added to: $project_name"
}

# Example 3: .NET-only setup (no Git, no Claude)
create_dotnet_only() {
    local project_name="$1"
    local description="${2:-.NET 8 project (minimal setup)}"
    local project_type="${3:-classlib}"
    
    print_status "Creating .NET-only project: $project_name"
    
    # Validate and setup
    validate_project_name "$project_name" || return 1
    check_dotnet_prerequisites || return 1
    check_directory_exists "$project_name" || return 1
    
    local package_name
    package_name=$(get_package_name "$project_name")
    
    # Create basic structure (minimal)
    mkdir -p "$project_name"
    cd "$project_name" || return 1
    
    # Just create the .NET projects and configuration
    create_dotnet_project "$project_name" "$project_type" || return 1
    create_global_json || return 1
    create_directory_build_props "$project_name" "$description" || return 1
    create_editorconfig || return 1
    setup_dotnet_dependencies "$project_name" || return 1
    create_dotnet_gitignore || return 1
    
    # Minimal README
    cat > README.md << EOF
# $project_name

$description

A minimal .NET 8 $project_type project.

## Quick Start
\`\`\`bash
dotnet build
dotnet test
\`\`\`
EOF
    
    print_success ".NET-only project created: $project_name"
}

# Example 4: Web API with full setup
create_webapi_project() {
    local project_name="$1"
    local description="${2:-ASP.NET Core Web API with Claude workflow}"
    
    print_status "Creating Web API project: $project_name"
    
    # Validate and setup
    validate_project_name "$project_name" || return 1
    check_dotnet_prerequisites || return 1
    check_directory_exists "$project_name" || return 1
    
    local package_name
    package_name=$(get_package_name "$project_name")
    
    # Create structure and setup .NET Web API environment
    create_basic_structure "$project_name" "$package_name" || return 1
    cd "$project_name" || return 1
    
    setup_dotnet_environment "$project_name" "$description" "webapi" || return 1
    
    # Add Web API specific packages
    cd "src/$project_name" || return 1
    dotnet add package Swashbuckle.AspNetCore --version 6.5.0
    dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.0
    cd ../.. || return 1
    
    # Web API specific README
    cat > README.md << EOF
# $project_name

$description

An ASP.NET Core Web API project with Claude TDD + Scrumban workflow.

## Quick Start
\`\`\`bash
dotnet run --project src/$project_name
# API will be available at https://localhost:7000
# Swagger UI at https://localhost:7000/swagger
\`\`\`

## Development
\`\`\`bash
./scripts/build.sh      # Build solution
./scripts/test.sh       # Run tests with coverage
./scripts/quality.sh    # Run all quality checks
\`\`\`

## API Documentation
Once running, visit https://localhost:7000/swagger for interactive API documentation.

## Project Structure
- **src/$project_name/** - Web API project
- **tests/$project_name.Tests/** - API tests
- **.claude/** - Claude TDD + Scrumban workflow files
EOF
    
    # Setup git and Claude workflow
    setup_git_environment "$project_name" || return 1
    
    # Source Claude module for full workflow
    source "$PARENT_DIR/lib/claude.sh"
    create_claude_workflow_files "$project_name" "$description" "net8.0" || return 1
    
    print_success "Web API project created: $project_name"
    print_status "Run: cd $project_name && dotnet run --project src/$project_name"
}

# Main command dispatcher
main() {
    local workflow="$1"
    local project_name="$2"
    local description="$3"
    local project_type="$4"
    
    case "$workflow" in
        "simple")
            if [ -z "$project_name" ]; then
                print_error "Usage: $0 simple <project_name> [description] [project_type]"
                exit 1
            fi
            create_simple_dotnet_project "$project_name" "$description" "$project_type"
            ;;
        "add-claude")
            if [ -z "$project_name" ]; then
                print_error "Usage: $0 add-claude <existing_project_name> [description]"
                exit 1
            fi
            add_claude_to_existing_dotnet "$project_name" "$description"
            ;;
        "dotnet-only")
            if [ -z "$project_name" ]; then
                print_error "Usage: $0 dotnet-only <project_name> [description] [project_type]"
                exit 1
            fi
            create_dotnet_only "$project_name" "$description" "$project_type"
            ;;
        "webapi")
            if [ -z "$project_name" ]; then
                print_error "Usage: $0 webapi <project_name> [description]"
                exit 1
            fi
            create_webapi_project "$project_name" "$description"
            ;;
        *)
            echo "Usage: $0 <workflow> <project_name> [options]"
            echo ""
            echo "Available workflows:"
            echo "  simple      - Create simple .NET project with Git (no Claude workflow)"
            echo "  add-claude  - Add Claude workflow to existing .NET project"
            echo "  dotnet-only - Create minimal .NET project (no Git, no Claude)"
            echo "  webapi      - Create ASP.NET Core Web API with full Claude workflow"
            echo ""
            echo "Examples:"
            echo "  $0 simple my-library \"My .NET library\""
            echo "  $0 add-claude existing-project"
            echo "  $0 dotnet-only test-lib \"Test library\" console"
            echo "  $0 webapi my-api \"REST API service\""
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"