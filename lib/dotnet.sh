#!/bin/bash

# .NET 8 environment setup module for Bootstrap Claude Code
# Handles .NET project creation, dependency management, and configuration

# Source core utilities (if not already loaded)
if ! command -v print_status >/dev/null 2>&1; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/core.sh"
fi

# Function to check .NET prerequisites
check_dotnet_prerequisites() {
    print_status "Checking .NET prerequisites..."
    
    if ! command_exists dotnet; then
        print_error ".NET SDK is not installed. Please install .NET 8 SDK from https://dotnet.microsoft.com/download"
        return 1
    fi
    
    # Check .NET version
    local dotnet_version=$(dotnet --version 2>/dev/null | cut -d'.' -f1)
    if [ "$dotnet_version" -lt 8 ]; then
        print_warning "Found .NET $dotnet_version. .NET 8+ is recommended for this bootstrap."
    fi
    
    print_success ".NET SDK found"
    return 0
}

# Function to create .NET solution and project structure
create_dotnet_project() {
    local project_name="$1"
    local project_type="${2:-classlib}"  # classlib, console, webapi, etc.
    
    print_status "Creating .NET solution and project..."
    
    # Create solution
    dotnet new sln -n "$project_name" || return 1
    
    # Create main project
    mkdir -p "src/$project_name"
    cd "src/$project_name" || return 1
    dotnet new "$project_type" -n "$project_name" -f net8.0 || return 1
    cd ../.. || return 1
    
    # Add main project to solution
    dotnet sln add "src/$project_name/$project_name.csproj" || return 1
    
    # Create test project
    mkdir -p "tests/${project_name}.Tests"
    cd "tests/${project_name}.Tests" || return 1
    dotnet new xunit -n "${project_name}.Tests" -f net8.0 || return 1
    cd ../.. || return 1
    
    # Add test project to solution
    dotnet sln add "tests/${project_name}.Tests/${project_name}.Tests.csproj" || return 1
    
    # Add project reference from test to main project
    dotnet add "tests/${project_name}.Tests/${project_name}.Tests.csproj" reference "src/$project_name/$project_name.csproj" || return 1
    
    print_success ".NET solution and projects created"
}

# Function to create global.json for SDK version pinning
create_global_json() {
    print_status "Creating global.json..."
    
    cat > global.json << 'EOF'
{
  "sdk": {
    "version": "8.0.0",
    "rollForward": "latestMinor"
  }
}
EOF
    
    print_success "global.json created"
}

# Function to create Directory.Build.props for shared settings
create_directory_build_props() {
    local project_name="$1"
    local project_description="$2"
    
    print_status "Creating Directory.Build.props..."
    
    cat > Directory.Build.props << EOF
<Project>
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <WarningsNotAsErrors />
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <Authors>$project_name Team</Authors>
    <Description>$project_description</Description>
    <Copyright>Copyright © \$(Authors) \$([System.DateTime]::Now.Year)</Copyright>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.CodeAnalysis.Analyzers" Version="3.3.4">
      <PrivateAssets>all</PrivateAssets>
      <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
    </PackageReference>
  </ItemGroup>
</Project>
EOF
    
    print_success "Directory.Build.props created"
}

# Function to create EditorConfig for consistent formatting
create_editorconfig() {
    print_status "Creating .editorconfig..."
    
    cat > .editorconfig << 'EOF'
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
EOF
    
    print_success ".editorconfig created"
}

# Function to setup quality and testing packages
setup_dotnet_dependencies() {
    local project_name="$1"
    
    print_status "Setting up .NET dependencies..."
    
    # Add testing packages to test project
    cd "tests/${project_name}.Tests" || return 1
    
    # Core testing packages
    dotnet add package Microsoft.NET.Test.Sdk --version 17.8.0 || return 1
    dotnet add package xunit --version 2.6.1 || return 1
    dotnet add package xunit.runner.visualstudio --version 2.5.3 || return 1
    dotnet add package coverlet.collector --version 6.0.0 || return 1
    
    # Additional testing utilities
    dotnet add package FluentAssertions --version 6.12.0 || return 1
    dotnet add package Moq --version 4.20.69 || return 1
    
    cd ../.. || return 1
    
    print_success "Dependencies configured"
}

