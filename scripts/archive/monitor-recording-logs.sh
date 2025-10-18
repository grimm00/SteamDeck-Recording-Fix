#!/bin/bash

# Steam Deck Recording Log Monitor
# This script monitors various log sources to capture recording events

set -e

echo "🔍 Steam Deck Recording Log Monitor"
echo "==================================="
echo ""
echo "This script will monitor logs for recording events."
echo "Start recording in a game (Steam + R1) to capture events."
echo "Press Ctrl+C to stop monitoring."
echo ""

# Create log directory
LOG_DIR="/tmp/recording-logs-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOG_DIR"

echo "📁 Log directory: $LOG_DIR"
echo ""

# Function to monitor gamescope logs
monitor_gamescope() {
    echo "🎮 Monitoring gamescope logs..."
    journalctl --user -u gamescope-session -f --since "now" > "$LOG_DIR/gamescope.log" 2>&1 &
    GAMESCOPE_PID=$!
    echo "   Gamescope PID: $GAMESCOPE_PID"
}

# Function to monitor Steam logs
monitor_steam() {
    echo "🎮 Monitoring Steam logs..."
    tail -f /home/deck/.local/share/Steam/logs/gameprocess_log.txt > "$LOG_DIR/steam-gameprocess.log" 2>&1 &
    STEAM_PID=$!
    echo "   Steam PID: $STEAM_PID"
    
    # Also monitor console log
    tail -f /home/deck/.local/share/Steam/logs/console-linux.txt > "$LOG_DIR/steam-console.log" 2>&1 &
    STEAM_CONSOLE_PID=$!
    echo "   Steam Console PID: $STEAM_CONSOLE_PID"
}

# Function to monitor system logs for recording events
monitor_system() {
    echo "🖥️  Monitoring system logs..."
    journalctl -f --since "now" | grep -i "record\|overlay\|notification\|mango" > "$LOG_DIR/system.log" 2>&1 &
    SYSTEM_PID=$!
    echo "   System PID: $SYSTEM_PID"
}

# Function to monitor MangoHud processes
monitor_mangohud() {
    echo "🥭 Monitoring MangoHud processes..."
    while true; do
        ps aux | grep -i mango | grep -v grep >> "$LOG_DIR/mangohud-processes.log" 2>&1
        sleep 1
    done &
    MANGOHUD_PID=$!
    echo "   MangoHud PID: $MANGOHUD_PID"
}

# Function to monitor gamescope stats
monitor_gamescope_stats() {
    echo "📊 Monitoring gamescope stats..."
    if [[ -f /run/user/1000/gamescope-stats ]]; then
        while true; do
            cat /run/user/1000/gamescope-stats >> "$LOG_DIR/gamescope-stats.log" 2>&1
            sleep 0.5
        done &
        GAMESCOPE_STATS_PID=$!
        echo "   Gamescope Stats PID: $GAMESCOPE_STATS_PID"
    else
        echo "   Gamescope stats file not found"
        GAMESCOPE_STATS_PID=""
    fi
}

# Function to monitor MangoHud config files
monitor_mangohud_configs() {
    echo "📝 Monitoring MangoHud config files..."
    while true; do
        find /run/user/1000 -name "*mango*" -type f -exec ls -la {} \; >> "$LOG_DIR/mangohud-configs.log" 2>&1
        sleep 2
    done &
    MANGOHUD_CONFIG_PID=$!
    echo "   MangoHud Config PID: $MANGOHUD_CONFIG_PID"
}

# Function to capture recording events with timestamps
capture_events() {
    echo "⏰ Capturing timestamped events..."
    while true; do
        echo "$(date): Recording event check" >> "$LOG_DIR/events.log"
        sleep 1
    done &
    EVENTS_PID=$!
    echo "   Events PID: $EVENTS_PID"
}

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Stopping monitoring..."
    
    # Kill all background processes
    for pid in $GAMESCOPE_PID $STEAM_PID $STEAM_CONSOLE_PID $SYSTEM_PID $MANGOHUD_PID $GAMESCOPE_STATS_PID $MANGOHUD_CONFIG_PID $EVENTS_PID; do
        if [[ -n "$pid" ]]; then
            kill "$pid" 2>/dev/null || true
        fi
    done
    
    echo "✅ Monitoring stopped"
    echo ""
    echo "📁 Logs saved to: $LOG_DIR"
    echo ""
    echo "📋 Log files created:"
    ls -la "$LOG_DIR"
    echo ""
    echo "🔍 To analyze the logs:"
    echo "   cd $LOG_DIR"
    echo "   grep -i 'record\\|overlay\\|notification' *.log"
    echo ""
}

# Set up signal handlers
trap cleanup EXIT INT TERM

# Start monitoring
monitor_gamescope
monitor_steam
monitor_system
monitor_mangohud
monitor_gamescope_stats
monitor_mangohud_configs
capture_events

echo ""
echo "🎯 Monitoring started! Now:"
echo "   1. Start a game"
echo "   2. Press Steam + R1 to start recording"
echo "   3. Wait for the 6-second mark"
echo "   4. Press Steam + R1 to stop recording"
echo "   5. Press Ctrl+C to stop monitoring"
echo ""

# Wait for user to stop
wait
