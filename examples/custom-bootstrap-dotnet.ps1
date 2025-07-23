# Example: Custom .NET Bootstrap Using Individual Modules - PowerShell Version
# This demonstrates how to use the modular .NET components separately

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Mode,
    
    [Parameter(Mandatory=$true, Position=1)]
    [string]$ProjectName,
    
    [Parameter()]
    [string]$Description = "",
    
    [Parameter()]
    [ValidateSet("classlib", "console", "webapi", "mvc", "api")]
    [string]$ProjectType = "classlib"
)

$ErrorActionPreference = "Stop"

# Get the parent directory to find lib modules
$parentDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

# Source required modules
try {
    . "$parentDir\lib\powershell\core.ps1"
    . "$parentDir\lib\powershell\dotnet.ps1"
    . "$parentDir\lib\powershell\git.ps1"
    . "$parentDir\lib\powershell\claude.ps1"
    . "$parentDir\lib\powershell\templates.ps1"
}
catch {
    Write-Host "Failed to load PowerShell modules: $_" -ForegroundColor Red
    exit 1
}

# Example 1: Simple .NET project without Claude workflow
function New-SimpleDotNetProject {
    param(
        [string]$ProjectName,
        [string]$Description = "Simple .NET 8 project",
        [string]$ProjectType = "classlib"
    )
    
    Write-Status "Creating simple .NET project: $ProjectName"
    
    # Validate and setup
    if (-not (Test-ProjectName $ProjectName)) { return $false }
    if (-not (Test-DotNetPrerequisites)) { return $false }
    if (-not (Test-DirectoryNotExists $ProjectName)) { return $false }
    
    $packageName = Get-PackageName $ProjectName
    
    # Create structure and setup .NET environment
    if (-not (New-BasicStructure $ProjectName $packageName)) { return $false }
    Set-Location -Path $ProjectName
    
    if (-not (Initialize-DotNetEnvironment $ProjectName $Description $ProjectType)) { return $false }
    
    # Simple README without Claude workflow
    $simpleReadme = @"
# $ProjectName

$Description

## Setup
``````powershell
dotnet restore
dotnet build
dotnet test
``````

## Development
Follow standard .NET development practices with TDD.

### Project Structure
- **src/$ProjectName/** - Main project source code
- **tests/$ProjectName.Tests/** - Unit and integration tests
- **scripts/** - Build and development utility scripts

### Quality Checks
``````powershell
.\scripts\build.ps1      # Build solution
.\scripts\test.ps1       # Run tests with coverage
.\scripts\quality.ps1    # Run all quality checks
``````
"@
    
    $simpleReadme | Out-File -FilePath "README.md" -Encoding UTF8
    
    # Setup git
    if (-not (Initialize-GitEnvironment $ProjectName)) { return $false }
    
    Write-Success "Simple .NET project created: $ProjectName"
    return $true
}

# Example 2: Add Claude workflow to existing .NET project
function Add-ClaudeToExistingDotNet {
    param(
        [string]$ProjectName,
        [string]$Description = "Existing .NET project with Claude workflow",
        [string]$TargetFramework = "net8.0"
    )
    
    if (-not (Test-Path $ProjectName -PathType Container)) {
        Write-Error "Project directory $ProjectName does not exist"
        return $false
    }
    
    Write-Status "Adding Claude workflow to existing .NET project: $ProjectName"
    
    Set-Location -Path $ProjectName
    
    # Create Claude workflow files
    if (-not (Initialize-ClaudeWorkflowFiles $ProjectName $Description $TargetFramework)) { return $false }
    
    Write-Success "Claude workflow added to: $ProjectName"
    return $true
}

# Example 3: .NET-only setup (no Git, no Claude)
function New-DotNetOnly {
    param(
        [string]$ProjectName,
        [string]$Description = ".NET 8 project (minimal setup)",
        [string]$ProjectType = "classlib"
    )
    
    Write-Status "Creating .NET-only project: $ProjectName"
    
    # Validate and setup
    if (-not (Test-ProjectName $ProjectName)) { return $false }
    if (-not (Test-DotNetPrerequisites)) { return $false }
    if (-not (Test-DirectoryNotExists $ProjectName)) { return $false }
    
    $packageName = Get-PackageName $ProjectName
    
    # Create basic structure (minimal)
    New-Item -ItemType Directory -Path $ProjectName -Force | Out-Null
    Set-Location -Path $ProjectName
    
    # Just create the .NET projects and configuration
    if (-not (New-DotNetProject -ProjectName $ProjectName -ProjectType $ProjectType)) { return $false }
    if (-not (New-GlobalJson)) { return $false }
    if (-not (New-DirectoryBuildProps -ProjectName $ProjectName -ProjectDescription $Description)) { return $false }
    if (-not (New-EditorConfig)) { return $false }
    if (-not (Initialize-DotNetDependencies -ProjectName $ProjectName)) { return $false }
    if (-not (New-DotNetGitIgnore)) { return $false }
    
    # Minimal README
    $minimalReadme = @"
# $ProjectName

$Description

A minimal .NET 8 $ProjectType project.

## Quick Start
``````powershell
dotnet build
dotnet test
``````
"@
    
    $minimalReadme | Out-File -FilePath "README.md" -Encoding UTF8
    
    Write-Success ".NET-only project created: $ProjectName"
    return $true
}

# Example 4: Web API with full setup
function New-WebApiProject {
    param(
        [string]$ProjectName,
        [string]$Description = "ASP.NET Core Web API with Claude workflow"
    )
    
    Write-Status "Creating Web API project: $ProjectName"
    
    # Validate and setup
    if (-not (Test-ProjectName $ProjectName)) { return $false }
    if (-not (Test-DotNetPrerequisites)) { return $false }
    if (-not (Test-DirectoryNotExists $ProjectName)) { return $false }
    
    $packageName = Get-PackageName $ProjectName
    
    # Create structure and setup .NET Web API environment
    if (-not (New-BasicStructure $ProjectName $packageName)) { return $false }
    Set-Location -Path $ProjectName
    
    if (-not (Initialize-DotNetEnvironment $ProjectName $Description "webapi")) { return $false }
    
    # Add Web API specific packages
    Set-Location -Path "src\$ProjectName"
    try {
        & dotnet add package Swashbuckle.AspNetCore --version 6.5.0
        & dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.0
    }
    catch {
        Write-Warning "Failed to add some Web API packages: $_"
    }
    Set-Location -Path "..\..\"
    
    # Web API specific README
    $webapiReadme = @"
# $ProjectName

$Description

An ASP.NET Core Web API project with Claude TDD + Scrumban workflow.

## Quick Start
``````powershell
dotnet run --project src\$ProjectName
# API will be available at https://localhost:7000
# Swagger UI at https://localhost:7000/swagger
``````

## Development
``````powershell
.\scripts\build.ps1      # Build solution
.\scripts\test.ps1       # Run tests with coverage
.\scripts\quality.ps1    # Run all quality checks
``````

## API Documentation
Once running, visit https://localhost:7000/swagger for interactive API documentation.

## Project Structure
- **src/$ProjectName/** - Web API project
- **tests/$ProjectName.Tests/** - API tests
- **.claude/** - Claude TDD + Scrumban workflow files
"@
    
    $webapiReadme | Out-File -FilePath "README.md" -Encoding UTF8
    
    # Setup git and Claude workflow
    if (-not (Initialize-GitEnvironment $ProjectName)) { return $false }
    
    # Create full Claude workflow
    if (-not (Initialize-ClaudeWorkflowFiles $ProjectName $Description "net8.0")) { return $false }
    
    Write-Success "Web API project created: $ProjectName"
    Write-Status "Run: cd $ProjectName; dotnet run --project src\$ProjectName"
    return $true
}

# Main command dispatcher
switch ($Mode.ToLower()) {
    "simple" {
        if ([string]::IsNullOrEmpty($Description)) {
            $Description = "Simple .NET 8 project"
        }
        $result = New-SimpleDotNetProject -ProjectName $ProjectName -Description $Description -ProjectType $ProjectType
        if (-not $result) { exit 1 }
    }
    "add-claude" {
        if ([string]::IsNullOrEmpty($Description)) {
            $Description = "Existing .NET project with Claude workflow"
        }
        $result = Add-ClaudeToExistingDotNet -ProjectName $ProjectName -Description $Description
        if (-not $result) { exit 1 }
    }
    "dotnet-only" {
        if ([string]::IsNullOrEmpty($Description)) {
            $Description = ".NET 8 project (minimal setup)"
        }
        $result = New-DotNetOnly -ProjectName $ProjectName -Description $Description -ProjectType $ProjectType
        if (-not $result) { exit 1 }
    }
    "webapi" {
        if ([string]::IsNullOrEmpty($Description)) {
            $Description = "ASP.NET Core Web API with Claude workflow"
        }
        $result = New-WebApiProject -ProjectName $ProjectName -Description $Description
        if (-not $result) { exit 1 }
    }
    default {
        Write-Host "Usage: .\custom-bootstrap-dotnet.ps1 <Mode> <ProjectName> [options]" -ForegroundColor White
        Write-Host ""
        Write-Host "Available modes:" -ForegroundColor Yellow
        Write-Host "  simple      - Create simple .NET project with Git (no Claude workflow)" -ForegroundColor White
        Write-Host "  add-claude  - Add Claude workflow to existing .NET project" -ForegroundColor White
        Write-Host "  dotnet-only - Create minimal .NET project (no Git, no Claude)" -ForegroundColor White
        Write-Host "  webapi      - Create ASP.NET Core Web API with full Claude workflow" -ForegroundColor White
        Write-Host ""
        Write-Host "Examples:" -ForegroundColor Yellow
        Write-Host "  .\custom-bootstrap-dotnet.ps1 simple MyLibrary -Description 'My .NET library'" -ForegroundColor Green
        Write-Host "  .\custom-bootstrap-dotnet.ps1 add-claude ExistingProject" -ForegroundColor Green
        Write-Host "  .\custom-bootstrap-dotnet.ps1 dotnet-only TestLib -Description 'Test library' -ProjectType console" -ForegroundColor Green
        Write-Host "  .\custom-bootstrap-dotnet.ps1 webapi MyApi -Description 'REST API service'" -ForegroundColor Green
        exit 1
    }
}