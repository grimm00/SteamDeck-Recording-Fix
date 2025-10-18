#!/bin/bash

# Steam Deck Recording Log Analysis Script
# Analyzes logs from Big Picture Mode vs Gaming Mode recording tests

set -e

# Default values
BIGPICTURE_START=""
BIGPICTURE_END=""
GAMING_START=""
GAMING_END=""
OUTPUT_FILE=""

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --bigpicture-start TIME    Start time for Big Picture Mode test (HH:MM:SS)"
    echo "  --bigpicture-end TIME      End time for Big Picture Mode test (HH:MM:SS)"
    echo "  --gaming-start TIME        Start time for Gaming Mode test (HH:MM:SS)"
    echo "  --gaming-end TIME          End time for Gaming Mode test (HH:MM:SS)"
    echo "  --output FILE              Output file for analysis report (default: auto-generated)"
    echo "  --help                     Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 --bigpicture-start 23:15:32 --bigpicture-end 23:15:47 \\"
    echo "     --gaming-start 23:20:15 --gaming-end 23:20:30"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --bigpicture-start)
            BIGPICTURE_START="$2"
            shift 2
            ;;
        --bigpicture-end)
            BIGPICTURE_END="$2"
            shift 2
            ;;
        --gaming-start)
            GAMING_START="$2"
            shift 2
            ;;
        --gaming-end)
            GAMING_END="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$BIGPICTURE_START" || -z "$BIGPICTURE_END" || -z "$GAMING_START" || -z "$GAMING_END" ]]; then
    echo "❌ Error: All timestamp parameters are required"
    show_usage
    exit 1
fi

# Generate output filename if not provided
if [[ -z "$OUTPUT_FILE" ]]; then
    OUTPUT_FILE="/tmp/recording-analysis-$(date +%Y%m%d_%H%M%S).md"
fi

echo "🔍 Steam Deck Recording Log Analysis"
echo "===================================="
echo ""
echo "Big Picture Mode: $BIGPICTURE_START - $BIGPICTURE_END"
echo "Gaming Mode: $GAMING_START - $GAMING_END"
echo "Output: $OUTPUT_FILE"
echo ""

# Function to extract logs for a time period
extract_logs() {
    local start_time="$1"
    local end_time="$2"
    local mode="$3"
    local output_dir="/tmp/log-extraction-$(date +%s)"
    
    mkdir -p "$output_dir"
    
    echo "📊 Extracting logs for $mode mode ($start_time - $end_time)..."
    
    # Extract gamescope logs
    echo "=== GAMESCOPE LOGS ===" > "$output_dir/${mode}_gamescope.log"
    journalctl --user -u gamescope-session --since "$start_time" --until "$end_time" >> "$output_dir/${mode}_gamescope.log" 2>&1 || true
    
    # Extract Steam logs (approximate - Steam logs don't have precise timestamps)
    echo "=== STEAM LOGS ===" > "$output_dir/${mode}_steam.log"
    tail -100 /home/deck/.local/share/Steam/logs/gameprocess_log.txt >> "$output_dir/${mode}_steam.log" 2>&1 || true
    
    # Extract system logs
    echo "=== SYSTEM LOGS ===" > "$output_dir/${mode}_system.log"
    journalctl --since "$start_time" --until "$end_time" | grep -i "record\|overlay\|notification\|mango\|steam" >> "$output_dir/${mode}_system.log" 2>&1 || true
    
    # Extract MangoHud processes
    echo "=== MANGOHUD PROCESSES ===" > "$output_dir/${mode}_mangohud.log"
    ps aux | grep -i mango | grep -v grep >> "$output_dir/${mode}_mangohud.log" 2>&1 || true
    
    echo "$output_dir"
}

