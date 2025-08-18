#!/bin/bash
# Development setup script for OurBigKitchen
# Installs required development tools and dependencies

set -e

echo "Setting up OurBigKitchen development environment..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew already installed"
fi

# Install SwiftLint
echo "Installing SwiftLint..."
brew install swiftlint

# Install SwiftFormat (optional but recommended)
echo "Installing SwiftFormat..."
brew install swiftformat

# Install Xcode command line tools if not present
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode command line tools..."
    xcode-select --install
else
    echo "Xcode command line tools already installed"
fi

# Create .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
    echo "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
!*.xcworkspace/contents.xcworkspacedata
*.xcuserstate
*.xcuserdata/

# Build
build/
DerivedData/
*.ipa
*.dSYM.zip
*.dSYM

# Swift Package Manager
.build/
Packages/
Package.pins
Package.resolved
*.xcodeproj

# CocoaPods
Pods/
*.xcworkspace

# Carthage
Carthage/Build/

# fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Code Injection
iOSInjectionProject/

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
*.log
logs/

# Environment variables
.env
.env.local
.env.*.local

# Temporary files
*.tmp
*.temp
EOF
fi

echo "Development environment setup complete!"
echo ""
echo "Next steps:"
echo "1. Open OurBigKitchen.xcworkspace in Xcode"
echo "2. Build the project to ensure everything works"
echo "3. Run 'swiftlint lint' to check code quality"
echo "4. The pre-commit hook will automatically run on commits"
