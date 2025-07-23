# .NET 8 environment setup module for Bootstrap Claude Code - PowerShell Version
# Handles .NET project creation, dependency management, and configuration

# Dot-source core utilities
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir\core.ps1"

# Function to check .NET prerequisites
function Test-DotNetPrerequisites {
    Write-Status "Checking .NET prerequisites..."
    
    try {
        $null = Get-Command dotnet -ErrorAction Stop
    }
    catch {
        Write-Error ".NET SDK is not installed. Please install .NET 8 SDK from https://dotnet.microsoft.com/download"
        return $false
    }
    
    # Check .NET version
    try {
        $dotnetVersion = (dotnet --version 2>$null).Split('.')[0]
        if ([int]$dotnetVersion -lt 8) {
            Write-Warning "Found .NET $dotnetVersion. .NET 8+ is recommended for this bootstrap."
        }
    }
    catch {
        Write-Warning "Could not determine .NET version"
    }
    
    Write-Success ".NET SDK found"
    return $true
}

# Function to create .NET solution and project structure
function New-DotNetProject {
    param(
        [string]$ProjectName,
        [string]$ProjectType = "classlib"
    )
    
    Write-Status "Creating .NET solution and project..."
    
    try {
        # Create solution
        & dotnet new sln -n $ProjectName
        if ($LASTEXITCODE -ne 0) { throw "Failed to create solution" }
        
        # Create main project
        New-Item -ItemType Directory -Path "src\$ProjectName" -Force | Out-Null
        Set-Location "src\$ProjectName"
        & dotnet new $ProjectType -n $ProjectName -f net8.0
        if ($LASTEXITCODE -ne 0) { throw "Failed to create main project" }
        Set-Location "..\..\"
        
        # Add main project to solution
        & dotnet sln add "src\$ProjectName\$ProjectName.csproj"
        if ($LASTEXITCODE -ne 0) { throw "Failed to add main project to solution" }
        
        # Create test project
        New-Item -ItemType Directory -Path "tests\$ProjectName.Tests" -Force | Out-Null
        Set-Location "tests\$ProjectName.Tests"
        & dotnet new xunit -n "$ProjectName.Tests" -f net8.0
        if ($LASTEXITCODE -ne 0) { throw "Failed to create test project" }
        Set-Location "..\..\"
        
        # Add test project to solution
        & dotnet sln add "tests\$ProjectName.Tests\$ProjectName.Tests.csproj"
        if ($LASTEXITCODE -ne 0) { throw "Failed to add test project to solution" }
        
        # Add project reference from test to main project
        & dotnet add "tests\$ProjectName.Tests\$ProjectName.Tests.csproj" reference "src\$ProjectName\$ProjectName.csproj"
        if ($LASTEXITCODE -ne 0) { throw "Failed to add project reference" }
        
        Write-Success ".NET solution and projects created"
        return $true
    }
    catch {
        Write-Error "Failed to create .NET project: $_"
        return $false
    }
}

# Function to create global.json for SDK version pinning
function New-GlobalJson {
    Write-Status "Creating global.json..."
    
    try {
        $globalJson = @{
            sdk = @{
                version = "8.0.0"
                rollForward = "latestMinor"
            }
        } | ConvertTo-Json -Depth 3
        
        $globalJson | Out-File -FilePath "global.json" -Encoding UTF8
        Write-Success "global.json created"
        return $true
    }
    catch {
        Write-Error "Failed to create global.json: $_"
        return $false
    }
}

# Function to create Directory.Build.props for shared settings
function New-DirectoryBuildProps {
    param(
        [string]$ProjectName,
        [string]$ProjectDescription
    )
    
    Write-Status "Creating Directory.Build.props..."
    
    try {
        $content = @"
<Project>
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <WarningsNotAsErrors />
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <Authors>$ProjectName Team</Authors>
    <Description>$ProjectDescription</Description>
    <Copyright>Copyright © `$(Authors) `$([System.DateTime]::Now.Year)</Copyright>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.CodeAnalysis.Analyzers" Version="3.3.4">
      <PrivateAssets>all</PrivateAssets>
      <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
    </PackageReference>
  </ItemGroup>
</Project>
"@
        
        $content | Out-File -FilePath "Directory.Build.props" -Encoding UTF8
        Write-Success "Directory.Build.props created"
        return $true
    }
    catch {
        Write-Error "Failed to create Directory.Build.props: $_"
        return $false
    }
}

