#!/bin/bash

# Steam Deck Verbose Logging Setup
# Enables system-level verbose logging that persists across Gaming Mode switches

set -e

echo "🔍 Steam Deck Verbose Logging Setup"
echo "==================================="
echo ""

# Function to enable system-level verbose logging
enable_system_logging() {
    echo "🖥️  Setting up system-level verbose logging..."
    echo "   This configuration will persist across Gaming Mode switches"
    
    # Create systemd override for gamescope session
    sudo mkdir -p /etc/systemd/user/gamescope-session.service.d/
    
    cat > /tmp/gamescope-override.conf << 'EOF'
[Service]
Environment=GAMESCOPE_DEBUG=1
Environment=GAMESCOPE_VERBOSE=1
Environment=WAYLAND_DEBUG=1
Environment=MANGOHUD_DEBUG=1
Environment=STEAM_DEBUG=1
Environment=STEAM_VERBOSE=1
EOF
    
    sudo mv /tmp/gamescope-override.conf /etc/systemd/user/gamescope-session.service.d/override.conf
    sudo systemctl daemon-reload
    
    echo "   ✅ Systemd override created for gamescope-session"
    echo "   ✅ Verbose logging will be active in both Desktop and Gaming Mode"
}

# Function to show usage instructions
show_instructions() {
    echo ""
    echo "📋 Usage Instructions:"
    echo "====================="
    echo ""
    echo "1. **Restart Steam Deck** to apply systemd changes"
    echo ""
    echo "2. **Use with analyze-recording-logs.sh**:"
    echo "   - This enables verbose logging that persists across mode switches"
    echo "   - After restart, run compare-recording-modes.sh for guided testing"
    echo "   - Use analyze-recording-logs.sh to extract and compare logs"
    echo ""
    echo "🔍 Key things the logs will capture:"
    echo "   - Overlay state changes in gamescope logs"
    echo "   - Recording notification events in Steam logs"
    echo "   - Compositor reconfiguration messages"
    echo "   - MangoHud process changes"
    echo ""
}

# Function to check current logging status
check_logging_status() {
    echo "📊 Current Logging Status:"
    echo "========================="
    echo ""
    
    # Check systemd override
    if [[ -f /etc/systemd/user/gamescope-session.service.d/override.conf ]]; then
        echo "✅ Systemd override: /etc/systemd/user/gamescope-session.service.d/override.conf"
    else
        echo "❌ Systemd override: Not found"
    fi
    
    echo ""
}

# Main execution
main() {
    echo "This script enables system-level verbose logging that persists across Gaming Mode switches."
    echo ""
    
    # Check if running as root for systemd changes
    if [[ $EUID -eq 0 ]]; then
        echo "⚠️  Running as root. This is needed for systemd changes."
    else
        echo "ℹ️  You may be prompted for sudo password for systemd changes."
    fi
    
    echo ""
    read -p "Press Enter to continue..."
    
    enable_system_logging
    
    check_logging_status
    show_instructions
    
    echo "✅ Verbose logging setup complete!"
    echo ""
    echo "🔄 **Important**: Restart your Steam Deck to apply all changes."
}

# Run main function
main "$@"
