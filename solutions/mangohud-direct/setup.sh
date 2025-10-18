#!/bin/bash

# Direct MangoHud Configuration Setup Script
# This script configures MangoHud for recording fix

set -e

echo "🎮 MangoHud Recording Fix Setup"
echo "==============================="

# Check if running on Steam Deck
if [[ ! -f /etc/steamos-release ]]; then
    echo "⚠️  Warning: This script is designed for Steam Deck"
    echo "   Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled"
        exit 1
    fi
fi

# Check if MangoHud is available
if ! command -v mangohud &> /dev/null; then
    echo "⚠️  MangoHud not found in PATH"
    echo "   MangoHud is usually pre-installed on Steam Deck"
    echo "   Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled"
        exit 1
    fi
fi

echo "✅ MangoHud found"

# Create MangoHud configuration directory
echo "📁 Creating MangoHud configuration directory..."
mkdir -p ~/.config/MangoHud

# Backup existing configuration if it exists
if [[ -f ~/.config/MangoHud/MangoHud.conf ]]; then
    echo "📋 Backing up existing configuration..."
    cp ~/.config/MangoHud/MangoHud.conf ~/.config/MangoHud/MangoHud.conf.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backup created"
fi

# Copy configuration file
echo "📝 Installing recording fix configuration..."
cp "$(dirname "$0")/mangohud.conf" ~/.config/MangoHud/MangoHud.conf
echo "✅ Configuration installed"

# Check if MANGOHUD environment variable is set
echo "🔍 Checking MANGOHUD environment variable..."
if [[ -z "$MANGOHUD" ]]; then
    echo "⚠️  MANGOHUD environment variable not set"
    echo ""
    echo "📋 To enable MangoHud, you need to set MANGOHUD=1"
    echo ""
    echo "Options:"
    echo "1. Add to Steam game launch options: MANGOHUD=1"
    echo "2. Add to ~/.bashrc: export MANGOHUD=1"
    echo "3. Set globally in Steam settings"
    echo ""
    echo "Would you like to add MANGOHUD=1 to ~/.bashrc? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "export MANGOHUD=1" >> ~/.bashrc
        echo "✅ Added to ~/.bashrc"
        echo "   You may need to restart your terminal or reboot"
    fi
else
    echo "✅ MANGOHUD environment variable is set: $MANGOHUD"
fi

echo ""
echo "🎯 Next Steps:"
echo "=============="
echo ""
echo "1. **Enable MangoHud in Steam**:"
echo "   - Open Steam Settings"
echo "   - Go to In-Game section"
echo "   - Add to Launch Options: MANGOHUD=1"
echo ""
echo "2. **Test Recording**:"
echo "   - Start any game"
echo "   - Press Steam + R1 to record"
echo "   - Record for 15+ seconds"
echo "   - Verify smooth recording throughout"
echo ""

# Test if configuration is valid
echo "🔍 Testing configuration..."
if [[ -f ~/.config/MangoHud/MangoHud.conf ]]; then
    echo "✅ Configuration file exists"
    if grep -q "control=mangohud" ~/.config/MangoHud/MangoHud.conf; then
        echo "✅ Configuration appears valid"
    else
        echo "⚠️  Configuration may be invalid"
    fi
else
    echo "❌ Configuration file not found"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📚 For more information:"
echo "   - README: $(pwd)/README.md"
echo "   - Issues: https://github.com/grimm00/SteamDeck-Recording-Fix/issues"
echo "   - Discussions: https://github.com/grimm00/SteamDeck-Recording-Fix/discussions"
echo ""
echo "🎮 Happy recording!"
