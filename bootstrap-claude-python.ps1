# Bootstrap Claude Code - Python Projects
# Creates Python projects with integrated Claude TDD + Scrumban workflow

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ProjectName,
    
    [Parameter()]
    [string]$Description = "",
    
    [Parameter()]
    [string]$PythonVersion = "3.12",
    
    [Parameter()]
    [switch]$Help
)

# Set error action preference for better error handling
$ErrorActionPreference = "Stop"

# Show usage information
function Show-Usage {
    Write-Host "Usage: .\bootstrap-claude-python.ps1 <ProjectName> [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "Creates Python projects with integrated Claude TDD + Scrumban workflow" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Yellow
    Write-Host "  ProjectName               Name of the project to create" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -Description <desc>       Project description" -ForegroundColor White
    Write-Host "  -PythonVersion <version>  Python version (default: 3.12)" -ForegroundColor White
    Write-Host "  -Help                     Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\bootstrap-claude-python.ps1 MyAwesomeApi -Description 'REST API for awesome things'" -ForegroundColor Green
    Write-Host "  .\bootstrap-claude-python.ps1 DataProcessor -Description 'Data processing pipeline' -PythonVersion 3.11" -ForegroundColor Green
    Write-Host "  .\bootstrap-claude-python.ps1 MlExperiment -Description 'Machine learning experiment' -PythonVersion 3.12" -ForegroundColor Green
    Write-Host ""
    Write-Host "Features:" -ForegroundColor Cyan
    Write-Host "  - Complete Python project setup with virtual environment and dependencies" -ForegroundColor White
    Write-Host "  - Integrated Claude TDD + Scrumban workflow for efficient development" -ForegroundColor White
    Write-Host "  - Cross-platform development tools and quality gates" -ForegroundColor White
    Write-Host "  - Pytest testing framework with coverage reporting" -ForegroundColor White
    Write-Host "  - Code quality tools: Black, flake8, mypy, isort" -ForegroundColor White
}

# Check if help was requested
if ($Help) {
    Show-Usage
    exit 0
}

# Get script directory for sourcing modules
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Source required modules
try {
    . "$scriptDir\lib\powershell\core.ps1"
    . "$scriptDir\lib\powershell\python.ps1"
    . "$scriptDir\lib\powershell\git.ps1"
    . "$scriptDir\lib\powershell\claude.ps1"
    . "$scriptDir\lib\powershell\templates.ps1"
}
catch {
    Write-Host "Failed to load PowerShell modules: $_" -ForegroundColor Red
    Write-Host "Make sure you're running this script from the bootstrap-claude-code directory" -ForegroundColor Yellow
    Write-Host "Required modules:" -ForegroundColor Yellow
    Write-Host "  - lib\powershell\core.ps1" -ForegroundColor Yellow
    Write-Host "  - lib\powershell\python.ps1" -ForegroundColor Yellow
    Write-Host "  - lib\powershell\git.ps1" -ForegroundColor Yellow
    Write-Host "  - lib\powershell\claude.ps1" -ForegroundColor Yellow
    Write-Host "  - lib\powershell\templates.ps1" -ForegroundColor Yellow
    exit 1
}

# Main bootstrap function
function Start-ModularBootstrap {
    # Parse command line arguments (sets global variables)
    try {
        Set-ProjectArguments -ProjectName $ProjectName -Description $Description -PythonVersion $PythonVersion -Help:$Help
    }
    catch {
        Write-Error "Failed to parse arguments: $_"
        exit 1
    }
    
    # Validate all inputs
    if (-not (Test-AllInputs)) {
        exit 1
    }
    
    Write-Status "Creating Claude-managed Python project: $script:PROJECT_NAME"
    Write-Status "Package name: $script:PACKAGE_NAME"
    Write-Status "Description: $script:PROJECT_DESCRIPTION"  
    Write-Status "Python version: $script:PYTHON_VERSION"
    
    try {
        # Create basic project structure
        if (-not (New-BasicStructure $script:PROJECT_NAME $script:PACKAGE_NAME)) {
            Write-Error "Failed to create basic project structure"
            exit 1
        }
        
        # Setup Python environment
        if (-not (Initialize-PythonEnvironment $script:PROJECT_NAME $script:PROJECT_DESCRIPTION $script:PYTHON_VERSION)) {
            Write-Error "Failed to setup Python environment"
            exit 1
        }
        
        # Create Claude workflow files
        if (-not (Initialize-ClaudeWorkflowFiles $script:PROJECT_NAME $script:PROJECT_DESCRIPTION $script:PYTHON_VERSION)) {
            Write-Error "Failed to create Claude workflow files"
            exit 1
        }
        
        # Create documentation templates
        if (-not (New-AllTemplates $script:PROJECT_NAME $script:PROJECT_DESCRIPTION $script:PYTHON_VERSION $script:PACKAGE_NAME)) {
            Write-Error "Failed to create documentation templates"
            exit 1
        }
        
        # Setup git environment (includes initial commit)
        if (-not (Initialize-GitEnvironment $script:PROJECT_NAME)) {
            Write-Error "Failed to setup Git environment"
            exit 1
        }
        
        # Show completion message
        Show-ModularCompletionMessage
    }
    catch {
        Write-Error "Modular bootstrap failed: $_"
        exit 1
    }
}

# Function to show completion message and next steps
function Show-ModularCompletionMessage {
    Write-Success "Project $script:PROJECT_NAME created successfully!"
    Write-Host ""
    Write-Status "Next steps:"
    Write-Host "  1. Set-Location $script:PROJECT_NAME"
    Write-Host "  2. .\.venv\Scripts\Activate.ps1"
    Write-Host "  3. Review .claude\prd.md and customize for your project"
    Write-Host "  4. Start with Claude: '/signin backend' or '/signin frontend'"
    Write-Host ""
    Write-Status "Useful commands:"
    Write-Host "  python -m pytest tests\ -v                    # Run tests"
    Write-Host "  .\scripts\test.ps1                            # Run tests with coverage"
    Write-Host "  .\scripts\quality.ps1                         # Run all quality checks"
    Write-Host "  python -m black src\ tests\                   # Format code"
    Write-Host ""
    Write-Status "Claude session commands:"
    Write-Host "  /signin [domain]                              # Start session with context"
    Write-Host "  /signout                                      # End session with state updates"
    Write-Host "  /update                                       # Refresh all documentation"
    Write-Host "  /status                                       # Quick status check"
    Write-Host ""
    Write-Status "Modular usage (PowerShell):"
    Write-Host "  Source individual modules from lib\powershell\ for custom workflows"
    Write-Host "  Example: . .\lib\powershell\core.ps1; . .\lib\powershell\python.ps1"
    Write-Host "  See README.md for examples of using modules separately"
    Write-Host ""
    Write-Status "Cross-platform compatibility:"
    Write-Host "  Windows: Use .ps1 scripts and PowerShell syntax"
    Write-Host "  Linux/macOS/WSL: Use .sh scripts and bash syntax"
    Write-Host "  Both versions create identical project structures"
    Write-Host ""
    Write-Status "Claude instructions:"
    Write-Host "  Tell Claude: 'Read CLAUDE.md and execute /signin [domain] protocol'"
}

# Run main function
Start-ModularBootstrap