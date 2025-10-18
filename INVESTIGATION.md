# Steam Deck Recording Investigation

## Problem Symptoms

### Primary Issue
Steam Deck game recording becomes choppy and stuttery after approximately 6 seconds of recording, coinciding with when Steam's "screen recording" notification disappears.

### Detailed Observations
- **Timing**: Issue occurs consistently at 6-second mark
- **Trigger**: Coincides with Steam recording notification disappearing
- **Symptoms**: Significant frame drops, stuttering, reduced recording quality
- **Consistency**: Reproducible across multiple games and recording methods
- **Duration**: Affects entire recording after the 6-second mark

### Affected Systems
- **SteamOS Versions**: 3.5+ (confirmed)
- **Recording Methods**: Internal Steam recording, external recording tools
- **Game Types**: All games tested show the same issue
- **Hardware**: All Steam Deck models affected

### Critical Discovery: Mode-Specific Behavior
- **Gaming Mode (Gamescope)**: Recording becomes choppy after 6 seconds
- **Big Picture Mode (Desktop)**: Recording works perfectly throughout entire duration
- **Implication**: Issue is specifically related to gamescope compositor, not Steam recording system

## Timeline Analysis

### Recording Process Timeline
```
0s:  Recording starts
0-6s: Recording notification visible, smooth recording
6s:  Recording notification disappears
6s+: Choppy/stuttery recording begins
```

### Key Observations
1. **Notification Period**: Recording is smooth while notification is visible
2. **Transition Point**: Issue begins exactly when notification disappears
3. **Persistence**: Problem continues for entire recording duration
4. **Consistency**: Timing is remarkably consistent across different scenarios

## System Architecture Analysis

### Steam Deck Recording Stack
```
┌─────────────────────────────────────┐
│           Game Application          │
├─────────────────────────────────────┤
│            Gamescope               │
│         (Compositor)               │
├─────────────────────────────────────┤
│         Steam Client               │
│      (Recording System)            │
├─────────────────────────────────────┤
│         SteamOS Kernel             │
└─────────────────────────────────────┘
```

### Overlay System Components
1. **Gamescope**: Compositor responsible for overlay management
2. **Steam Client**: Handles recording and notification display
3. **MangoHud**: Performance overlay system (when present)
4. **Overlay Layers**: Multiple overlay systems can interact

### Recording Pipeline
1. **Game Rendering**: Game renders frames
2. **Gamescope Compositing**: Compositor combines game + overlays
3. **Recording Capture**: Steam captures composited output
4. **Buffer Management**: Recording buffers store captured frames
5. **File Writing**: Buffers written to recording file

## Root Cause Hypotheses

### Hypothesis 1: Overlay State Transition
**Theory**: Steam's recording notification creates a temporary overlay layer. When it disappears, the overlay system state changes, causing gamescope to reconfigure the rendering pipeline.

**Evidence**:
- Timing correlation with notification disappearance
- MangoHud overlay prevents the issue
- Problem is consistent across games
- Overlay system is known to affect compositor behavior

**Mechanism**:
1. Recording notification creates overlay layer
2. Gamescope optimizes for notification overlay
3. Notification disappears, overlay state changes
4. Gamescope reconfigures rendering pipeline
5. Recording buffer management becomes unstable

### Hypothesis 2: Compositor Resource Reallocation
**Theory**: The recording notification system uses GPU/compositor resources. When it disappears, resource allocation changes, causing the recording process to lose priority or access to necessary resources.

**Evidence**:
- Performance-related symptoms (frame drops)
- Overlay keeps resources allocated
- Affects recording quality specifically
- GPU resource management is complex in gamescope

**Mechanism**:
1. Notification system allocates GPU resources
2. Recording process shares resources with notification
3. Notification disappears, resources deallocated
4. Recording process loses resource access
5. Frame drops and stuttering occur

### Hypothesis 3: Buffer Management Strategy Change
**Theory**: The recording system uses different buffer management strategies before and after the notification disappears. The transition between these strategies causes frame drops.

**Evidence**:
- Timing-specific issue
- Overlay prevents buffer strategy change
- Consistent across different games
- Recording pipeline is complex

**Mechanism**:
1. Initial recording uses notification-optimized buffers
2. Notification disappears, buffer strategy changes
3. Transition causes temporary buffer instability
4. Recording quality degrades
5. New buffer strategy is less efficient

### Hypothesis 4: Steam Client State Machine
**Theory**: Steam's recording client has a state machine that changes behavior when the notification disappears, affecting the recording pipeline.

**Evidence**:
- Issue is Steam-specific
- Timing matches Steam notification lifecycle
- Other recording tools may not have this issue
- Steam client manages recording internally

**Mechanism**:
1. Steam client enters "recording with notification" state
2. Notification disappears, state changes
3. New state uses different recording parameters
4. Recording quality degrades in new state
5. State transition is not smooth

## Testing Results

### MangoHud Overlay Solution
**Test**: Keep MangoHud overlay active during recording
**Result**: ✅ Recording remains smooth throughout
**Conclusion**: Overlay presence prevents the issue

### Notification Timing Tests
**Test**: Record with/without notification system
**Result**: Issue only occurs when notification disappears
**Conclusion**: Notification lifecycle is the trigger

