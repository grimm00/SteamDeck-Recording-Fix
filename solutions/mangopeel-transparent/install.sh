#!/bin/bash

# MangoPeel Transparent Overlay Installation Script
# This script helps configure MangoPeel for recording fix

set -e

echo "🎮 MangoPeel Recording Fix Installation"
echo "========================================"

# Check if running on Steam Deck
if [[ ! -f /etc/steamos-release ]]; then
    echo "⚠️  Warning: This script is designed for Steam Deck"
    echo "   Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Installation cancelled"
        exit 1
    fi
fi

# Check if Decky Loader is installed
if [[ ! -d /home/deck/homebrew ]]; then
    echo "❌ Decky Loader not found!"
    echo "   Please install Decky Loader first:"
    echo "   https://decky.xyz/"
    exit 1
fi

# Check if MangoPeel is installed
if [[ ! -d /home/deck/homebrew/plugins/MangoPeel ]]; then
    echo "❌ MangoPeel plugin not found!"
    echo "   Please install MangoPeel from Decky Store first"
    exit 1
fi

echo "✅ Decky Loader found"
echo "✅ MangoPeel plugin found"

# Create backup of current configuration
echo "📋 Creating backup of current configuration..."
if [[ -f /home/deck/homebrew/plugins/MangoPeel/main.py ]]; then
    cp /home/deck/homebrew/plugins/MangoPeel/main.py /home/deck/homebrew/plugins/MangoPeel/main.py.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backup created"
else
    echo "⚠️  Could not find main.py to backup"
fi

# Check if SteamOS compatibility fixes are needed
echo "🔍 Checking for SteamOS compatibility issues..."
if grep -q "RegisterForControllerStateChanges" /home/deck/homebrew/plugins/MangoPeel/dist/index.js 2>/dev/null; then
    echo "⚠️  SteamOS compatibility fixes may be needed"
    echo "   Consider applying fixes from:"
    echo "   https://github.com/grimm00/MangoPeel_Steam_OS_Fixes"
fi

echo ""
echo "🎯 Configuration Instructions:"
echo "=============================="
echo ""
echo "1. Open Steam Deck Quick Access menu (Steam button)"
echo "2. Find MangoPeel plugin"
echo "3. Set preset to 'Preset 0 (Recording Fix)' or 'No Display'"
echo "4. The overlay will be completely transparent"
echo ""
echo "5. Test recording:"
echo "   - Start any game"
echo "   - Press Steam + R1 to record"
echo "   - Record for 15+ seconds"
echo "   - Verify smooth recording throughout"
echo ""

# Test if MangoPeel is running
echo "🔍 Checking MangoPeel status..."
if pgrep -f "MangoPeel" > /dev/null; then
    echo "✅ MangoPeel is running"
else
    echo "⚠️  MangoPeel may not be running"
    echo "   Try restarting Steam or Decky Loader"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "📚 For more information:"
echo "   - README: $(pwd)/README.md"
echo "   - Issues: https://github.com/grimm00/SteamDeck-Recording-Fix/issues"
echo "   - Discussions: https://github.com/grimm00/SteamDeck-Recording-Fix/discussions"
echo ""
echo "🎮 Happy recording!"
