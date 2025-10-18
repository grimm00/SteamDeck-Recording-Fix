#!/bin/bash

# Steam Deck Recording Mode Comparison Script
# Compares recording behavior between Big Picture Mode and Gaming Mode using post-hoc log analysis

set -e

echo "🎮 Steam Deck Recording Mode Comparison"
echo "======================================="
echo ""
echo "This script helps compare recording behavior between:"
echo "  - Big Picture Mode (Desktop Mode)"
echo "  - Gaming Mode (Gamescope)"
echo ""
echo "⚠️  IMPORTANT: This script uses post-hoc log analysis."
echo "   You must record exact timestamps during testing."
echo ""

# Function to check prerequisites
check_prerequisites() {
    echo "🔍 Checking Prerequisites:"
    echo "=========================="
    
    # Check if verbose logging is enabled
    if [[ -f /etc/systemd/user/gamescope-session.service.d/override.conf ]]; then
        echo "✅ Verbose logging is enabled"
    else
        echo "❌ Verbose logging not enabled"
        echo "   Run: ./scripts/enable-verbose-logging.sh"
        echo "   Then restart your Steam Deck"
        exit 1
    fi
    
    # Check if analyze script exists
    if [[ -f ./scripts/analyze-recording-logs.sh ]]; then
        echo "✅ Analysis script found"
    else
        echo "❌ Analysis script not found: ./scripts/analyze-recording-logs.sh"
        exit 1
    fi
    
    echo ""
}

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
    
    # Capture gamescope information (only in gaming mode)
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
        echo "5. **IMPORTANT**: Note the exact time you started and stopped recording"
        echo "6. Press Enter when done testing"
    else
        echo "1. Switch to Gaming Mode:"
        echo "   - Press Steam button → Power → Switch to Gaming Mode"
        echo "2. Start the same game"
        echo "3. Test recording:"
        echo "   - Press Steam + R1 to start recording"
        echo "   - Record for 15+ seconds"
        echo "   - Note if recording becomes choppy after 6 seconds"
        echo "4. **IMPORTANT**: Note the exact time you started and stopped recording"
        echo "5. Press Enter when done testing"
    fi
}

# Function to get timestamps from user
get_timestamps() {
    local mode="$1"
    echo ""
    echo "⏰ Record the exact timestamps for $mode mode:"
    echo "=============================================="
    echo ""
    echo "Format: HH:MM:SS (24-hour format)"
    echo "Example: 23:15:32"
    echo ""
    
    read -p "Start recording time: " start_time
    read -p "Stop recording time: " stop_time
    
    echo "$start_time,$stop_time"
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
    
    bigpicture_timestamps=$(get_timestamps "Big Picture")
    bigpicture_dir=$(capture_state "bigpicture")
    
    echo ""
    echo "📝 Big Picture Mode test complete!"
    echo "   Logs saved to: $bigpicture_dir"
    echo "   Timestamps: $bigpicture_timestamps"
    echo ""
    
    # Test Gaming Mode
    show_instructions "gaming"
    read -p "Press Enter when ready to test Gaming Mode recording..."
    
    gaming_timestamps=$(get_timestamps "Gaming")
    gaming_dir=$(capture_state "gaming")
    
    echo ""
    echo "📝 Gaming Mode test complete!"
    echo "   Logs saved to: $gaming_dir"
    echo "   Timestamps: $gaming_timestamps"
    echo ""
    
    # Parse timestamps
    IFS=',' read -r bp_start bp_stop <<< "$bigpicture_timestamps"
    IFS=',' read -r gm_start gm_stop <<< "$gaming_timestamps"
    
    # Run analysis
    echo "🔍 Running log analysis..."
    echo "========================="
    echo ""
    
    ./scripts/analyze-recording-logs.sh \
        --bigpicture-start "$bp_start" \
        --bigpicture-end "$bp_stop" \
        --gaming-start "$gm_start" \
        --gaming-end "$gm_stop" \
        --output "/tmp/recording-analysis-$(date +%Y%m%d_%H%M%S).md"
    
    echo ""
    echo "✅ Analysis complete!"
    echo ""
    echo "📁 Files created:"
    echo "   Initial state: $initial_dir"
    echo "   Big Picture: $bigpicture_dir"
    echo "   Gaming: $gaming_dir"
    echo "   Analysis report: /tmp/recording-analysis-*.md"
    echo ""
    
    echo "🔍 Key differences to look for:"
    echo "   - Different processes running in each mode"
    echo "   - Gamescope logs only in Gaming Mode"
    echo "   - Different MangoHud configurations"
    echo "   - Different Steam log entries"
    echo "   - Overlay state changes around 6-second mark"
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
    check_prerequisites
    
    echo "This script will help you compare recording behavior between modes."
    echo "Make sure you have a game ready to test with."
    echo ""
    echo "⚠️  CRITICAL: You must record exact timestamps during testing!"
    echo "   The analysis depends on precise timing information."
    echo ""
    read -p "Press Enter to start the comparison..."
    
    run_comparison
}

# Run main function
main "$@"