# Function to create utility scripts
create_dotnet_utility_scripts() {
    print_status "Creating utility scripts..."
    
    # Test script
    cat > scripts/test.sh << 'EOF'
#!/bin/bash
echo "Running .NET tests..."
dotnet test --verbosity normal --collect:"XPlat Code Coverage"
EOF
    chmod +x scripts/test.sh
    
    # Build script
    cat > scripts/build.sh << 'EOF'
#!/bin/bash
echo "Building .NET solution..."
dotnet build --configuration Release --verbosity normal
EOF
    chmod +x scripts/build.sh
    
    # Quality script
    cat > scripts/quality.sh << 'EOF'
#!/bin/bash
echo "Running quality checks..."

echo "Building solution..."
dotnet build --configuration Release --no-restore

echo "Running tests with coverage..."
dotnet test --no-build --configuration Release --collect:"XPlat Code Coverage"

echo "Formatting check..."
dotnet format --verify-no-changes --verbosity diagnostic

echo "Quality checks completed!"
EOF
    chmod +x scripts/quality.sh
    
    # PowerShell versions
    cat > scripts/test.ps1 << 'EOF'
Write-Host "Running .NET tests..." -ForegroundColor Blue
dotnet test --verbosity normal --collect:"XPlat Code Coverage"
EOF
    
    cat > scripts/build.ps1 << 'EOF'
Write-Host "Building .NET solution..." -ForegroundColor Blue
dotnet build --configuration Release --verbosity normal
EOF
    
    cat > scripts/quality.ps1 << 'EOF'
Write-Host "Running quality checks..." -ForegroundColor Blue

Write-Host "Building solution..." -ForegroundColor Yellow
dotnet build --configuration Release --no-restore

Write-Host "Running tests with coverage..." -ForegroundColor Yellow
dotnet test --no-build --configuration Release --collect:"XPlat Code Coverage"

Write-Host "Formatting check..." -ForegroundColor Yellow
dotnet format --verify-no-changes --verbosity diagnostic

Write-Host "Quality checks completed!" -ForegroundColor Green
EOF
    
    print_success "Utility scripts created"
}

# Function to create .NET-specific .gitignore
create_dotnet_gitignore() {
    print_status "Creating .NET .gitignore..."
    
    cat > .gitignore << 'EOF'
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
EOF
    
    print_success ".NET .gitignore created"
}

# Function to verify .NET setup
verify_dotnet_setup() {
    print_status "Verifying .NET setup..."
    
    if [ ! -f "global.json" ]; then
        print_error "global.json not found"
        return 1
    fi
    
    if [ ! -f "Directory.Build.props" ]; then
        print_error "Directory.Build.props not found"
        return 1
    fi
    
    # Try to build the solution
    if ! dotnet build --verbosity quiet >/dev/null 2>&1; then
        print_error "Solution build failed"
        return 1
    fi
    
    # Try to run tests
    if ! dotnet test --verbosity quiet >/dev/null 2>&1; then
        print_error "Tests failed"
        return 1
    fi
    
    print_success ".NET setup verified successfully"
    return 0
}

# Main orchestrator function for .NET environment setup
setup_dotnet_environment() {
    local project_name="$1"
    local project_description="$2"
    local project_type="${3:-classlib}"
    
    print_status "Setting up .NET environment for $project_name..."
    
    # Check prerequisites
    check_dotnet_prerequisites || return 1
    
    # Create .NET project structure
    create_dotnet_project "$project_name" "$project_type" || return 1
    
    # Create configuration files
    create_global_json || return 1
    create_directory_build_props "$project_name" "$project_description" || return 1
    create_editorconfig || return 1
    
    # Setup dependencies
    setup_dotnet_dependencies "$project_name" || return 1
    
    # Create utility scripts
    create_dotnet_utility_scripts || return 1
    
    # Create .gitignore
    create_dotnet_gitignore || return 1
    
    # Verify setup
    verify_dotnet_setup || return 1
    
    print_success ".NET environment setup completed for $project_name"
    return 0
}