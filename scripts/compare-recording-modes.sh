#!/bin/bash

# Steam Deck Recording Mode Comparison Script
# Compares recording behavior between Big Picture Mode and Gaming Mode

set -e

echo "🎮 Steam Deck Recording Mode Comparison"
echo "======================================="
echo ""
echo "This script helps compare recording behavior between:"
echo "  - Big Picture Mode (Desktop Mode)"
echo "  - Gaming Mode (Gamescope)"
echo ""

# Function to capture current system state
capture_state() {
    local mode="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local log_dir="/tmp/recording-comparison-$timestamp"
    
    echo "📊 Capturing $mode state..."
    mkdir -p "$log_dir"
    
    # Capture process information
    echo "=== PROCESSES ===" > "$log_dir/${mode}_processes.log"
    ps aux | grep -E "(steam|gamescope|mango)" | grep -v grep >> "$log_dir/${mode}_processes.log"
    
    # Capture gamescope information
    if [[ "$mode" == "gaming" ]]; then
        echo "=== GAMESCOPE INFO ===" > "$log_dir/${mode}_gamescope.log"
        journalctl --user -u gamescope-session --since "5 minutes ago" >> "$log_dir/${mode}_gamescope.log" 2>&1 || true
    fi
    
    # Capture Steam logs
    echo "=== STEAM LOGS ===" > "$log_dir/${mode}_steam.log"
    tail -50 /home/deck/.local/share/Steam/logs/gameprocess_log.txt >> "$log_dir/${mode}_steam.log" 2>&1 || true
    
    # Capture MangoHud configs
    echo "=== MANGOHUD CONFIGS ===" > "$log_dir/${mode}_mangohud.log"
    find /run/user/1000 -name "*mango*" -type f -exec ls -la {} \; >> "$log_dir/${mode}_mangohud.log" 2>&1 || true
    
    # Capture system resources
    echo "=== SYSTEM RESOURCES ===" > "$log_dir/${mode}_resources.log"
    echo "CPU:" >> "$log_dir/${mode}_resources.log"
    top -bn1 | head -20 >> "$log_dir/${mode}_resources.log"
    echo "Memory:" >> "$log_dir/${mode}_resources.log"
    free -h >> "$log_dir/${mode}_resources.log"
    
    echo "✅ $mode state captured in: $log_dir"
    echo "$log_dir"
}

# Function to provide instructions
show_instructions() {
    local mode="$1"
    echo ""
    echo "🎯 Instructions for $mode mode:"
    echo "================================"
    
    if [[ "$mode" == "bigpicture" ]]; then
        echo "1. Switch to Desktop Mode:"
        echo "   - Press Steam button → Power → Switch to Desktop"
        echo "2. Open Steam in Big Picture Mode:"
        echo "   - Launch Steam from desktop"
        echo "   - Click 'Big Picture Mode' button"
        echo "3. Start a game"
        echo "4. Test recording:"
        echo "   - Press Steam + R1 to start recording"
        echo "   - Record for 15+ seconds"
        echo "   - Note if recording stays smooth after 6 seconds"
        echo "5. Press Enter when done testing"
    else
        echo "1. Switch to Gaming Mode:"
        echo "   - Press Steam button → Power → Switch to Gaming Mode"
        echo "2. Start the same game"
        echo "3. Test recording:"
        echo "   - Press Steam + R1 to start recording"
        echo "   - Record for 15+ seconds"
        echo "   - Note if recording becomes choppy after 6 seconds"
        echo "4. Press Enter when done testing"
    fi
}

# Main comparison function
run_comparison() {
    echo "🔄 Starting recording mode comparison..."
    echo ""
    
    # Capture initial state
    initial_dir=$(capture_state "initial")
    
    # Test Big Picture Mode
    show_instructions "bigpicture"
    read -p "Press Enter when ready to test Big Picture Mode recording..."
    
    bigpicture_dir=$(capture_state "bigpicture")
    
    echo ""
    echo "📝 Big Picture Mode test complete!"
    echo "   Logs saved to: $bigpicture_dir"
    echo ""
    
    # Test Gaming Mode
    show_instructions "gaming"
    read -p "Press Enter when ready to test Gaming Mode recording..."
    
    gaming_dir=$(capture_state "gaming")
    
    echo ""
    echo "📝 Gaming Mode test complete!"
    echo "   Logs saved to: $gaming_dir"
    echo ""
    
    # Analysis
    echo "🔍 Analysis Results:"
    echo "==================="
    echo ""
    echo "📁 Log directories:"
    echo "   Initial: $initial_dir"
    echo "   Big Picture: $bigpicture_dir"
    echo "   Gaming: $gaming_dir"
    echo ""
    
    echo "🔍 Key differences to look for:"
    echo "   - Different processes running in each mode"
    echo "   - Gamescope logs only in Gaming Mode"
    echo "   - Different MangoHud configurations"
    echo "   - Different Steam log entries"
    echo ""
    
    echo "📋 To analyze the differences:"
    echo "   diff -u $bigpicture_dir/bigpicture_processes.log $gaming_dir/gaming_processes.log"
    echo "   diff -u $bigpicture_dir/bigpicture_steam.log $gaming_dir/gaming_steam.log"
    echo "   diff -u $bigpicture_dir/bigpicture_mangohud.log $gaming_dir/gaming_mangohud.log"
    echo ""
    
    echo "🎯 Expected findings:"
    echo "   - Big Picture Mode: No gamescope, direct Steam recording"
    echo "   - Gaming Mode: Gamescope compositor, overlay system conflicts"
    echo ""
}

# Check if we're in the right environment
check_environment() {
    if [[ ! -f /etc/steamos-release ]]; then
        echo "⚠️  Warning: This script is designed for Steam Deck"
        echo "   Some features may not work on other systems"
        echo ""
    fi
    
    if [[ ! -d /home/deck/.local/share/Steam ]]; then
        echo "❌ Steam not found. Please ensure Steam is installed."
        exit 1
    fi
}

# Main execution
main() {
    check_environment
    
    echo "This script will help you compare recording behavior between modes."
    echo "Make sure you have a game ready to test with."
    echo ""
    read -p "Press Enter to start the comparison..."
    
    run_comparison
}

# Run main function
main "$@"
