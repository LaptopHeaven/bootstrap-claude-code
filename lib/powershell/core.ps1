# Core utilities and shared functions for Claude Python Bootstrap - PowerShell Version
# Dot-source this file to use common functions across modules

# Global variables for project configuration
$script:PROJECT_NAME = ""
$script:PROJECT_DESCRIPTION = ""
$script:PYTHON_VERSION = "3.12"
$script:PACKAGE_NAME = ""

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Function to check if command exists
function Test-CommandExists {
    param([string]$CommandName)
    
    try {
        if (Get-Command $CommandName -ErrorAction SilentlyContinue) {
            return $true
        }
        return $false
    }
    catch {
        return $false
    }
}

# Function to validate project name format
function Test-ProjectName {
    param([string]$ProjectName)
    
    if ([string]::IsNullOrEmpty($ProjectName)) {
        Write-Error "Project name is required"
        return $false
    }
    
    if ($ProjectName -notmatch '^[a-z][a-z0-9_-]*$') {
        Write-Error "Project name must start with a letter and contain only lowercase letters, numbers, hyphens, and underscores"
        return $false
    }
    
    return $true
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Status "Checking prerequisites..."
    
    # Try python3 first, then python (Windows typically uses just 'python')
    $pythonCmd = $null
    if (Test-CommandExists "python3") {
        $pythonCmd = "python3"
    }
    elseif (Test-CommandExists "python") {
        $pythonCmd = "python"
    }
    else {
        Write-Error "Python 3 is not installed or not in PATH"
        return $false
    }
    
    # Set global python command
    $script:PYTHON_CMD = $pythonCmd
    
    if (-not (Test-CommandExists "git")) {
        Write-Error "Git is not installed or not in PATH"
        return $false
    }
    
    return $true
}

# Function to check if directory already exists
function Test-DirectoryExists {
    param([string]$ProjectName)
    
    if (Test-Path -Path $ProjectName -PathType Container) {
        Write-Error "Directory $ProjectName already exists"
        return $false
    }
    
    return $true
}

# Function to create basic directory structure
function New-BasicStructure {
    param(
        [string]$ProjectName,
        [string]$PackageName
    )
    
    Write-Status "Creating project directory structure..."
    
    # Create project directory
    New-Item -ItemType Directory -Path $ProjectName -Force | Out-Null
    Set-Location -Path $ProjectName
    
    # Create directory structure
    $directories = @(
        ".claude",
        ".claude\logs",
        "src\$PackageName",
        "tests\unit",
        "tests\integration", 
        "docs",
        "scripts"
    )
    
    foreach ($dir in $directories) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    Write-Success "Directory structure created"
    return $true
}

# Function to convert project name to package name
function Get-PackageName {
    param([string]$ProjectName)
    return $ProjectName -replace '-', '_'
}

# Function to show usage information
function Show-Usage {
    $scriptName = $MyInvocation.PSCommandPath
    if ($scriptName) {
        $scriptName = Split-Path $scriptName -Leaf
    } else {
        $scriptName = "bootstrap-claude-python.ps1"
    }
    
    Write-Host "Usage: .$scriptName <project_name> [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Description <desc>    Project description"
    Write-Host "  -PythonVersion <ver>   Python version (default: 3.12)"
    Write-Host "  -Help                  Show this help"
    Write-Host ""
    Write-Host "Example:"
    Write-Host "  .$scriptName my-awesome-api -Description `"REST API for awesome things`" -PythonVersion 3.11"
}

# Function to parse command line arguments
function Set-ProjectArguments {
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
    
    if ($Help) {
        Show-Usage
        exit 0
    }
    
    # Set script-level variables
    $script:PROJECT_NAME = $ProjectName
    $script:PYTHON_VERSION = $PythonVersion
    
    # Set default description if not provided
    if ([string]::IsNullOrEmpty($Description)) {
        $script:PROJECT_DESCRIPTION = "A Python project managed by Claude using TDD + Scrumban workflow"
    } else {
        $script:PROJECT_DESCRIPTION = $Description
    }
    
    # Set package name
    $script:PACKAGE_NAME = Get-PackageName $ProjectName
}

# Function to validate all inputs
function Test-AllInputs {
    if (-not (Test-ProjectName $script:PROJECT_NAME)) {
        return $false
    }
    
    if (-not (Test-Prerequisites)) {
        return $false
    }
    
    if (-not (Test-DirectoryExists $script:PROJECT_NAME)) {
        return $false
    }
    
    return $true
}

# Function to get virtual environment activation path
function Get-VenvActivatePath {
    if (Test-Path ".venv\Scripts\Activate.ps1") {
        return ".\.venv\Scripts\Activate.ps1"
    }
    elseif (Test-Path ".venv\Scripts\activate.ps1") {
        return ".\.venv\Scripts\activate.ps1"
    }
    else {
        return $null
    }
}

# Function to activate virtual environment
function Enable-VirtualEnvironment {
    $activatePath = Get-VenvActivatePath
    if ($activatePath) {
        try {
            & $activatePath
            return $true
        }
        catch {
            Write-Warning "Failed to activate virtual environment: $_"
            return $false
        }
    }
    else {
        Write-Warning "Virtual environment activation script not found"
        return $false
    }
}

# Function to get current date/time for templates
function Get-CurrentDateTime {
    return Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

# Function to get current date for templates
function Get-CurrentDate {
    return Get-Date -Format "yyyy-MM-dd"
}

# Export key variables and functions for use in other modules
# Note: PowerShell doesn't have exactly the same export mechanism as bash,
# but dot-sourcing this file makes all functions available