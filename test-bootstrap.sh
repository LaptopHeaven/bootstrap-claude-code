#!/bin/bash

# Self-Testing Infrastructure for Bootstrap Claude Code
# Tests that bootstrap scripts create working projects

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Function to print colored output
print_test_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_test_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

print_test_failure() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
    FAILED_TESTS+=("$1")
}

print_test_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Cleanup function
cleanup_test_projects() {
    print_test_status "Cleaning up test projects..."
    rm -rf test-python-* test-dotnet-* 2>/dev/null || true
}

# Test Python bootstrap script
test_python_bootstrap() {
    local test_name="Python Bootstrap Script"
    print_test_status "Testing $test_name..."
    ((TESTS_RUN++))
    
    local project_name="test-python-bootstrap"
    
    # Clean up any existing test project
    rm -rf "$project_name" 2>/dev/null || true
    
    # Test the bootstrap script
    if ./bootstrap-claude-python.sh "$project_name" -d "Test Python project" >/dev/null 2>&1; then
        # Verify project structure
        if [[ -d "$project_name" && -f "$project_name/pyproject.toml" && -d "$project_name/.claude" ]]; then
            # Simplified test - just check if virtual env and package structure exist
            if [[ -f "$project_name/.venv/bin/activate" && -f "$project_name/src/${project_name//-/_}/__init__.py" ]]; then
                print_test_success "$test_name - Project created with correct structure"
                rm -rf "$project_name"
                return 0
            else
                print_test_failure "$test_name - Virtual environment or package structure missing"
                rm -rf "$project_name" 
                return 1
            fi
        else
            print_test_failure "$test_name - Project structure incomplete"
            rm -rf "$project_name"
            return 1
        fi
    else
        print_test_failure "$test_name - Bootstrap script failed"
        rm -rf "$project_name"
        return 1
    fi
}

# Test .NET bootstrap script
test_dotnet_bootstrap() {
    local test_name=".NET Bootstrap Script"
    print_test_status "Testing $test_name..."
    ((TESTS_RUN++))
    
    local project_name="test-dotnet-bootstrap"
    
    # Clean up any existing test project
    rm -rf "$project_name" 2>/dev/null || true
    
    # Check if .NET is available
    if ! command -v dotnet >/dev/null 2>&1; then
        print_test_warning "$test_name - Skipped (.NET SDK not available)"
        ((TESTS_RUN--))  # Don't count as a run test
        return 0
    fi
    
    # Test the bootstrap script
    if ./bootstrap-claude-dotnet.sh "$project_name" -d "Test .NET project" >/dev/null 2>&1; then
        # Verify project structure
        if [[ -d "$project_name" && -f "$project_name/global.json" && -d "$project_name/.claude" ]]; then
            # Test if the project actually works
            cd "$project_name"
            
            # Test build and run tests
            if dotnet build >/dev/null 2>&1 && dotnet test >/dev/null 2>&1; then
                print_test_success "$test_name - Project created and tests pass"
                cd ..
                rm -rf "$project_name"
                return 0
            else
                print_test_failure "$test_name - Project created but build/test fails"
                cd ..
                rm -rf "$project_name"
                return 1
            fi
        else
            print_test_failure "$test_name - Project structure incomplete"
            rm -rf "$project_name"
            return 1
        fi
    else
        print_test_failure "$test_name - Bootstrap script failed"
        rm -rf "$project_name"
        return 1
    fi
}

# Test module loading
test_module_loading() {
    local test_name="Module Loading"
    print_test_status "Testing $test_name..."
    ((TESTS_RUN++))
    
    # Test that all modules can be loaded without errors
    local output
    output=$(bash -c 'source lib/core.sh && source lib/python.sh && source lib/dotnet.sh && source lib/git.sh && source lib/claude.sh && source lib/templates.sh' 2>&1)
    if [[ $? -eq 0 ]]; then
        print_test_success "$test_name - All modules load successfully"
        return 0
    else
        print_test_failure "$test_name - Module loading failed"
        echo "Error output: $output" >&2
        return 1
    fi
}

# Test cross-platform consistency (basic check)
test_cross_platform_consistency() {
    local test_name="Cross-Platform Consistency"
    print_test_status "Testing $test_name..."
    ((TESTS_RUN++))
    
    # Test that both Bash and PowerShell scripts have similar help output
    local bash_help_lines=$(./bootstrap-claude-python.sh --help 2>&1 | wc -l)
    
    # Check if PowerShell is available
    if command -v pwsh >/dev/null 2>&1 || command -v powershell >/dev/null 2>&1; then
        local ps_cmd="pwsh"
        if ! command -v pwsh >/dev/null 2>&1; then
            ps_cmd="powershell"
        fi
        
        local ps_help_lines=$($ps_cmd -File bootstrap-claude-python.ps1 -Help 2>&1 | wc -l)
        
        # Help output should be reasonably similar in length (within 50% difference)
        local ratio=$((bash_help_lines * 100 / ps_help_lines))
        if [[ $ratio -ge 50 && $ratio -le 150 ]]; then
            print_test_success "$test_name - Help output consistency check passed"
            return 0
        else
            print_test_failure "$test_name - Help output differs significantly (Bash: $bash_help_lines lines, PS: $ps_help_lines lines)"
            return 1
        fi
    else
        print_test_warning "$test_name - Skipped (PowerShell not available)"
        ((TESTS_RUN--))  # Don't count as a run test
        return 0
    fi
}

# Test example scripts
test_example_scripts() {
    local test_name="Example Scripts"
    print_test_status "Testing $test_name..."
    ((TESTS_RUN++))
    
    # Test that example scripts have help output
    if ./examples/custom-bootstrap.sh 2>&1 | grep -q "Usage:" && 
       ./examples/custom-bootstrap-dotnet.sh 2>&1 | grep -q "Usage:"; then
        print_test_success "$test_name - Example scripts show usage information"
        return 0
    else
        print_test_failure "$test_name - Example scripts missing usage information"
        return 1
    fi
}

# Main test runner
main() {
    echo "=========================================="
    echo "Bootstrap Claude Code - Self-Test Suite"
    echo "=========================================="
    echo ""
    
    # Ensure we're in the right directory
    if [[ ! -f "bootstrap-claude-python.sh" || ! -f "bootstrap-claude-dotnet.sh" ]]; then
        echo "Error: Must run from bootstrap-claude-code directory"
        exit 1
    fi
    
    # Make sure scripts are executable
    chmod +x bootstrap-claude-python.sh bootstrap-claude-dotnet.sh examples/*.sh
    
    # Run all tests
    test_module_loading
    test_python_bootstrap
    test_dotnet_bootstrap
    test_cross_platform_consistency
    test_example_scripts
    
    # Cleanup
    cleanup_test_projects
    
    # Report results
    echo ""
    echo "=========================================="
    echo "Test Results Summary"
    echo "=========================================="
    echo "Tests run: $TESTS_RUN"
    echo "Tests passed: $TESTS_PASSED"
    echo "Tests failed: $TESTS_FAILED"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        print_test_success "All tests passed! 🎉"
        exit 0
    else
        echo ""
        echo "Failed tests:"
        for failed_test in "${FAILED_TESTS[@]}"; do
            echo "  - $failed_test"
        done
        echo ""
        print_test_failure "Some tests failed. Please review the output above."
        exit 1
    fi
}

# Handle cleanup on exit
trap cleanup_test_projects EXIT

# Run the tests
main "$@"