# Function to create EditorConfig for consistent formatting
function New-EditorConfig {
    Write-Status "Creating .editorconfig..."
    
    try {
        $content = @'
root = true

[*]
charset = utf-8
end_of_line = crlf
indent_style = space
indent_size = 4
insert_final_newline = true
trim_trailing_whitespace = true

[*.{json,yml,yaml}]
indent_size = 2

[*.{sh,ps1}]
end_of_line = lf

# C# files
[*.cs]
indent_size = 4

# Code style rules
dotnet_style_qualification_for_field = false:suggestion
dotnet_style_qualification_for_property = false:suggestion
dotnet_style_qualification_for_method = false:suggestion
dotnet_style_qualification_for_event = false:suggestion

dotnet_style_predefined_type_for_locals_parameters_members = true:suggestion
dotnet_style_predefined_type_for_member_access = true:suggestion

dotnet_style_require_accessibility_modifiers = always:suggestion
dotnet_style_readonly_field = true:suggestion

# Expression-level preferences
dotnet_style_object_initializer = true:suggestion
dotnet_style_collection_initializer = true:suggestion
dotnet_style_explicit_tuple_names = true:suggestion
dotnet_style_null_propagation = true:suggestion
dotnet_style_coalesce_expression = true:suggestion
dotnet_style_prefer_is_null_check_over_reference_equality_method = true:suggestion
dotnet_style_prefer_inferred_tuple_names = true:suggestion
dotnet_style_prefer_inferred_anonymous_type_member_names = true:suggestion

# C# formatting rules
csharp_new_line_before_open_brace = all
csharp_new_line_before_else = true
csharp_new_line_before_catch = true
csharp_new_line_before_finally = true
csharp_new_line_before_members_in_object_initializers = true
csharp_new_line_before_members_in_anonymous_types = true

csharp_indent_case_contents = true
csharp_indent_switch_labels = true

csharp_space_after_cast = false
csharp_space_after_keywords_in_control_flow_statements = true
csharp_space_between_method_declaration_parameter_list_parentheses = false
csharp_space_between_method_call_parameter_list_parentheses = false
'@
        
        $content | Out-File -FilePath ".editorconfig" -Encoding UTF8
        Write-Success ".editorconfig created"
        return $true
    }
    catch {
        Write-Error "Failed to create .editorconfig: $_"
        return $false
    }
}

# Function to setup quality and testing packages
function Initialize-DotNetDependencies {
    param([string]$ProjectName)
    
    Write-Status "Setting up .NET dependencies..."
    
    try {
        # Add testing packages to test project
        Set-Location "tests\$ProjectName.Tests"
        
        # Core testing packages
        & dotnet add package Microsoft.NET.Test.Sdk --version 17.8.0
        if ($LASTEXITCODE -ne 0) { throw "Failed to add Microsoft.NET.Test.Sdk" }
        
        & dotnet add package xunit --version 2.6.1
        if ($LASTEXITCODE -ne 0) { throw "Failed to add xunit" }
        
        & dotnet add package xunit.runner.visualstudio --version 2.5.3
        if ($LASTEXITCODE -ne 0) { throw "Failed to add xunit.runner.visualstudio" }
        
        & dotnet add package coverlet.collector --version 6.0.0
        if ($LASTEXITCODE -ne 0) { throw "Failed to add coverlet.collector" }
        
        # Additional testing utilities
        & dotnet add package FluentAssertions --version 6.12.0
        if ($LASTEXITCODE -ne 0) { throw "Failed to add FluentAssertions" }
        
        & dotnet add package Moq --version 4.20.69
        if ($LASTEXITCODE -ne 0) { throw "Failed to add Moq" }
        
        Set-Location "..\..\"
        
        Write-Success "Dependencies configured"
        return $true
    }
    catch {
        Write-Error "Failed to setup dependencies: $_"
        Set-Location "..\..\" -ErrorAction SilentlyContinue
        return $false
    }
}