# Function to analyze log differences
analyze_differences() {
    local bp_dir="$1"
    local gm_dir="$2"
    
    echo "🔍 Analyzing differences between modes..."
    
    # Compare gamescope logs
    echo "### Gamescope Log Differences" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    if [[ -f "$bp_dir/bigpicture_gamescope.log" && -f "$gm_dir/gaming_gamescope.log" ]]; then
        echo "**Big Picture Mode:** No gamescope logs (expected)" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "**Gaming Mode:** Gamescope logs found" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        cat "$gm_dir/gaming_gamescope.log" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
    else
        echo "⚠️  Gamescope logs not found for comparison" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    
    # Compare Steam logs
    echo "### Steam Log Differences" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "**Big Picture Mode Steam Logs:**" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    cat "$bp_dir/bigpicture_steam.log" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "**Gaming Mode Steam Logs:**" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    cat "$gm_dir/gaming_steam.log" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Compare system logs
    echo "### System Log Differences" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "**Big Picture Mode System Logs:**" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    cat "$bp_dir/bigpicture_system.log" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "**Gaming Mode System Logs:**" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    cat "$gm_dir/gaming_system.log" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Compare MangoHud processes
    echo "### MangoHud Process Differences" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "**Big Picture Mode MangoHud:**" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    cat "$bp_dir/bigpicture_mangohud.log" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "**Gaming Mode MangoHud:**" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    cat "$gm_dir/gaming_mangohud.log" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

# Function to look for key events
find_key_events() {
    local bp_dir="$1"
    local gm_dir="$2"
    
    echo "🎯 Looking for key events around 6-second mark..."
    
    echo "### Key Events Analysis" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Look for overlay-related events in gaming mode
    echo "#### Gaming Mode - Overlay Events" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    if [[ -f "$gm_dir/gaming_gamescope.log" ]]; then
        grep -i "overlay\|compositor\|notification\|state" "$gm_dir/gaming_gamescope.log" >> "$OUTPUT_FILE" 2>&1 || echo "No overlay events found" >> "$OUTPUT_FILE"
    else
        echo "No gamescope logs available" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    
    # Look for recording-related events
    echo "#### Recording Events" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "**Big Picture Mode:**" >> "$OUTPUT_FILE"
    grep -i "record\|notification" "$bp_dir/bigpicture_system.log" >> "$OUTPUT_FILE" 2>&1 || echo "No recording events found" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "**Gaming Mode:**" >> "$OUTPUT_FILE"
    grep -i "record\|notification" "$gm_dir/gaming_system.log" >> "$OUTPUT_FILE" 2>&1 || echo "No recording events found" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

# Function to generate summary
generate_summary() {
    echo "📋 Generating analysis summary..."
    
    echo "## Analysis Summary" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "### Test Configuration" >> "$OUTPUT_FILE"
    echo "- **Big Picture Mode**: $BIGPICTURE_START - $BIGPICTURE_END" >> "$OUTPUT_FILE"
    echo "- **Gaming Mode**: $GAMING_START - $GAMING_END" >> "$OUTPUT_FILE"
    echo "- **Analysis Date**: $(date)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    echo "### Key Findings" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "1. **Gamescope Presence**: Gaming Mode shows gamescope compositor activity, Big Picture Mode does not" >> "$OUTPUT_FILE"
    echo "2. **Overlay System**: Look for overlay state changes in Gaming Mode logs around 6-second mark" >> "$OUTPUT_FILE"
    echo "3. **Recording Pipeline**: Compare Steam recording behavior between modes" >> "$OUTPUT_FILE"
    echo "4. **MangoHud Integration**: Check for MangoHud process differences" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    echo "### Next Steps" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "1. Review overlay state changes in Gaming Mode gamescope logs" >> "$OUTPUT_FILE"
    echo "2. Look for compositor reconfiguration events around 6-second mark" >> "$OUTPUT_FILE"
    echo "3. Compare Steam recording notification timing between modes" >> "$OUTPUT_FILE"
    echo "4. Document findings for upstream gamescope issue reporting" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

# Main execution
main() {
    # Create output file
    cat > "$OUTPUT_FILE" << EOF
# Steam Deck Recording Analysis Report

**Generated**: $(date)
**Big Picture Mode**: $BIGPICTURE_START - $BIGPICTURE_END
**Gaming Mode**: $GAMING_START - $GAMING_END

## Overview

This report compares recording behavior between Big Picture Mode (working) and Gaming Mode (choppy after 6 seconds).

EOF

    # Extract logs for both modes
    bp_dir=$(extract_logs "$BIGPICTURE_START" "$BIGPICTURE_END" "bigpicture")
    gm_dir=$(extract_logs "$GAMING_START" "$GAMING_END" "gaming")
    
    # Analyze differences
    analyze_differences "$bp_dir" "$gm_dir"
    
    # Find key events
    find_key_events "$bp_dir" "$gm_dir"
    
    # Generate summary
    generate_summary
    
    echo "✅ Analysis complete!"
    echo "📄 Report saved to: $OUTPUT_FILE"
    echo ""
    echo "🔍 Key things to look for in the report:"
    echo "   - Overlay state changes in Gaming Mode gamescope logs"
    echo "   - Compositor reconfiguration events around 6-second mark"
    echo "   - Recording notification timing differences"
    echo "   - MangoHud process differences between modes"
    echo ""
    echo "📋 To view the report:"
    echo "   cat $OUTPUT_FILE"
    echo "   # or open in a text editor"
}

# Run main function
main "$@"
