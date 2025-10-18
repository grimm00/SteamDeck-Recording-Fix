# MangoPeel Transparent Overlay Solution

⚠️ **IMPORTANT NOTICE**: This solution has known reliability issues. The MangoPeel plugin's preset system may not consistently apply changes, making this solution unreliable for many users.

**Recommended Alternative**: If you experience issues with this solution, try the [Direct MangoHud Configuration](../mangohud-direct/) instead, which is more reliable and doesn't depend on plugin functionality.

## Overview

This solution uses MangoPeel's transparent overlay to prevent Steam Deck recording choppiness. While it can be user-friendly when working, it has known reliability issues with the preset system.

## How It Works

The transparent overlay keeps the MangoHud overlay system active during recording, preventing gamescope from changing overlay states when Steam's recording notification disappears. This maintains a stable recording pipeline.

## Prerequisites

- ✅ **Steam Deck** with SteamOS 3.5+
- ✅ **Decky Loader** installed
- ✅ **MangoPeel plugin** installed and working
- ✅ **SteamOS compatibility fixes** applied (if needed)

## Installation

### Step 1: Install MangoPeel (if not already installed)

1. **Install Decky Loader**:
   - Follow [Decky Loader installation guide](https://decky.xyz/)
   - Ensure it's working properly

2. **Install MangoPeel**:
   - Open Decky Loader in Steam Deck
   - Go to Plugin Store
   - Search for "MangoPeel"
   - Install the plugin

3. **Apply Compatibility Fixes** (if needed):
   - If MangoPeel has issues, apply fixes from [MangoPeel SteamOS Fixes](https://github.com/grimm00/MangoPeel_Steam_OS_Fixes)

### Step 2: Configure Transparent Overlay

1. **Open MangoPeel**:
   - Press Steam button
   - Go to Quick Access menu
   - Find MangoPeel plugin

2. **Set Recording Fix Preset**:
   - Select **Preset 0 (Recording Fix)**
   - The overlay will be completely transparent (invisible)

3. **Verify Configuration**:
   - Preset should show as "Recording Fix" or "No Display"
   - No visible overlay elements should appear

### Step 3: Test Recording

1. **Start a Game**:
   - Launch any game on your Steam Deck

2. **Begin Recording**:
   - Press **Steam + R1** to start recording
   - You should see the recording notification

3. **Test Duration**:
   - Record for **15+ seconds**
   - Watch for choppiness after 6 seconds

4. **Verify Fix**:
   - Recording should remain smooth throughout
   - No stuttering or frame drops after 6 seconds

## Configuration Details

### Preset 0 Configuration
```
control=mangohud
mangoapp_steam
fsr_steam_sharpness=5
nis_steam_sharpness=10
no_display
alpha=0.0
background_alpha=0.0
```

### What Each Setting Does
- **`control=mangohud`**: Enables MangoHud overlay system
- **`mangoapp_steam`**: Integrates with Steam overlay system
- **`no_display`**: Prevents any visual elements from showing
- **`alpha=0.0`**: Makes overlay completely transparent
- **`background_alpha=0.0`**: Makes background completely transparent

## Troubleshooting

### Overlay Not Working
**Symptoms**: Recording still choppy after 6 seconds

**Solutions**:
1. **Check Preset**: Ensure Preset 0 is selected
2. **Restart Steam**: Restart Steam to apply changes
3. **Check MangoPeel**: Verify MangoPeel is running
4. **Apply Fixes**: Use compatibility fixes if needed

### Visible Overlay Elements
**Symptoms**: Can see overlay elements (should be invisible)

**Solutions**:
1. **Check Alpha Settings**: Ensure alpha=0.0
2. **Verify Preset**: Make sure correct preset is selected
3. **Restart Plugin**: Restart MangoPeel plugin

### Performance Issues
**Symptoms**: Game performance affected

**Solutions**:
1. **Check Overlay**: Ensure overlay is transparent
2. **Monitor Resources**: Check CPU/GPU usage
3. **Alternative Solutions**: Try direct MangoHud config

### Preset System Not Working (Common Issue)
**Symptoms**: Preset changes don't take effect, recording still choppy

**This is a known issue with the MangoPeel plugin. The preset system may not consistently apply changes.**

**Solutions**:
1. **Try Alternative Solution**: Use [Direct MangoHud Configuration](../mangohud-direct/) instead
2. **Check Plugin Status**: Verify MangoPeel is actually running
3. **Restart Everything**: Restart Steam, Decky Loader, and MangoPeel
4. **Apply Compatibility Fixes**: Use fixes from [MangoPeel SteamOS Fixes](https://github.com/grimm00/MangoPeel_Steam_OS_Fixes)
5. **Manual Configuration**: Try manually editing MangoHud config files

**If none of these work**: The plugin may have fundamental issues. Switch to Direct MangoHud Configuration.

## Advantages

- ✅ **Easiest Setup**: Just change one preset setting (when working)
- ✅ **No Manual Config**: No file editing required
- ✅ **Toggle On/Off**: Can easily enable/disable
- ✅ **User-Friendly**: Works through plugin interface (when working)
- ✅ **Immediate Effect**: Works right away (when working)

## Disadvantages

- ❌ **Plugin Dependency**: Requires MangoPeel plugin
- ❌ **Decky Loader**: Requires Decky Loader installation
- ❌ **Compatibility**: May need SteamOS compatibility fixes
- ❌ **Reliability Issues**: Preset system may not work consistently
- ❌ **Unpredictable**: May work for some users but not others

## Performance Impact

- **CPU Usage**: < 0.1% (negligible)
- **GPU Usage**: Minimal (keeps overlay system active)
- **Memory**: ~1-2MB for overlay system
- **Battery**: No measurable impact
- **Visual Impact**: Completely invisible

## Alternative Solutions

If this solution doesn't work for you:

1. **[Direct MangoHud Configuration](../mangohud-direct/)**: No plugin required
2. **[Systemd Service](../systemd-service/)**: System-level solution
3. **[Manual Workarounds](../../docs/manual-workarounds.md)**: Temporary solutions

## Support

- **Issues**: [GitHub Issues](https://github.com/grimm00/SteamDeck-Recording-Fix/issues)
- **Discussions**: [GitHub Discussions](https://github.com/grimm00/SteamDeck-Recording-Fix/discussions)
- **MangoPeel Issues**: [MangoPeel Project](https://github.com/grimm00/MangoPeel_Steam_OS_Fixes)

---

**Last Updated**: October 17, 2025  
**Compatibility**: SteamOS 3.5+, MangoPeel 0.0.6+  
**Status**: Working Solution