# Function to create utility scripts
function New-DotNetUtilityScripts {
    Write-Status "Creating utility scripts..."
    
    try {
        # Create scripts directory if not exists
        if (-not (Test-Path "scripts")) {
            New-Item -ItemType Directory -Path "scripts" | Out-Null
        }
        
        # Test script (Bash)
        $testShContent = @'
#!/bin/bash
echo "Running .NET tests..."
dotnet test --verbosity normal --collect:"XPlat Code Coverage"
'@
        $testShContent | Out-File -FilePath "scripts\test.sh" -Encoding UTF8
        
        # Build script (Bash)
        $buildShContent = @'
#!/bin/bash
echo "Building .NET solution..."
dotnet build --configuration Release --verbosity normal
'@
        $buildShContent | Out-File -FilePath "scripts\build.sh" -Encoding UTF8
        
        # Quality script (Bash)
        $qualityShContent = @'
#!/bin/bash
echo "Running quality checks..."

echo "Building solution..."
dotnet build --configuration Release --no-restore

echo "Running tests with coverage..."
dotnet test --no-build --configuration Release --collect:"XPlat Code Coverage"

echo "Formatting check..."
dotnet format --verify-no-changes --verbosity diagnostic

echo "Quality checks completed!"
'@
        $qualityShContent | Out-File -FilePath "scripts\quality.sh" -Encoding UTF8
        
        # PowerShell versions
        $testPs1Content = @'
Write-Host "Running .NET tests..." -ForegroundColor Blue
dotnet test --verbosity normal --collect:"XPlat Code Coverage"
'@
        $testPs1Content | Out-File -FilePath "scripts\test.ps1" -Encoding UTF8
        
        $buildPs1Content = @'
Write-Host "Building .NET solution..." -ForegroundColor Blue
dotnet build --configuration Release --verbosity normal
'@
        $buildPs1Content | Out-File -FilePath "scripts\build.ps1" -Encoding UTF8
        
        $qualityPs1Content = @'
Write-Host "Running quality checks..." -ForegroundColor Blue

Write-Host "Building solution..." -ForegroundColor Yellow
dotnet build --configuration Release --no-restore

Write-Host "Running tests with coverage..." -ForegroundColor Yellow
dotnet test --no-build --configuration Release --collect:"XPlat Code Coverage"

Write-Host "Formatting check..." -ForegroundColor Yellow
dotnet format --verify-no-changes --verbosity diagnostic

Write-Host "Quality checks completed!" -ForegroundColor Green
'@
        $qualityPs1Content | Out-File -FilePath "scripts\quality.ps1" -Encoding UTF8
        
        Write-Success "Utility scripts created"
        return $true
    }
    catch {
        Write-Error "Failed to create utility scripts: $_"
        return $false
    }
}

