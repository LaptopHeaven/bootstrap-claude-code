#!/bin/bash

# Core utilities and shared functions for Claude Python Bootstrap
# Source this file to use common functions across modules

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

# Function to validate project name format
validate_project_name() {
    local project_name="$1"
    
    if [ -z "$project_name" ]; then
        print_error "Project name is required"
        echo ""
        show_usage
        return 1
    fi
    
    if [[ ! "$project_name" =~ ^[a-z][a-z0-9_-]*$ ]]; then
        print_error "Project name must start with a letter and contain only lowercase letters, numbers, hyphens, and underscores"
        echo ""
        show_usage
        return 1
    fi
    
    return 0
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists python3; then
        print_error "Python 3 is not installed"
        return 1
    fi
    
    if ! command_exists git; then
        print_error "Git is not installed"
        return 1
    fi
    
    return 0
}

# Function to check if directory already exists
check_directory_exists() {
    local project_name="$1"
    
    if [ -d "$project_name" ]; then
        print_error "Directory $project_name already exists"
        return 1
    fi
    
    return 0
}

# Function to create basic directory structure
create_basic_structure() {
    local project_name="$1"
    local package_name="$2"
    
    print_status "Creating project directory structure..."
    mkdir -p "$project_name"
    cd "$project_name" || return 1
    
    # Create directory structure
    mkdir -p .claude
    mkdir -p .claude/logs
    mkdir -p "src/$package_name"
    mkdir -p tests/unit
    mkdir -p tests/integration
    mkdir -p docs
    mkdir -p scripts
    
    print_success "Directory structure created"
    return 0
}

# Function to convert project name to package name
get_package_name() {
    local project_name="$1"
    echo "$project_name" | tr '-' '_'
}

# Function to show usage information
show_usage() {
    echo "Usage: $0 <project_name> [options]"
    echo ""
    echo "Creates Python projects with integrated Claude TDD + Scrumban workflow"
    echo ""
    echo "Arguments:"
    echo "  project_name              Name of the project to create"
    echo ""
    echo "Options:"
    echo "  -d, --description <desc>  Project description"
    echo "  -p, --python <version>    Python version (default: 3.12)"
    echo "  -h, --help                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 my-awesome-api -d \"REST API for awesome things\""
    echo "  $0 data-processor -d \"Data processing pipeline\" -p 3.11"
    echo "  $0 ml-experiment -d \"Machine learning experiment\" -p 3.12"
    echo ""
    echo "Features:"
    echo "  - Complete Python project setup with virtual environment and dependencies"
    echo "  - Integrated Claude TDD + Scrumban workflow for efficient development"
    echo "  - Cross-platform development tools and quality gates"
    echo "  - Pytest testing framework with coverage reporting"
    echo "  - Code quality tools: Black, flake8, mypy, isort"
}

# Function to parse command line arguments
parse_arguments() {
    PROJECT_NAME=""
    PROJECT_DESCRIPTION=""
    PYTHON_VERSION="3.12"
    
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
    
    # Set default description if not provided
    if [ -z "$PROJECT_DESCRIPTION" ]; then
        PROJECT_DESCRIPTION="A Python project managed by Claude using TDD + Scrumban workflow"
    fi
}

# Function to validate all inputs
validate_inputs() {
    validate_project_name "$PROJECT_NAME" || return 1
    check_prerequisites || return 1
    check_directory_exists "$PROJECT_NAME" || return 1
    return 0
}

# Export functions for use in other modules
export -f print_status print_success print_warning print_error
export -f command_exists validate_project_name check_prerequisites
export -f check_directory_exists create_basic_structure get_package_name
export -f show_usage parse_arguments validate_inputs