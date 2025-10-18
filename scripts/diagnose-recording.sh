#!/bin/bash

# Steam Deck Recording Diagnostic Script
# This script helps diagnose recording issues and recommends solutions

set -e

echo "🔍 Steam Deck Recording Diagnostic Tool"
echo "======================================="
echo ""

# Check if running on Steam Deck
if [[ ! -f /etc/steamos-release ]]; then
    echo "⚠️  Warning: This script is designed for Steam Deck"
    echo "   Some checks may not be accurate on other systems"
    echo ""
fi

# System Information
echo "📋 System Information:"
echo "======================"
if [[ -f /etc/steamos-release ]]; then
    echo "SteamOS Version: $(cat /etc/steamos-release)"
else
    echo "SteamOS Version: Not detected"
fi

if [[ -f /etc/os-release ]]; then
    echo "OS Release: $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
fi

echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo ""

# Check MangoHud
echo "🔍 MangoHud Status:"
echo "==================="
if command -v mangohud &> /dev/null; then
    echo "✅ MangoHud is installed"
    echo "   Version: $(mangohud --version 2>/dev/null || echo "Unknown")"
else
    echo "❌ MangoHud not found in PATH"
fi

if [[ -f ~/.config/MangoHud/MangoHud.conf ]]; then
    echo "✅ MangoHud configuration exists"
    if grep -q "control=mangohud" ~/.config/MangoHud/MangoHud.conf; then
        echo "✅ Configuration appears valid"
    else
        echo "⚠️  Configuration may be invalid"
    fi
else
    echo "❌ MangoHud configuration not found"
fi

if [[ -n "$MANGOHUD" ]]; then
    echo "✅ MANGOHUD environment variable is set: $MANGOHUD"
else
    echo "❌ MANGOHUD environment variable not set"
fi
echo ""

# Check Decky Loader
echo "🔍 Decky Loader Status:"
echo "======================="
if [[ -d /home/deck/homebrew ]]; then
    echo "✅ Decky Loader is installed"
    if [[ -d /home/deck/homebrew/plugins/MangoPeel ]]; then
        echo "✅ MangoPeel plugin is installed"
        echo "⚠️  Note: MangoPeel has known reliability issues with preset system"
        if [[ -f /home/deck/homebrew/plugins/MangoPeel/main.py ]]; then
            echo "✅ MangoPeel main.py exists"
        else
            echo "❌ MangoPeel main.py not found"
        fi
    else
        echo "❌ MangoPeel plugin not installed"
    fi
else
    echo "❌ Decky Loader not installed"
fi
echo ""

# Check Steam
echo "🔍 Steam Status:"
echo "================"
if pgrep -f "steam" > /dev/null; then
    echo "✅ Steam is running"
else
    echo "❌ Steam is not running"
fi

if [[ -d /home/deck/.steam ]]; then
    echo "✅ Steam directory exists"
else
    echo "❌ Steam directory not found"
fi
echo ""

# Check Gamescope
echo "🔍 Gamescope Status:"
echo "===================="
if command -v gamescope &> /dev/null; then
    echo "✅ Gamescope is installed"
    echo "   Version: $(gamescope --version 2>/dev/null || echo "Unknown")"
else
    echo "❌ Gamescope not found in PATH"
fi

if pgrep -f "gamescope" > /dev/null; then
    echo "✅ Gamescope is running"
else
    echo "❌ Gamescope is not running"
fi
echo ""

# Check Recording Capabilities
echo "🔍 Recording Capabilities:"
echo "=========================="
if command -v ffmpeg &> /dev/null; then
    echo "✅ FFmpeg is available"
else
    echo "❌ FFmpeg not found"
fi

if [[ -d /dev/dri ]]; then
    echo "✅ DRI devices available"
    ls -la /dev/dri/ 2>/dev/null || echo "   Could not list DRI devices"
else
    echo "❌ DRI devices not found"
fi
echo ""

# Recommendations
echo "💡 Recommendations:"
echo "==================="

# Check if user has the recording issue
echo "Do you experience recording choppiness after 6 seconds? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "✅ Confirmed: You have the recording choppiness issue"
    echo ""
    
    # Recommend solutions based on what's available
    if command -v mangohud &> /dev/null; then
        echo "🎯 **Recommended Solution: Direct MangoHud Configuration**"
        echo "   - Most reliable solution"
        echo "   - No plugin required"
        echo "   - Run: ./solutions/mangohud-direct/setup.sh"
        echo "   - See: solutions/mangohud-direct/README.md"
        echo ""
    elif [[ -d /home/deck/homebrew/plugins/MangoPeel ]]; then
        echo "🎯 **Alternative Solution: MangoPeel Transparent Overlay**"
        echo "   - ⚠️  Note: Has known reliability issues"
        echo "   - Just change preset to 'Preset 0 (Recording Fix)'"
        echo "   - See: solutions/mangopeel-transparent/README.md"
        echo "   - If it doesn't work, try Direct MangoHud Configuration"
        echo ""
    else
        echo "🎯 **Recommended Solution: Install MangoHud**"
        echo "   - MangoHud is required for the fix"
        echo "   - Install via package manager or build from source"
        echo "   - See: https://github.com/flightlessmango/MangoHud"
        echo ""
    fi
    
    echo "🔧 **Alternative Solutions:**"
    echo "   - Systemd Service: solutions/systemd-service/README.md"
    echo "   - Manual Workarounds: docs/manual-workarounds.md"
    echo ""
else
    echo "✅ Great! You don't have the recording choppiness issue"
    echo "   This script is designed to help users with the 6-second choppiness problem"
    echo "   If you experience other recording issues, please report them"
    echo ""
fi

# Test recording capability
echo "🧪 **Recording Test:**"
echo "   To test if the fix works:"
echo "   1. Start any game"
echo "   2. Press Steam + R1 to record"
echo "   3. Record for 15+ seconds"
echo "   4. Check if recording is smooth throughout"
echo ""

# Additional help
echo "📚 **Additional Resources:**"
echo "   - Project README: README.md"
echo "   - Technical Investigation: INVESTIGATION.md"
echo "   - All Solutions: SOLUTIONS.md"
echo "   - GitHub Issues: https://github.com/grimm00/SteamDeck-Recording-Fix/issues"
echo "   - GitHub Discussions: https://github.com/grimm00/SteamDeck-Recording-Fix/discussions"
echo ""

echo "✅ Diagnostic complete!"
echo "   If you need help, please share this output when reporting issues"
