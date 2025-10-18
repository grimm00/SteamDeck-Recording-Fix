# Steam Deck Recording Fix

[![SteamOS Compatibility](https://img.shields.io/badge/SteamOS-3.5%2B-blue)](https://store.steampowered.com/steamos)
[![Solutions Available](https://img.shields.io/badge/Solutions-4%2B-green)](#solutions)
[![Community](https://img.shields.io/badge/Community-Active-orange)](https://github.com/grimm00/SteamDeck-Recording-Fix/discussions)
[![Status](https://img.shields.io/badge/Status-Maintained-brightgreen)](#status)

## The Problem

Steam Deck game recording becomes **choppy and stuttery after approximately 6 seconds**, right when the "screen recording" notification disappears. This affects the quality of your recorded gameplay and makes recordings unusable for longer sessions.

### Symptoms
- ✅ **First 6 seconds**: Recording is smooth and high quality
- ❌ **After 6 seconds**: Significant frame drops and stuttering
- 🕐 **Timing**: Coincides with Steam's recording notification disappearing
- 🎮 **Affects**: All games and recording methods

## Quick Fix (Recommended Solutions)

### Option 1: Direct MangoHud Configuration (Recommended)

**No plugin required** - works reliably on any Steam Deck

1. **Create MangoHud Configuration**:
   ```bash
   mkdir -p ~/.config/MangoHud
   cat > ~/.config/MangoHud/MangoHud.conf << 'EOF'
   control=mangohud
   no_display
   alpha=0.0
   background_alpha=0.0
   EOF
   ```

2. **Enable MangoHud**:
   - Add `MANGOHUD=1` to your game's launch options
   - Or set it globally in Steam settings

3. **Test Recording**:
   - Start any game
   - Begin recording (Steam + R1)
   - Record for 10+ seconds
   - Verify smooth recording throughout

**Result**: Recording stays smooth for the entire duration! 🎉

### Option 2: MangoPeel Transparent Overlay (May Work)

⚠️ **Note**: This solution has known reliability issues. The plugin may not consistently apply preset changes.

**Prerequisites**: MangoPeel plugin installed via Decky Loader

1. **Install MangoPeel** (if not already installed):
   - Install Decky Loader
   - Install MangoPeel from the Decky Store
   - Apply SteamOS compatibility fixes (see [MangoPeel project](https://github.com/grimm00/MangoPeel_Steam_OS_Fixes))

2. **Configure Transparent Overlay**:
   - Open MangoPeel in Steam Deck's Quick Access menu
   - Set preset to **Preset 0 (Recording Fix)**
   - The overlay should be completely invisible but active

3. **Test Recording**: Same as above

**If this doesn't work**: Try Option 1 (Direct MangoHud Configuration) instead.

## Alternative Solutions

| Solution | Difficulty | Effectiveness | Requirements |
|----------|------------|---------------|--------------|
| [Direct MangoHud](solutions/mangohud-direct/) | ⭐⭐ Moderate | ⭐⭐⭐⭐⭐ | MangoHud only |
| [MangoPeel Transparent](solutions/mangopeel-transparent/) | ⭐ Easy | ⭐⭐⭐ | Decky Loader + MangoPeel |
| [Systemd Service](solutions/systemd-service/) | ⭐⭐⭐ Advanced | ⭐⭐⭐⭐⭐ | System access |
| [Manual Workarounds](docs/manual-workarounds.md) | ⭐⭐⭐⭐ Expert | ⭐⭐⭐ Variable | Various |

## How It Works

The issue occurs because:
1. **Steam's recording notification** creates a temporary overlay layer
2. **When the notification disappears** (after ~6 seconds), the overlay system state changes
3. **Gamescope compositor** reconfigures the rendering pipeline
4. **Recording buffers** become unstable, causing choppiness

**The Fix**: Keep a transparent overlay active to prevent the overlay system from changing states, maintaining a stable recording pipeline.

## Technical Details

- **Root Cause**: Overlay system conflicts in gamescope compositor
- **Affected Components**: Steam recording, gamescope, MangoHud
- **SteamOS Versions**: 3.5+ (tested)
- **Performance Impact**: Negligible (< 0.1% CPU, invisible overlay)

For detailed technical analysis, see [INVESTIGATION.md](INVESTIGATION.md).

## Testing

### Quick Test
1. Start recording in any game
2. Record for 15+ seconds
3. Check if recording becomes choppy after 6 seconds

### Automated Testing
```bash
# Run our automated test
./scripts/diagnose-recording.sh

# Test recording quality
./testing/test-recording.sh
```

## Community

- **🐛 Bug Reports**: [GitHub Issues](https://github.com/grimm00/SteamDeck-Recording-Fix/issues)
- **💬 Discussions**: [GitHub Discussions](https://github.com/grimm00/SteamDeck-Recording-Fix/discussions)
- **📺 Reddit**: [r/SteamDeck](https://reddit.com/r/SteamDeck)
- **🎮 Discord**: [Steam Deck Discord](https://discord.gg/steamdeck)

## Contributing

We welcome contributions! See [CONTRIBUTING.md](community/contributions.md) for:
- How to test and report results
- How to submit new solutions
- How to help with documentation
- Code of conduct

## Status

- ✅ **Issue Identified**: Steam Deck recording choppiness after 6 seconds
- ✅ **Root Cause Found**: Overlay system conflicts in gamescope
- ✅ **Solutions Available**: Multiple working fixes
- ✅ **Community Active**: Ongoing testing and improvements
- ⏳ **Official Fix**: Waiting for Valve/SteamOS team response

## Related Projects

- **[MangoPeel SteamOS Fixes](https://github.com/grimm00/MangoPeel_Steam_OS_Fixes)**: Plugin compatibility fixes
- **[MangoHud](https://github.com/flightlessmango/MangoHud)**: Performance overlay system
- **[Gamescope](https://github.com/Plagman/gamescope)**: Steam Deck compositor

## License

This project is licensed under the BSD-3-Clause License - see the [LICENSE](LICENSE) file for details.

---

**Last Updated**: October 17, 2025  
**SteamOS Compatibility**: 3.5+  
**Status**: Active Development
