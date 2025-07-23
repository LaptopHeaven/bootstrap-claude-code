# Self-Testing Infrastructure for Bootstrap Claude Code - PowerShell Version
# Tests that bootstrap scripts create working projects

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Test results tracking
$script:TestsRun = 0
$script:TestsPassed = 0
$script:TestsFailed = 0
$script:FailedTests = @()

# Function to print colored output
function Write-TestStatus {
    param([string]$Message)
    Write-Host "[TEST] $Message" -ForegroundColor Blue
}

function Write-TestSuccess {
    param([string]$Message)
    Write-Host "[PASS] $Message" -ForegroundColor Green
    $script:TestsPassed++
}

function Write-TestFailure {
    param([string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
    $script:TestsFailed++
    $script:FailedTests += $Message
}

function Write-TestWarning {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

# Cleanup function
function Remove-TestProjects {
    Write-TestStatus "Cleaning up test projects..."
    Get-ChildItem -Path . -Directory | Where-Object { $_.Name -match "^test-(python|dotnet)-" } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# Test Python bootstrap script
function Test-PythonBootstrap {
    $testName = "Python Bootstrap Script"
    Write-TestStatus "Testing $testName..."
    $script:TestsRun++
    
    $projectName = "test-python-bootstrap-ps"
    
    # Clean up any existing test project
    if (Test-Path $projectName) {
        Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    try {
        # Test the bootstrap script
        $output = & ".\bootstrap-claude-python.ps1" $projectName -Description "Test Python project" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            # Verify project structure
            if ((Test-Path "$projectName") -and (Test-Path "$projectName\pyproject.toml") -and (Test-Path "$projectName\.claude")) {
                # Test if the project actually works
                Set-Location $projectName
                
                try {
                    # Activate virtual environment and test (Windows-specific)
                    if (Test-Path ".venv\Scripts\Activate.ps1") {
                        & ".venv\Scripts\Activate.ps1"
                        $testOutput = & python -m pytest tests\ 2>&1
                        
                        if ($LASTEXITCODE -eq 0) {
                            Write-TestSuccess "$testName - Project created and tests pass"
                            Set-Location ..
                            Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
                            return $true
                        } else {
                            Write-TestFailure "$testName - Project created but tests fail"
                            Set-Location ..
                            Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
                            return $false
                        }
                    } else {
                        Write-TestFailure "$testName - Virtual environment not created properly"
                        Set-Location ..
                        Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
                        return $false
                    }
                }
                catch {
                    Write-TestFailure "$testName - Error testing project: $_"
                    Set-Location ..
                    Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
                    return $false
                }
            } else {
                Write-TestFailure "$testName - Project structure incomplete"
                Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
                return $false
            }
        } else {
            Write-TestFailure "$testName - Bootstrap script failed"
            Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
            return $false
        }
    }
    catch {
        Write-TestFailure "$testName - Exception during test: $_"
        Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
        return $false
    }
}

# Test .NET bootstrap script
function Test-DotNetBootstrap {
    $testName = ".NET Bootstrap Script"
    Write-TestStatus "Testing $testName..."
    $script:TestsRun++
    
    $projectName = "test-dotnet-bootstrap-ps"
    
    # Clean up any existing test project
    if (Test-Path $projectName) {
        Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Check if .NET is available
    try {
        $null = Get-Command dotnet -ErrorAction Stop
    }
    catch {
        Write-TestWarning "$testName - Skipped (.NET SDK not available)"
        $script:TestsRun--  # Don't count as a run test
        return $true
    }
    
    try {
        # Test the bootstrap script
        $output = & ".\bootstrap-claude-dotnet.ps1" $projectName -Description "Test .NET project" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            # Verify project structure
            if ((Test-Path "$projectName") -and (Test-Path "$projectName\global.json") -and (Test-Path "$projectName\.claude")) {
                # Test if the project actually works
                Set-Location $projectName
                
                try {
                    # Test build and run tests
                    $buildOutput = & dotnet build 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        $testOutput = & dotnet test 2>&1
                        if ($LASTEXITCODE -eq 0) {
                            Write-TestSuccess "$testName - Project created and tests pass"
                            Set-Location ..
                            Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
                            return $true
                        } else {
                            Write-TestFailure "$testName - Project created but tests fail"
                            if ($Verbose) { Write-Host "Test output: $testOutput" }
                            Set-Location ..
                            Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
                            return $false
                        }
                    } else {
                        Write-TestFailure "$testName - Project created but build fails"
                        if ($Verbose) { Write-Host "Build output: $buildOutput" }
                        Set-Location ..
                        Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
                        return $false
                    }
                }
                catch {
                    Write-TestFailure "$testName - Error testing project: $_"
                    Set-Location ..
                    Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
                    return $false
                }
            } else {
                Write-TestFailure "$testName - Project structure incomplete"
                Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
                return $false
            }
        } else {
            Write-TestFailure "$testName - Bootstrap script failed"
            if ($Verbose) { Write-Host "Output: $output" }
            Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
            return $false
        }
    }
    catch {
        Write-TestFailure "$testName - Exception during test: $_"
        Remove-Item -Path $projectName -Recurse -Force -ErrorAction SilentlyContinue
        return $false
    }
}

# Test module loading
function Test-ModuleLoading {
    $testName = "PowerShell Module Loading"
    Write-TestStatus "Testing $testName..."
    $script:TestsRun++
    
    try {
        # Test that all PowerShell modules can be loaded without errors
        . ".\lib\powershell\core.ps1"
        . ".\lib\powershell\python.ps1"
        . ".\lib\powershell\dotnet.ps1"
        . ".\lib\powershell\git.ps1"
        . ".\lib\powershell\claude.ps1"
        . ".\lib\powershell\templates.ps1"
        
        Write-TestSuccess "$testName - All PowerShell modules load successfully"
        return $true
    }
    catch {
        Write-TestFailure "$testName - PowerShell module loading failed: $_"
        return $false
    }
}

# Test help output
function Test-HelpOutput {
    $testName = "Help Output"
    Write-TestStatus "Testing $testName..."
    $script:TestsRun++
    
    try {
        # Test that scripts show help when requested
        $pythonHelp = & ".\bootstrap-claude-python.ps1" -Help 2>&1
        $dotnetHelp = & ".\bootstrap-claude-dotnet.ps1" -Help 2>&1
        
        if ($pythonHelp -match "Usage:" -and $dotnetHelp -match "Usage:") {
            Write-TestSuccess "$testName - Bootstrap scripts show proper help"
            return $true
        } else {
            Write-TestFailure "$testName - Help output missing or malformed"
            return $false
        }
    }
    catch {
        Write-TestFailure "$testName - Error testing help output: $_"
        return $false
    }
}

# Test example scripts
function Test-ExampleScripts {
    $testName = "Example Scripts"
    Write-TestStatus "Testing $testName..."
    $script:TestsRun++
    
    try {
        # Test that example scripts have help output
        $customPythonHelp = & ".\examples\custom-bootstrap.ps1" "invalid" "test" 2>&1
        $customDotNetHelp = & ".\examples\custom-bootstrap-dotnet.ps1" "invalid" "test" 2>&1
        
        if ($customPythonHelp -match "Usage:" -and $customDotNetHelp -match "Usage:") {
            Write-TestSuccess "$testName - Example scripts show usage information"
            return $true
        } else {
            Write-TestFailure "$testName - Example scripts missing usage information"
            return $false
        }
    }
    catch {
        Write-TestFailure "$testName - Error testing example scripts: $_"
        return $false
    }
}

# Main test runner
function Main {
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Bootstrap Claude Code - Self-Test Suite" -ForegroundColor Cyan
    Write-Host "PowerShell Edition" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Ensure we're in the right directory
    if (-not (Test-Path "bootstrap-claude-python.ps1") -or -not (Test-Path "bootstrap-claude-dotnet.ps1")) {
        Write-Host "Error: Must run from bootstrap-claude-code directory" -ForegroundColor Red
        exit 1
    }
    
    # Run all tests
    Test-ModuleLoading
    Test-PythonBootstrap
    Test-DotNetBootstrap
    Test-HelpOutput
    Test-ExampleScripts
    
    # Cleanup
    Remove-TestProjects
    
    # Report results
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Test Results Summary" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Tests run: $script:TestsRun"
    Write-Host "Tests passed: $script:TestsPassed"
    Write-Host "Tests failed: $script:TestsFailed"
    
    if ($script:TestsFailed -eq 0) {
        Write-TestSuccess "All tests passed! 🎉"
        exit 0
    } else {
        Write-Host ""
        Write-Host "Failed tests:"
        foreach ($failedTest in $script:FailedTests) {
            Write-Host "  - $failedTest"
        }
        Write-Host ""
        Write-TestFailure "Some tests failed. Please review the output above."
        exit 1
    }
}

# Handle cleanup on exit
try {
    Main
}
finally {
    Remove-TestProjects
}