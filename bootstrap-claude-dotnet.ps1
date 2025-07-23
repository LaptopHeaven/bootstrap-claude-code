# Bootstrap Claude Code - .NET Projects
# Creates .NET 8 projects with integrated Claude TDD + Scrumban workflow

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ProjectName,
    
    [Parameter()]
    [string]$Description = "",
    
    [Parameter()]
    [ValidateSet("classlib", "console", "webapi", "mvc", "api")]
    [string]$ProjectType = "classlib",
    
    [Parameter()]
    [switch]$Help
)

# Set error action preference for better error handling
$ErrorActionPreference = "Stop"

# Show usage information
function Show-Usage {
    Write-Host "Usage: .\bootstrap-claude-dotnet.ps1 <ProjectName> [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "Creates .NET 8 projects with integrated Claude TDD + Scrumban workflow" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Yellow
    Write-Host "  ProjectName               Name of the project to create" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -Description <desc>       Project description" -ForegroundColor White
    Write-Host "  -ProjectType <type>       Project type (classlib, console, webapi, mvc, api) [default: classlib]" -ForegroundColor White
    Write-Host "  -Help                     Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\bootstrap-claude-dotnet.ps1 MyAwesomeLibrary -Description 'My awesome .NET library'" -ForegroundColor Green
    Write-Host "  .\bootstrap-claude-dotnet.ps1 MyConsoleApp -Description 'Console application' -ProjectType console" -ForegroundColor Green
    Write-Host "  .\bootstrap-claude-dotnet.ps1 MyWebApi -Description 'REST API service' -ProjectType webapi" -ForegroundColor Green
    Write-Host ""
    Write-Host "Features:" -ForegroundColor Cyan
    Write-Host "  - Complete .NET 8 project setup with solution, projects, and dependencies" -ForegroundColor White
    Write-Host "  - Integrated Claude TDD + Scrumban workflow for efficient development" -ForegroundColor White
    Write-Host "  - Cross-platform development tools and quality gates" -ForegroundColor White
}

# Check if help was requested
if ($Help) {
    Show-Usage
    exit 0
}

# Set default description if not provided
if ([string]::IsNullOrEmpty($Description)) {
    $Description = "A .NET 8 project bootstrapped with Claude TDD + Scrumban workflow"
}

# Get script directory for sourcing modules
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Function to source modules with error handling
function Import-Module {
    param(
        [string]$ModulePath,
        [string]$ModuleName
    )
    
    if (Test-Path $ModulePath) {
        try {
            . $ModulePath
            return $true
        }
        catch {
            Write-Host "Failed to load $ModuleName module from $ModulePath : $_" -ForegroundColor Red
            return $false
        }
    }
    else {
        Write-Host "Module not found: $ModulePath" -ForegroundColor Red
        return $false
    }
}

# Load all required modules
Write-Host "Loading Bootstrap Claude Code modules..." -ForegroundColor Cyan

$modulesToLoad = @(
    @{ Path = "$scriptDir\lib\powershell\core.ps1"; Name = "core" },
    @{ Path = "$scriptDir\lib\powershell\dotnet.ps1"; Name = "dotnet" },
    @{ Path = "$scriptDir\lib\powershell\git.ps1"; Name = "git" },
    @{ Path = "$scriptDir\lib\powershell\claude.ps1"; Name = "claude" },
    @{ Path = "$scriptDir\lib\powershell\templates.ps1"; Name = "templates" }
)

$moduleLoadFailed = $false
foreach ($module in $modulesToLoad) {
    if (-not (Import-Module -ModulePath $module.Path -ModuleName $module.Name)) {
        $moduleLoadFailed = $true
    }
}

if ($moduleLoadFailed) {
    Write-Host "Make sure you're running this script from the bootstrap-claude-code directory" -ForegroundColor Yellow
    Write-Host "Required modules:" -ForegroundColor Yellow
    foreach ($module in $modulesToLoad) {
        Write-Host "  - $($module.Path)" -ForegroundColor Yellow
    }
    exit 1
}

Write-Success "All modules loaded successfully"

