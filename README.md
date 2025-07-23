# Bootstrap Claude Code

**The missing link between Claude and your development projects.**

## The Problem

Every time you start a new project, you face the same time-consuming setup:
- Configuring build tools, testing frameworks, and quality gates
- Setting up project structure and development workflows  
- Integrating with Claude for AI-powered development
- Ensuring consistency across different projects and team members

Hours later, you're finally ready to write actual code.

## The Solution

Bootstrap Claude Code eliminates project setup friction by providing **ready-to-use project templates** that integrate seamlessly with Claude's development workflow.

**In 30 seconds, get:**
- ✅ Complete project structure with testing and quality tools
- ✅ Claude TDD + Scrumban workflow for efficient AI-powered development
- ✅ Cross-platform development scripts and automation
- ✅ Consistent setup across Python and .NET projects

## Who This Is For

**Individual developers** who want to:
- Start projects faster with consistent, quality setups
- Leverage Claude more effectively in their development workflow
- Avoid the tedium of manual project configuration

**Small development teams** who need:
- Standardized project structures across team members
- Shared development practices and tooling
- Consistent Claude integration patterns

## Quick Start

### Python Projects

```bash
# Linux/macOS/WSL
./bootstrap-claude-python.sh my-python-app -d "My awesome Python application"

# Windows PowerShell  
.\bootstrap-claude-python.ps1 MyPythonApp -Description "My awesome Python application"
```

### .NET 8 Projects

```bash
# Linux/macOS/WSL
./bootstrap-claude-dotnet.sh my-dotnet-api -d "REST API service" -t webapi

# Windows PowerShell
.\bootstrap-claude-dotnet.ps1 MyDotNetApi -Description "REST API service" -ProjectType webapi
```

**That's it!** Your project is ready with testing, quality tools, and Claude integration.

## What You Get

### Complete Project Setup
- **Testing frameworks**: pytest (Python) or xUnit (.NET) with coverage reporting
- **Code quality**: Formatters, linters, type checkers, and pre-commit hooks
- **Build automation**: Cross-platform scripts for build, test, and quality checks
- **Documentation**: README templates and development guides

### Claude TDD + Scrumban Integration
- **Structured workflow files** in `.claude/` directory for AI-powered development
- **Session management** with sign-in/sign-out protocols
- **Scrumban board** for tracking development tasks
- **Domain contexts** for better AI understanding of your project

### Cross-Platform Support
- **Bash scripts** for Linux, macOS, and WSL environments
- **PowerShell scripts** for native Windows development
- **Identical functionality** across both platforms

## Supported Project Types

### Python
- **Virtual environments** with dependency management
- **Package structure** following Python best practices
- **pytest** with coverage, mocking, and async support
- **Quality tools**: Black, flake8, mypy, isort

### .NET 8
- **Solution structure** with class libraries, console apps, or web APIs
- **xUnit testing** with FluentAssertions and Moq
- **Code analysis** with EditorConfig and analyzers
- **NuGet packages** and dependency management

## Example: From Zero to Coding in 30 Seconds

```bash
# 1. Create project (10 seconds)
./bootstrap-claude-python.sh my-ml-project -d "Machine learning experiment"

# 2. Navigate and activate (5 seconds)
cd my-ml-project
source .venv/bin/activate

# 3. Start developing with Claude (15 seconds)
# - Open .claude/CLAUDE.md for development workflow
# - Run ./scripts/test.sh to verify setup
# - Begin TDD cycle with Claude assistance
```

**Result**: Fully configured project with testing, quality tools, Git repository, and Claude workflow integration.

## Advanced Usage

### Custom Module Combinations

For specific workflows, you can use individual modules:

```bash
# Python project without Claude workflow
./examples/custom-bootstrap.sh simple my-lib "Simple Python library"

# Add Claude workflow to existing project
./examples/custom-bootstrap.sh add-claude existing-project

# .NET Web API with full Claude integration
./examples/custom-bootstrap-dotnet.sh webapi my-api "REST API service"
```

### Project Types

**Python Options:**
- Any Python version (default: 3.12)
- Custom project descriptions
- Virtual environment isolation

**\\.NET Options:**
- `classlib` - Class library (default)
- `console` - Console application  
- `webapi` - ASP.NET Core Web API
- `mvc` - ASP.NET Core MVC
- `api` - Minimal API

## Requirements

### All Platforms
- Git (for repository management)

### Python Projects
- Python 3.11+ (3.12 recommended)

### .NET Projects  
- .NET 8 SDK

### Platform Requirements
- **Windows**: PowerShell 5.1+ (PowerShell 7+ recommended)
- **Linux/macOS/WSL**: Bash shell
- **Cross-platform**: Both implementations provide identical functionality

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/LaptopHeaven/bootstrap-claude-code.git
   cd bootstrap-claude-code
   ```

2. **Make scripts executable (Linux/macOS/WSL):**
   ```bash
   chmod +x bootstrap-claude-python.sh bootstrap-claude-dotnet.sh
   ```

3. **Start bootstrapping projects!**

## Why Bootstrap Claude Code?

### Time Savings
- **No more setup friction**: Projects ready in seconds, not hours
- **Consistent environments**: Same quality standards across all projects  
- **Reduced context switching**: Focus on code, not configuration

### Quality Assurance
- **Battle-tested setups**: Proven project structures and tool configurations
- **Quality gates**: Automated testing, formatting, and analysis
- **Best practices**: Following language-specific conventions and patterns

### Claude Integration
- **Structured AI workflow**: Maximize Claude's effectiveness with organized development patterns
- **Session continuity**: Maintain context across development sessions
- **Collaborative development**: AI-assisted TDD and planning workflows

## Contributing

We welcome contributions! This project focuses on **Python and .NET support** with proven, maintainable implementations.

### Development Principles
- **Quality over quantity**: Better to support 2 languages excellently than 10 poorly
- **User-first design**: Optimize for developer experience and workflow efficiency  
- **Cross-platform consistency**: Identical functionality across Bash and PowerShell

### Getting Started
1. Test both bootstrap scripts to ensure they work correctly
2. Follow established patterns for error handling and output
3. Update documentation with any new functionality
4. Ensure cross-platform compatibility

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Ready to eliminate setup friction and supercharge your development with Claude?**

Choose your language and start bootstrapping! 🚀