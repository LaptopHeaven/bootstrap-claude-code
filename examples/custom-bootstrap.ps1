# Example: Custom Bootstrap Using Individual Modules - PowerShell Version
# This demonstrates how to use the modular components separately

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Mode,
    
    [Parameter(Mandatory=$true, Position=1)]
    [string]$ProjectName,
    
    [Parameter()]
    [string]$Description = "",
    
    [Parameter()]
    [string]$PythonVersion = "3.12"
)

$ErrorActionPreference = "Stop"

# Get the parent directory to find lib modules
$parentDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

# Source required modules
try {
    . "$parentDir\lib\powershell\core.ps1"
    . "$parentDir\lib\powershell\python.ps1"
    . "$parentDir\lib\powershell\git.ps1"
    . "$parentDir\lib\powershell\claude.ps1"
    . "$parentDir\lib\powershell\templates.ps1"
}
catch {
    Write-Host "Failed to load PowerShell modules: $_" -ForegroundColor Red
    exit 1
}

# Example 1: Simple Python project without Claude workflow
function New-SimplePythonProject {
    param(
        [string]$ProjectName,
        [string]$Description = "Simple Python project",
        [string]$PythonVersion = "3.12"
    )
    
    Write-Status "Creating simple Python project: $ProjectName"
    
    # Set project arguments
    Set-ProjectArguments -ProjectName $ProjectName -Description $Description -PythonVersion $PythonVersion
    
    # Validate and setup
    if (-not (Test-ProjectName $script:PROJECT_NAME)) { return $false }
    if (-not (Test-Prerequisites)) { return $false }
    if (-not (Test-DirectoryExists $script:PROJECT_NAME)) { return $false }
    
    $packageName = Get-PackageName $script:PROJECT_NAME
    
    # Create structure and setup Python environment
    if (-not (New-BasicStructure $script:PROJECT_NAME $packageName)) { return $false }
    Set-Location -Path $script:PROJECT_NAME
    
    if (-not (Initialize-PythonEnvironment $script:PROJECT_NAME $script:PROJECT_DESCRIPTION $script:PYTHON_VERSION)) { return $false }
    
    # Simple README without Claude workflow
    $simpleReadme = @"
# $script:PROJECT_NAME

$script:PROJECT_DESCRIPTION

## Setup
``````powershell
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt -r requirements-dev.txt
python -m pytest tests\ -v
``````

## Development
Follow standard Python development practices with TDD.
"@
    
    $simpleReadme | Out-File -FilePath "README.md" -Encoding UTF8
    
    # Setup git
    if (-not (Initialize-GitEnvironment $script:PROJECT_NAME)) { return $false }
    
    Write-Success "Simple Python project created: $script:PROJECT_NAME"
    return $true
}

# Example 2: Add Claude workflow to existing project
function Add-ClaudeToExisting {
    param(
        [string]$ProjectName,
        [string]$Description = "Existing project with Claude workflow",
        [string]$PythonVersion = "3.12"
    )
    
    if (-not (Test-Path -Path $ProjectName -PathType Container)) {
        Write-Error "Project directory $ProjectName does not exist"
        return $false
    }
    
    Write-Status "Adding Claude workflow to existing project: $ProjectName"
    
    Set-Location -Path $ProjectName
    
    # Create Claude workflow files
    if (-not (Initialize-ClaudeWorkflowFiles $ProjectName $Description $PythonVersion)) { return $false }
    
    Write-Success "Claude workflow added to: $ProjectName"
    return $true
}

# Example 3: Python-only setup (no git, no Claude)
function New-PythonOnlySetup {
    param(
        [string]$ProjectName,
        [string]$Description = "Python-only project",  
        [string]$PythonVersion = "3.12"
    )
    
    Write-Status "Setting up Python-only environment: $ProjectName"
    
    # Set project arguments
    Set-ProjectArguments -ProjectName $ProjectName -Description $Description -PythonVersion $PythonVersion
    
    if (-not (Test-ProjectName $script:PROJECT_NAME)) { return $false }
    if (-not (Test-DirectoryExists $script:PROJECT_NAME)) { return $false }
    
    $packageName = Get-PackageName $script:PROJECT_NAME
    
    if (-not (New-BasicStructure $script:PROJECT_NAME $packageName)) { return $false }
    Set-Location -Path $script:PROJECT_NAME
    
    # Only Python setup, no git or Claude
    if (-not (New-VirtualEnvironment)) { return $false }
    if (-not (Update-Pip)) { return $false }
    if (-not (New-RequirementsFiles $script:PYTHON_VERSION)) { return $false }
    if (-not (Install-DevDependencies)) { return $false }
    if (-not (New-PytestConfig)) { return $false }
    if (-not (New-PyprojectConfig $script:PROJECT_NAME $script:PROJECT_DESCRIPTION $script:PYTHON_VERSION)) { return $false }
    if (-not (New-Gitignore)) { return $false }
    if (-not (New-PythonPackage $packageName $script:PROJECT_NAME $script:PROJECT_DESCRIPTION)) { return $false }
    if (-not (New-SampleTests $packageName $script:PROJECT_NAME)) { return $false }
    if (-not (Test-PythonSetup)) { return $false }
    
    Write-Success "Python-only setup complete: $script:PROJECT_NAME"
    return $true
}

# Main function to demonstrate usage
function Start-CustomBootstrap {
    switch ($Mode.ToLower()) {
        "simple" {
            New-SimplePythonProject -ProjectName $ProjectName -Description $Description -PythonVersion $PythonVersion
        }
        "add-claude" {
            Add-ClaudeToExisting -ProjectName $ProjectName -Description $Description -PythonVersion $PythonVersion
        }
        "python-only" {
            New-PythonOnlySetup -ProjectName $ProjectName -Description $Description -PythonVersion $PythonVersion
        }
        "help" {
            Show-CustomUsage
        }
        default {
            Write-Host "Unknown mode: $Mode" -ForegroundColor Red
            Show-CustomUsage
            exit 1
        }
    }
}

# Function to show usage
function Show-CustomUsage {
    $scriptName = Split-Path -Leaf $MyInvocation.MyCommand.Path
    
    Write-Host "Custom Bootstrap Examples - PowerShell Version"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\$scriptName simple <project_name> [-Description <desc>] [-PythonVersion <ver>]"
    Write-Host "    Creates a simple Python project without Claude workflow"
    Write-Host ""
    Write-Host "  .\$scriptName add-claude <existing_project> [-Description <desc>] [-PythonVersion <ver>]"
    Write-Host "    Adds Claude workflow to an existing project"
    Write-Host ""
    Write-Host "  .\$scriptName python-only <project_name> [-Description <desc>] [-PythonVersion <ver>]"
    Write-Host "    Sets up Python environment only (no git, no Claude)"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\$scriptName simple my-api -Description `"REST API project`" -PythonVersion 3.11"
    Write-Host "  .\$scriptName add-claude existing-project -Description `"Add Claude to existing`""  
    Write-Host "  .\$scriptName python-only test-project -Description `"Just Python setup`""
    Write-Host ""
    Write-Host "Cross-platform note:"
    Write-Host "  This is the PowerShell version. For bash, use custom-bootstrap.sh"
}

# Run main with all arguments
if ($Mode -eq "help" -or $Mode -eq "-help" -or $Mode -eq "--help") {
    Show-CustomUsage
}
else {
    Start-CustomBootstrap
}