# Function to create .NET-specific .gitignore
function New-DotNetGitIgnore {
    Write-Status "Creating .NET .gitignore..."
    
    try {
        $gitignoreContent = @'
## Ignore Visual Studio temporary files, build results, and
## files generated by popular Visual Studio add-ons.
##
## Get latest from https://github.com/github/gitignore/blob/main/VisualStudio.gitignore

# User-specific files
*.rsuser
*.suo
*.user
*.userosscache
*.sln.docstates

# User-specific files (MonoDevelop/Xamarin Studio)
*.userprefs

# Mono auto generated files
mono_crash.*

# Build results
[Dd]ebug/
[Dd]ebugPublic/
[Rr]elease/
[Rr]eleases/
x64/
x86/
[Ww][Ii][Nn]32/
[Aa][Rr][Mm]/
[Aa][Rr][Mm]64/
bld/
[Bb]in/
[Oo]bj/
[Ll]og/
[Ll]ogs/

# Visual Studio 2015/2017 cache/options directory
.vs/
# Uncomment if you have tasks that create the project's static files in wwwroot
#wwwroot/

# Visual Studio 2017 auto generated files
Generated\ Files/

# MSTest test Results
[Tt]est[Rr]esult*/
[Bb]uild[Ll]og.*

# NUnit
*.VisualState.xml
TestResult.xml
nunit-*.xml

# Build Results of an ATL Project
[Dd]ebugPS/
[Rr]eleasePS/
dlldata.c

# Benchmark Results
BenchmarkDotNet.Artifacts/

# .NET Core
project.lock.json
project.fragment.lock.json
artifacts/

# ASP.NET Scaffolding
ScaffoldingReadMe.txt

# StyleCop
StyleCopReport.xml

# Files built by Visual Studio
*_i.c
*_p.c
*_h.h
*.ilk
*.meta
*.obj
*.iobj
*.pch
*.pdb
*.ipdb
*.pgc
*.pgd
*.rsp
*.sbr
*.tlb
*.tli
*.tlh
*.tmp
*.tmp_proj
*_wpftmp.csproj
*.log
*.tlog
*.vspscc
*.vssscc
.builds
*.pidb
*.svclog
*.scc

# Chutzpah Test files
_Chutzpah*

# Visual C++ cache files
ipch/
*.aps
*.ncb
*.opendb
*.opensdf
*.sdf
*.cachefile
*.VC.db
*.VC.VC.opendb

# Visual Studio profiler
*.psess
*.vsp
*.vspx
*.sap

# Visual Studio Trace Files
*.e2e

# TFS 2012 Local Workspace
$tf/

# Guidance Automation Toolkit
*.gpState

# ReSharper is a .NET coding add-in
_ReSharper*/
*.[Rr]e[Ss]harper
*.DotSettings.user

# TeamCity is a build add-in
_TeamCity*

# DotCover is a Code Coverage Tool
*.dotCover

# AxoCover is a Code Coverage Tool
.axoCover/*
!.axoCover/settings.json

# Coverlet is a free, cross platform Code Coverage Tool
coverage*.json
coverage*.xml
coverage*.info

# Visual Studio code coverage results
*.coverage
*.coveragexml

# NCrunch
_NCrunch_*
.*crunch*.local.xml
nCrunchTemp_*

# MightyMoose
*.mm.*
AutoTest.Net/

# Web workbench (sass)
.sass-cache/

# Installshield output folder
[Ee]xpress/

# DocProject is a documentation generator add-in
DocProject/buildhelp/
DocProject/Help/*.HxT
DocProject/Help/*.HxC
DocProject/Help/*.hhc
DocProject/Help/*.hhk
DocProject/Help/*.hhp
DocProject/Help/Html2
DocProject/Help/html

# Click-Once directory
publish/

# Publish Web Output
*.[Pp]ublish.xml
*.azurePubxml
# Note: Comment the next line if you want to checkin your web deploy settings,
# but database connection strings (with potential passwords) will be unencrypted
*.pubxml
*.publishproj

# Microsoft Azure Web App publish settings. Comment the next line if you want to
# checkin your Azure Web App publish settings, but sensitive information contained
# in these files may be public.
*.azurePubxml

# Microsoft Azure Build Output
csx/
*.build.csdef

# Microsoft Azure Emulator
ecf/
rcf/

# Windows Store app package directories and files
AppPackages/
BundleArtifacts/
Package.StoreAssociation.xml
_pkginfo.txt
*.appx
*.appxbundle
*.appxupload

# Visual Studio cache files
# files ending in .cache can be ignored
*.[Cc]ache
# but keep track of directories ending in .cache
!?*.[Cc]ache/

# Others
ClientBin/
~$*
*~
*.dbmdl
*.dbproj.schemaview
*.jfm
*.pfx
*.publishsettings
orleans.codegen.cs

# Including strong name files can present a security risk
# (https://github.com/github/gitignore/pull/2483#issue-259490424)
#*.snk

# Since there are multiple workflows, uncomment the next line to ignore bower_components
# (https://github.com/github/gitignore/pull/1529#issuecomment-104372622)
#bower_components/

# RIA/Silverlight projects
Generated_Code/

# Backup & report files from converting an old project file
# to a newer Visual Studio version. Backup files are not needed,
# because we have git ;-)
_UpgradeReport_Files/
Backup*/
UpgradeLog*.XML
UpgradeLog*.htm
CopySourceAsDestination/

# SQL Server files
*.mdf
*.ldf
*.ndf

# Business Intelligence projects
*.rdl.data
*.bim.layout
*.bim_*.settings
*.rptproj.rsuser
*- [Bb]ackup.rdl
*- [Bb]ackup ([0-9]).rdl
*- [Bb]ackup ([0-9][0-9]).rdl

# Microsoft Fakes
FakesAssemblies/

# GhostDoc plugin setting file
*.GhostDoc.xml

# Node.js Tools for Visual Studio
.ntvs_analysis.dat
node_modules/

# Visual Studio 6 build log
*.plg

# Visual Studio 6 workspace options file
*.opt

# Visual Studio 6 auto-generated workspace file (contains which files were open etc.)
*.vbw

# Visual Studio 6 auto-generated project file (contains which files were open etc.)
*.vbp

# Visual Studio 6 workspace and project file (working project files containing files to include in project)
*.dsw
*.dsp

# Visual Studio 6 technical files
*.ncb
*.aps

# Visual Studio LightSwitch build output
**/*.HTMLClient/GeneratedArtifacts
**/*.DesktopClient/GeneratedArtifacts
**/*.DesktopClient/ModelManifest.xml
**/*.Server/GeneratedArtifacts
**/*.Server/ModelManifest.xml
_Pvt_Extensions

# Paket dependency manager
.paket/paket.exe
paket-files/

# FAKE - F# Make
.fake/

# CodeRush personal settings
.cr/personal

# Python Tools for Visual Studio (PTVS)
__pycache__/
*.pyc

# Cake - Uncomment if you are using it
# tools/**
# !tools/packages.config

# Tabs Studio
*.tss

# Telerik's JustMock configuration file
*.jmconfig

# BizTalk build output
*.btp.cs
*.btm.cs
*.odx.cs
*.xsd.cs

# OpenCover UI analysis results
OpenCover/

# Azure Stream Analytics local run output
ASALocalRun/

# MSBuild Binary and Structured Log
*.binlog

# NVidia Nsight GPU debugger configuration file
*.nvuser

# MFractors (Xamarin productivity tool) working folder
.mfractor/

# Local History for Visual Studio
.localhistory/

# Visual Studio History (VSHistory) files
.vshistory/

# BeatPulse healthcheck temp database
healthchecksdb

# Backup folder for Package Reference Convert tool in Visual Studio 2017
MigrationBackup/

# Ionide (cross platform F# VS Code tools) working folder
.ionide/

# Fody - auto-generated XML schema
FodyWeavers.xsd

# VS Code files for those working on multiple tools
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
*.code-workspace

# Local History for Visual Studio Code
.history/

# Windows Installer files from build outputs
*.cab
*.msi
*.msix
*.msm
*.msp

# JetBrains Rider
*.sln.iml
'@
        
        $gitignoreContent | Out-File -FilePath ".gitignore" -Encoding UTF8
        Write-Success ".NET .gitignore created"
        return $true
    }
    catch {
        Write-Error "Failed to create .gitignore: $_"
        return $false
    }
}

# Function to verify .NET setup
function Test-DotNetSetup {
    Write-Status "Verifying .NET setup..."
    
    try {
        if (-not (Test-Path "global.json")) {
            Write-Error "global.json not found"
            return $false
        }
        
        if (-not (Test-Path "Directory.Build.props")) {
            Write-Error "Directory.Build.props not found"
            return $false
        }
        
        # Try to build the solution
        $buildOutput = & dotnet build --verbosity quiet 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Solution build failed: $buildOutput"
            return $false
        }
        
        # Try to run tests
        $testOutput = & dotnet test --verbosity quiet 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Tests failed: $testOutput"
            return $false
        }
        
        Write-Success ".NET setup verified successfully"
        return $true
    }
    catch {
        Write-Error "Failed to verify .NET setup: $_"
        return $false
    }
}

# Main orchestrator function for .NET environment setup
function Initialize-DotNetEnvironment {
    param(
        [string]$ProjectName,
        [string]$ProjectDescription,
        [string]$ProjectType = "classlib"
    )
    
    Write-Status "Setting up .NET environment for $ProjectName..."
    
    # Check prerequisites
    if (-not (Test-DotNetPrerequisites)) {
        return $false
    }
    
    # Create .NET project structure
    if (-not (New-DotNetProject -ProjectName $ProjectName -ProjectType $ProjectType)) {
        return $false
    }
    
    # Create configuration files
    if (-not (New-GlobalJson)) {
        return $false
    }
    
    if (-not (New-DirectoryBuildProps -ProjectName $ProjectName -ProjectDescription $ProjectDescription)) {
        return $false
    }
    
    if (-not (New-EditorConfig)) {
        return $false
    }
    
    # Setup dependencies
    if (-not (Initialize-DotNetDependencies -ProjectName $ProjectName)) {
        return $false
    }
    
    # Create utility scripts
    if (-not (New-DotNetUtilityScripts)) {
        return $false
    }
    
    # Create .gitignore
    if (-not (New-DotNetGitIgnore)) {
        return $false
    }
    
    # Verify setup
    if (-not (Test-DotNetSetup)) {
        return $false
    }
    
    Write-Success ".NET environment setup completed for $ProjectName"
    return $true
}