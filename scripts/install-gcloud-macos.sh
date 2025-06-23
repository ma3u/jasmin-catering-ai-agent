#!/bin/bash

# Quick Google Cloud CLI installer for macOS
# Optimized for MacBook setup

set -e

echo "📦 Installing Google Cloud CLI on macOS..."
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew first..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
    else
        export PATH="/usr/local/bin:$PATH"
    fi
fi

echo "📥 Installing Google Cloud CLI via Homebrew..."
brew install --cask google-cloud-sdk

# Add gcloud to PATH
echo "🔧 Adding gcloud to PATH..."

# Detect Homebrew installation path
if [[ -d "/opt/homebrew" ]]; then
    # Apple Silicon Mac
    GCLOUD_PATH="/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
else
    # Intel Mac
    GCLOUD_PATH="/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
fi

# Add to current session
export PATH="$GCLOUD_PATH/bin:$PATH"

# Add to shell profile
SHELL_PROFILE=""
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_PROFILE="$HOME/.bashrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
    SHELL_PROFILE="$HOME/.bash_profile"
fi

if [[ -n "$SHELL_PROFILE" ]]; then
    echo "📝 Adding gcloud to $SHELL_PROFILE..."
    echo "" >> $SHELL_PROFILE
    echo "# Google Cloud CLI" >> $SHELL_PROFILE
    echo "export PATH=\"$GCLOUD_PATH/bin:\$PATH\"" >> $SHELL_PROFILE
    
    # Source the updated profile
    source $SHELL_PROFILE
fi

# Initialize gcloud components
echo "🔧 Initializing gcloud components..."
gcloud components install alpha beta

echo ""
echo "✅ Google Cloud CLI installation complete!"
echo ""
echo "📋 Verification:"
gcloud version
echo ""
echo "🚀 Next step: Run the complete setup"
echo "   ./scripts/complete-setup.sh"
