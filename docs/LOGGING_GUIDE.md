# Steam Deck Recording Investigation Guide

## Overview

This guide explains how to investigate the Steam Deck recording choppiness issue using the provided logging tools. The investigation focuses on comparing Big Picture Mode (working) vs Gaming Mode (choppy after 6 seconds).

## Prerequisites

1. **Enable Verbose Logging** (one-time setup):
   ```bash
   ./scripts/enable-verbose-logging.sh
   ```
   - This creates systemd overrides for verbose logging
   - **Important**: Restart your Steam Deck after running this script

2. **Verify Logging is Enabled**:
   ```bash
   # Check if systemd override exists
   ls -la /etc/systemd/user/gamescope-session.service.d/override.conf
   ```

## Investigation Workflow

### Step 1: Prepare for Testing

1. **Restart Steam Deck** (if you just enabled verbose logging)
2. **Have a game ready** for testing
3. **Note the current time** - you'll need exact timestamps

### Step 2: Test Big Picture Mode (Working Recording)

1. **Switch to Desktop Mode**:
   - Press Steam button → Power → Switch to Desktop

2. **Open Steam in Big Picture Mode**:
   - Launch Steam from desktop
   - Click "Big Picture Mode" button

3. **Start a game and test recording**:
   - Launch your test game
   - Press Steam + R1 to start recording
   - **Record the exact start time** (HH:MM:SS format)
   - Record for 15+ seconds
   - Press Steam + R1 to stop recording
   - **Record the exact stop time** (HH:MM:SS format)
   - Note: Recording should stay smooth throughout

### Step 3: Test Gaming Mode (Choppy Recording)

1. **Switch to Gaming Mode**:
   - Press Steam button → Power → Switch to Gaming Mode

2. **Start the same game and test recording**:
   - Launch the same test game
   - Press Steam + R1 to start recording
   - **Record the exact start time** (HH:MM:SS format)
   - Record for 15+ seconds
   - Press Steam + R1 to stop recording
   - **Record the exact stop time** (HH:MM:SS format)
   - Note: Recording should become choppy after 6 seconds

### Step 4: Return to Desktop Mode for Analysis

1. **Switch back to Desktop Mode**:
   - Press Steam button → Power → Switch to Desktop

2. **Run the comparison script**:
   ```bash
   ./scripts/compare-recording-modes.sh
   ```
   - This script will guide you through the process
   - It will ask for your timestamps from Steps 2 and 3
   - It will automatically run the analysis

### Step 5: Analyze Results

The analysis script will generate a report showing:

- **Gamescope logs** (only present in Gaming Mode)
- **Steam log differences** between modes
- **System log differences**
- **MangoHud process differences**
- **Key events around the 6-second mark**

## Manual Analysis (Alternative)

If you prefer to run the analysis manually:

```bash
# Extract logs for Big Picture Mode (replace with your timestamps)
./scripts/analyze-recording-logs.sh \
  --bigpicture-start 23:15:32 \
  --bigpicture-end 23:15:47 \
  --gaming-start 23:20:15 \
  --gaming-end 23:20:30
```

## What to Look For

### Key Differences Between Modes

1. **Gamescope Presence**:
   - Big Picture Mode: No gamescope logs (direct Steam recording)
   - Gaming Mode: Gamescope compositor activity

2. **Overlay State Changes**:
   - Look for overlay state transitions in Gaming Mode
   - Focus on events around the 6-second mark
   - Look for compositor reconfiguration messages

3. **Recording Pipeline**:
   - Compare Steam recording behavior between modes
   - Look for notification timing differences
   - Check for resource allocation changes

4. **MangoHud Integration**:
   - Compare MangoHud process activity
   - Look for config file changes
   - Check for overlay system interactions

### Critical Events to Find

- **Overlay state changes** in gamescope logs
- **Compositor reconfiguration** messages
- **Recording notification events** in Steam logs
- **Resource allocation changes** around 6-second mark
- **MangoHud process changes** or config updates

## Troubleshooting

### Verbose Logging Not Working

1. **Check systemd override**:
   ```bash
   cat /etc/systemd/user/gamescope-session.service.d/override.conf
   ```

2. **Restart Steam Deck** if you just enabled logging

3. **Check gamescope service status**:
   ```bash
   systemctl --user status gamescope-session
   ```

### No Logs Found

1. **Check log file locations**:
   ```bash
   # Gamescope logs
   journalctl --user -u gamescope-session --since "1 hour ago"
   
   # Steam logs
   ls -la /home/deck/.local/share/Steam/logs/
   ```

2. **Verify timestamps** are in correct format (HH:MM:SS)

3. **Check system time** is correct

### Analysis Script Fails

1. **Check script permissions**:
   ```bash
   chmod +x ./scripts/analyze-recording-logs.sh
   ```

2. **Verify all required parameters** are provided

3. **Check output directory** is writable

## Expected Results

### Big Picture Mode (Working)
- No gamescope logs
- Direct Steam recording pipeline
- Smooth recording throughout
- Minimal overlay system activity

### Gaming Mode (Choppy)
- Gamescope compositor logs
- Overlay state changes around 6-second mark
- Compositor reconfiguration events
- Recording pipeline conflicts

## Reporting Findings

The analysis report is suitable for:

1. **Upstream Issue Reporting**:
   - Gamescope GitHub issues
   - Steam Deck community forums
   - Valve support tickets

2. **Community Documentation**:
   - Update project documentation
   - Share findings with other users
   - Contribute to solution development

3. **Technical Analysis**:
   - Deep dive into root cause
   - Solution development
   - Performance optimization

## Next Steps

After completing the investigation:

1. **Review the analysis report** for key findings
2. **Document any new discoveries** in the project
3. **Share findings** with the community
4. **Consider upstream reporting** if new insights are found
5. **Update solutions** based on findings

## Tips for Success

1. **Record exact timestamps** - analysis depends on precise timing
2. **Use the same game** for both tests to ensure consistency
3. **Test multiple times** to verify reproducibility
4. **Document your findings** as you go
5. **Share results** with the community for validation