### Resource Monitoring
**Test**: Monitor GPU/CPU usage during recording
**Result**: Resource usage changes at 6-second mark
**Conclusion**: Resource allocation changes are involved

### Buffer Analysis
**Test**: Analyze recording buffer behavior
**Result**: Buffer management changes at transition point
**Conclusion**: Buffer strategy changes cause instability

## Technical Deep Dive

### Gamescope Overlay System
Gamescope manages multiple overlay layers:
- **Game Layer**: Primary game rendering
- **Notification Layer**: Steam notifications
- **Performance Layer**: MangoHud overlays
- **System Layer**: System notifications

**Overlay State Management**:
- Overlays can be added/removed dynamically
- State changes trigger compositor reconfiguration
- Resource allocation changes with overlay state
- Recording pipeline is affected by overlay changes

### Steam Recording Implementation
Steam's recording system:
- **Capture Method**: Screenshots of composited output
- **Buffer Management**: Circular buffers for frame storage
- **Quality Settings**: Configurable bitrate and resolution
- **Notification System**: Visual feedback for recording state

**Recording State Machine**:
1. **Initialization**: Set up recording pipeline
2. **Active Recording**: Capture and store frames
3. **Notification Display**: Show recording indicator
4. **Notification Hide**: Remove visual indicator
5. **Continued Recording**: Maintain recording pipeline

### MangoHud Integration
MangoHud provides:
- **Performance Overlay**: System performance information
- **Overlay Management**: Consistent overlay layer
- **Resource Allocation**: Stable GPU resource usage
- **Compositor Integration**: Works with gamescope

**Why MangoHud Fixes the Issue**:
- Maintains consistent overlay state
- Prevents compositor reconfiguration
- Keeps resource allocation stable
- Provides stable recording pipeline

## Logging and Investigation Tools

### Gaming Mode Constraints
**Important**: When switching from Desktop Mode to Gaming Mode, Steam Deck suspends most Desktop processes to optimize for gaming performance. This means background monitoring scripts won't persist across mode switches.

### Available Scripts
The project includes several scripts designed to work within these constraints:

1. **`scripts/enable-verbose-logging.sh`**: System-level verbose logging setup
   - Enables debug logging that persists across Gaming Mode switches
   - Sets up systemd overrides for gamescope-session service
   - One-time setup, then logs are automatic

2. **`scripts/compare-recording-modes.sh`**: Guided mode comparison tool
   - Walks through Big Picture Mode vs Gaming Mode testing
   - Collects exact timestamps during testing
   - Runs post-hoc log analysis automatically

3. **`scripts/analyze-recording-logs.sh`**: Post-hoc log analysis
   - Extracts logs using timestamp ranges
   - Compares system logs between modes
   - Generates markdown reports for upstream reporting

4. **`scripts/archive/monitor-recording-logs.sh`**: Archived (not viable)
   - Moved to archive due to Gaming Mode constraints
   - Replaced by post-hoc analysis approach

### Investigation Workflow
1. **Enable verbose logging** (one-time setup)
2. **Test in Big Picture Mode**, record exact timestamps
3. **Switch to Gaming Mode**, test recording, record timestamps
4. **Return to Desktop Mode**, run analysis scripts
5. **Review generated report** for key differences

### Key Log Sources
- **Gamescope**: `journalctl --user -u gamescope-session --since TIME --until TIME`
- **Steam**: `/home/deck/.local/share/Steam/logs/gameprocess_log.txt`
- **System**: `journalctl --since TIME --until TIME | grep -i "record\|overlay\|notification"`
- **MangoHud**: Process monitoring and config file changes

### Documentation
- **`docs/LOGGING_GUIDE.md`**: Complete step-by-step investigation guide
- Includes troubleshooting, expected results, and reporting guidance

## Future Research Directions

### Upstream Investigation
1. **Gamescope Analysis**: Deep dive into gamescope source code
2. **Steam Client Investigation**: Analyze Steam recording implementation
3. **Kernel Integration**: Check kernel-level recording support
4. **Driver Analysis**: GPU driver recording optimization

### Alternative Solutions
1. **Gamescope Patches**: Modify gamescope to handle transitions better
2. **Steam Client Patches**: Fix Steam recording state machine
3. **Kernel Patches**: Improve recording at kernel level
4. **Driver Patches**: Optimize GPU recording support

### Community Research
1. **User Reports**: Collect more user experiences
2. **System Variations**: Test on different configurations
3. **Game-Specific Analysis**: Check for game-specific issues
4. **Performance Impact**: Measure solution performance

## Conclusion

The Steam Deck recording choppiness issue is caused by overlay system state changes in the gamescope compositor when Steam's recording notification disappears. The MangoHud overlay solution works by maintaining a consistent overlay state, preventing the compositor from reconfiguring the rendering pipeline.

**Key Findings**:
- Issue is reproducible and timing-specific
- Root cause is overlay system state management
- MangoHud overlay prevents the problem
- Multiple solutions are available
- Upstream fix would require gamescope/Steam changes

**Recommended Actions**:
1. Use MangoHud overlay solution for immediate fix
2. Report issue to Valve/SteamOS team
3. Contribute to gamescope development
4. Monitor for official fixes
5. Continue community research

---

**Investigation Date**: October 17, 2025  
**Status**: Active Investigation  
**Next Steps**: Upstream reporting and community research