# Function to create .NET-specific documentation templates
function New-DotNetTemplates {
    param(
        [string]$ProjectName,
        [string]$ProjectDescription,
        [string]$ProjectType,
        [string]$PackageName
    )
    
    Write-Status "Creating .NET documentation templates..."
    
    try {
        $readmeContent = @"
# $ProjectName

$ProjectDescription

## Overview

This is a .NET 8 $ProjectType project bootstrapped with Claude TDD + Scrumban workflow for efficient development.

## Prerequisites

- .NET 8 SDK
- Git

## Getting Started

### Build the project
``````powershell
dotnet build
# or
.\scripts\build.ps1
``````

### Run tests
``````powershell
dotnet test
# or  
.\scripts\test.ps1
``````

### Run quality checks
``````powershell
.\scripts\quality.ps1
``````

## Project Structure

- **src/$ProjectName/** - Main project source code
- **tests/$ProjectName.Tests/** - Unit and integration tests
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
"@
        
        $readmeContent | Out-File -FilePath "README.md" -Encoding UTF8
        Write-Success ".NET documentation templates created"
        return $true
    }
    catch {
        Write-Error "Failed to create .NET documentation templates: $_"
        return $false
    }
}

# Main bootstrap function
function Start-Bootstrap {
    Write-Status "🔧 Creating Claude-managed .NET project: $ProjectName"
    Write-Status "Description: $Description"
    Write-Status "Project type: $ProjectType"
    
    try {
        # Validate project name using core module
        if (-not (Test-ProjectName $ProjectName)) {
            exit 1
        }
        
        # Check if directory already exists using core module
        if (-not (Test-DirectoryNotExists $ProjectName)) {
            exit 1
        }
        
        # Get package name (for directory structure) using core module
        $packageName = Get-PackageName $ProjectName
        Write-Status "Package name: $packageName"
        
        # Create basic project structure using core module
        Write-Status "📁 Creating project structure..."
        if (-not (New-BasicStructure $ProjectName $packageName)) {
            Write-Error "Failed to create basic project structure"
            exit 1
        }
        
        # Change to project directory
        Set-Location $ProjectName
        
        # Setup .NET environment using dotnet module
        Write-Status "🏗️  Setting up .NET environment..."
        if (-not (Initialize-DotNetEnvironment $ProjectName $Description $ProjectType)) {
            Write-Error "Failed to setup .NET environment"
            exit 1
        }
        
        # Setup Git environment using git module
        Write-Status "📋 Setting up Git repository..."
        if (-not (Initialize-GitEnvironment $ProjectName)) {
            Write-Error "Failed to setup Git environment"
            exit 1
        }
        
        # Create Claude workflow files using claude module
        Write-Status "🤖 Creating Claude TDD + Scrumban workflow..."
        if (-not (Initialize-ClaudeWorkflowFiles $ProjectName $Description "net8.0")) {
            Write-Error "Failed to create Claude workflow files"
            exit 1
        }
        
        # Create documentation templates (adapted for .NET)
        Write-Status "📚 Creating documentation templates..."
        if (-not (New-DotNetTemplates $ProjectName $Description $ProjectType $packageName)) {
            Write-Error "Failed to create documentation templates"
            exit 1
        }
        
        # Final verification using dotnet module
        Write-Status "✅ Running final verification..."
        if (-not (Test-DotNetSetup)) {
            Write-Warning "Some verification checks failed, but project was created"
        }
        
        Write-Success "🎉 .NET project '$ProjectName' created successfully!"
        Write-Host ""
        Write-Status "📋 Next steps:"
        Write-Status "1. cd $ProjectName"
        Write-Status "2. Review .claude/CLAUDE.md for development workflow"
        Write-Status "3. .\scripts\test.ps1    # Run tests"
        Write-Status "4. .\scripts\build.ps1   # Build solution"
        Write-Status "5. .\scripts\quality.ps1 # Run quality checks"
        Write-Host ""
        Write-Status "🚀 Happy coding with Claude!"
    }
    catch {
        Write-Error "Bootstrap failed: $_"
        exit 1
    }
}

# Run the main function
Start-Bootstrap