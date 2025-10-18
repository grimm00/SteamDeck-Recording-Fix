#!/bin/bash

# Steam Deck Verbose Logging Setup
# Enables verbose logging for gamescope and Steam to capture recording events

set -e

echo "🔍 Steam Deck Verbose Logging Setup"
echo "==================================="
echo ""

# Function to enable gamescope verbose logging
enable_gamescope_logging() {
    echo "🎮 Setting up gamescope verbose logging..."
    
    # Check if gamescope is running
    if pgrep -f "gamescope" > /dev/null; then
        echo "   Gamescope is currently running"
        echo "   You may need to restart gamescope for changes to take effect"
    fi
    
    # Create gamescope config directory
    mkdir -p ~/.config/gamescope
    
    # Create gamescope config for verbose logging
    cat > ~/.config/gamescope/gamescope.conf << 'EOF'
# Gamescope verbose logging configuration
# Enable debug logging
--log-level=debug

# Enable overlay debugging
--debug-overlay

# Enable compositor debugging
--debug-compositor

# Enable Wayland debugging
--debug-wayland

# Enable HDR debugging
--debug-hdr

# Enable FSR debugging
--debug-fsr
EOF
    
    echo "   ✅ Gamescope config created: ~/.config/gamescope/gamescope.conf"
}

# Function to enable Steam verbose logging
enable_steam_logging() {
    echo "🎮 Setting up Steam verbose logging..."
    
    # Create Steam launch script with verbose logging
    cat > ~/.local/share/Steam/steam-verbose.sh << 'EOF'
#!/bin/bash
# Steam with verbose logging for recording debugging

export STEAM_DEBUG=1
export STEAM_VERBOSE=1
export STEAM_LOG_LEVEL=debug

# Enable Steam overlay debugging
export STEAM_OVERLAY_DEBUG=1

# Enable Steam recording debugging
export STEAM_RECORDING_DEBUG=1

# Enable Steam compositor debugging
export STEAM_COMPOSITOR_DEBUG=1

# Run Steam with debug flags
exec /home/deck/.local/share/Steam/ubuntu12_32/steam "$@"
EOF
    
    chmod +x ~/.local/share/Steam/steam-verbose.sh
    echo "   ✅ Steam verbose script created: ~/.local/share/Steam/steam-verbose.sh"
}

# Function to enable system logging
enable_system_logging() {
    echo "🖥️  Setting up system logging..."
    
    # Create systemd override for gamescope session
    sudo mkdir -p /etc/systemd/user/gamescope-session.service.d/
    
    cat > /tmp/gamescope-override.conf << 'EOF'
[Service]
Environment=GAMESCOPE_DEBUG=1
Environment=GAMESCOPE_VERBOSE=1
Environment=WAYLAND_DEBUG=1
Environment=MANGOHUD_DEBUG=1
EOF
    
    sudo mv /tmp/gamescope-override.conf /etc/systemd/user/gamescope-session.service.d/override.conf
    sudo systemctl daemon-reload
    
    echo "   ✅ Systemd override created for gamescope-session"
}

# Function to create log monitoring script
create_log_monitor() {
    echo "📊 Creating log monitoring script..."
    
    cat > ~/.local/bin/monitor-recording-debug.sh << 'EOF'
#!/bin/bash
# Real-time recording debug monitor

echo "🔍 Recording Debug Monitor"
echo "========================="
echo ""

# Monitor gamescope logs
echo "🎮 Gamescope logs:"
journalctl --user -u gamescope-session -f --since "now" | grep -i "record\|overlay\|notification\|compositor" &

# Monitor Steam logs
echo "🎮 Steam logs:"
tail -f /home/deck/.local/share/Steam/logs/gameprocess_log.txt | grep -i "record\|overlay\|notification" &

# Monitor system logs
echo "🖥️  System logs:"
journalctl -f --since "now" | grep -i "record\|overlay\|notification\|mango" &

wait
EOF
    
    chmod +x ~/.local/bin/monitor-recording-debug.sh
    mkdir -p ~/.local/bin
    
    echo "   ✅ Log monitor created: ~/.local/bin/monitor-recording-debug.sh"
}

# Function to show usage instructions
show_instructions() {
    echo ""
    echo "📋 Usage Instructions:"
    echo "====================="
    echo ""
    echo "1. **Restart Steam Deck** to apply systemd changes"
    echo ""
    echo "2. **Test in Gaming Mode**:"
    echo "   - Switch to Gaming Mode"
    echo "   - Start a game"
    echo "   - Run: ~/.local/bin/monitor-recording-debug.sh"
    echo "   - Start recording (Steam + R1)"
    echo "   - Watch for debug messages around the 6-second mark"
    echo ""
    echo "3. **Test in Big Picture Mode**:"
    echo "   - Switch to Desktop Mode"
    echo "   - Run: ~/.local/share/Steam/steam-verbose.sh"
    echo "   - Start Big Picture Mode"
    echo "   - Start a game and test recording"
    echo ""
    echo "4. **Compare the logs** between the two modes"
    echo ""
    echo "🔍 Key things to look for:"
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
    
    # Check gamescope config
    if [[ -f ~/.config/gamescope/gamescope.conf ]]; then
        echo "✅ Gamescope verbose config: ~/.config/gamescope/gamescope.conf"
    else
        echo "❌ Gamescope verbose config: Not found"
    fi
    
    # Check Steam verbose script
    if [[ -f ~/.local/share/Steam/steam-verbose.sh ]]; then
        echo "✅ Steam verbose script: ~/.local/share/Steam/steam-verbose.sh"
    else
        echo "❌ Steam verbose script: Not found"
    fi
    
    # Check systemd override
    if [[ -f /etc/systemd/user/gamescope-session.service.d/override.conf ]]; then
        echo "✅ Systemd override: /etc/systemd/user/gamescope-session.service.d/override.conf"
    else
        echo "❌ Systemd override: Not found"
    fi
    
    # Check log monitor
    if [[ -f ~/.local/bin/monitor-recording-debug.sh ]]; then
        echo "✅ Log monitor: ~/.local/bin/monitor-recording-debug.sh"
    else
        echo "❌ Log monitor: Not found"
    fi
    
    echo ""
}

# Main execution
main() {
    echo "This script will enable verbose logging for recording debugging."
    echo ""
    
    # Check if running as root for systemd changes
    if [[ $EUID -eq 0 ]]; then
        echo "⚠️  Running as root. This is needed for systemd changes."
    else
        echo "ℹ️  You may be prompted for sudo password for systemd changes."
    fi
    
    echo ""
    read -p "Press Enter to continue..."
    
    enable_gamescope_logging
    enable_steam_logging
    enable_system_logging
    create_log_monitor
    
    check_logging_status
    show_instructions
    
    echo "✅ Verbose logging setup complete!"
    echo ""
    echo "🔄 **Important**: Restart your Steam Deck to apply all changes."
}

# Run main function
main "$@"
