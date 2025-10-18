# Steam Deck Recording Testing Guide

## Overview

This guide provides comprehensive testing procedures for the Steam Deck recording choppiness issue. It includes how to reproduce the issue, test solutions, and verify fixes.

## Quick Test

### Basic Recording Test
1. **Start a Game**: Launch any game on your Steam Deck
2. **Begin Recording**: Press **Steam + R1** to start recording
3. **Record Duration**: Record for **15+ seconds**
4. **Check Quality**: Look for choppiness after 6 seconds

### Expected Results
- **First 6 seconds**: Smooth recording
- **After 6 seconds**: Choppy/stuttery recording (if issue exists)
- **With Fix**: Smooth recording throughout

## Detailed Testing Procedures

### 1. Issue Reproduction

#### Prerequisites
- Steam Deck with SteamOS 3.5+
- Any game installed
- Recording capability enabled

#### Steps
1. **Launch Game**: Start any game
2. **Start Recording**: Press Steam + R1
3. **Wait for Notification**: Recording notification appears
4. **Monitor Timeline**: Watch for 6-second mark
5. **Observe Quality**: Check recording quality after 6 seconds

#### Expected Behavior
- **0-6 seconds**: Recording notification visible, smooth recording
- **6+ seconds**: Notification disappears, recording becomes choppy

#### Troubleshooting Failed Reproduction
- **Check SteamOS Version**: Ensure 3.5+
- **Verify Recording**: Ensure recording is actually working
- **Test Different Games**: Try multiple games
- **Check System State**: Ensure system is in normal state

### 2. Solution Testing

#### MangoPeel Transparent Overlay Test
1. **Install MangoPeel**: Ensure plugin is installed and working
2. **Set Preset**: Change to "Preset 0 (Recording Fix)"
3. **Verify Transparency**: Ensure overlay is invisible
4. **Test Recording**: Record for 15+ seconds
5. **Check Quality**: Verify smooth recording throughout

#### Direct MangoHud Test
1. **Create Configuration**: Set up MangoHud config
2. **Enable MangoHud**: Set MANGOHUD=1
3. **Test Recording**: Record for 15+ seconds
4. **Check Quality**: Verify smooth recording throughout

#### Systemd Service Test
1. **Install Service**: Set up systemd service
2. **Enable Service**: Start and enable service
3. **Test Recording**: Record for 15+ seconds
4. **Check Quality**: Verify smooth recording throughout

### 3. Performance Testing

#### Resource Usage Test
1. **Monitor Resources**: Check CPU/GPU usage during recording
2. **Compare States**: Compare with/without fix
3. **Measure Impact**: Quantify performance impact
4. **Document Results**: Record findings

#### Battery Life Test
1. **Record Battery**: Check battery level before test
2. **Record for Extended Period**: Record for 30+ minutes
3. **Monitor Battery**: Check battery drain
4. **Compare Results**: Compare with/without fix

#### Game Performance Test
1. **Benchmark Game**: Run game benchmarks
2. **Compare FPS**: Check frame rates with/without fix
3. **Monitor Stuttering**: Check for frame drops
4. **Document Impact**: Record performance impact

### 4. Compatibility Testing

#### Game Compatibility Test
1. **Test Multiple Games**: Try different game types
2. **Check Genres**: Test various game genres
3. **Verify Compatibility**: Ensure fix works across games
4. **Document Issues**: Record any game-specific problems

#### SteamOS Version Test
1. **Test Different Versions**: Try various SteamOS versions
2. **Check Updates**: Test after system updates
3. **Verify Compatibility**: Ensure fix works across versions
4. **Document Changes**: Record version-specific issues

#### Hardware Compatibility Test
1. **Test Different Models**: Try various Steam Deck models
2. **Check Storage**: Test different storage types
3. **Verify Compatibility**: Ensure fix works across hardware
4. **Document Differences**: Record hardware-specific issues

## Automated Testing

### Test Script Usage
```bash
# Run diagnostic script
./scripts/diagnose-recording.sh

# Test recording quality
./testing/test-recording.sh

# Benchmark performance
./testing/benchmark-quality.sh
```

### Test Script Features
- **Automated Recording**: Creates test recordings
- **Quality Analysis**: Analyzes recording quality
- **Performance Monitoring**: Tracks resource usage
- **Report Generation**: Creates test reports

## Test Results Documentation

### Recording Quality Metrics
- **Frame Rate**: Frames per second
- **Frame Drops**: Number of dropped frames
- **Stuttering**: Stuttering frequency
- **Overall Quality**: Subjective quality rating

### Performance Metrics
- **CPU Usage**: CPU utilization percentage
- **GPU Usage**: GPU utilization percentage
- **Memory Usage**: Memory consumption
- **Battery Drain**: Battery usage rate

### Compatibility Metrics
- **Game Compatibility**: Percentage of games working
- **SteamOS Compatibility**: Version compatibility
- **Hardware Compatibility**: Model compatibility
- **Overall Success Rate**: Overall fix effectiveness

## Test Case Documentation

### Standard Test Cases
1. **Basic Recording Test**: 15-second recording
2. **Extended Recording Test**: 5-minute recording
3. **Multiple Game Test**: Test across 10+ games
4. **Performance Test**: Resource usage measurement
5. **Compatibility Test**: Cross-version testing

### Edge Case Tests
1. **Low Battery Test**: Recording with low battery
2. **High Load Test**: Recording during high system load
3. **Network Test**: Recording during network activity
4. **Background Test**: Recording with background processes
5. **Sleep/Wake Test**: Recording after sleep/wake cycles

### Regression Tests
1. **Update Test**: Test after system updates
2. **Plugin Update Test**: Test after plugin updates
3. **Configuration Test**: Test after configuration changes
4. **Restart Test**: Test after system restarts
5. **Factory Reset Test**: Test after factory reset

## Community Testing

### Test Result Submission
1. **Run Tests**: Execute standard test cases
2. **Document Results**: Record all findings
3. **Submit Reports**: Share results with community
4. **Contribute Data**: Help improve solutions

### Test Result Analysis
1. **Aggregate Data**: Combine community results
2. **Identify Patterns**: Find common issues
3. **Improve Solutions**: Use data to improve fixes
4. **Update Documentation**: Update based on findings

## Quality Assurance

### Test Validation
1. **Verify Reproducibility**: Ensure tests are repeatable
2. **Check Accuracy**: Validate test measurements
3. **Review Results**: Analyze test outcomes
4. **Document Findings**: Record all observations

### Continuous Testing
1. **Regular Testing**: Run tests periodically
2. **Update Testing**: Update tests as needed
3. **Monitor Changes**: Watch for system changes
4. **Maintain Quality**: Ensure test quality

## Troubleshooting Test Issues

### Common Test Problems
1. **Recording Not Working**: Check Steam settings
2. **Quality Issues**: Verify recording settings
3. **Performance Problems**: Check system state
4. **Compatibility Issues**: Verify requirements

### Test Environment Issues
1. **System State**: Ensure clean system state
2. **Background Processes**: Check for interfering processes
3. **Resource Availability**: Ensure sufficient resources
4. **Configuration**: Verify test configuration

## Test Reporting

### Test Report Format
1. **Test Information**: Test details and environment
2. **Results**: Test outcomes and measurements
3. **Analysis**: Interpretation of results
4. **Recommendations**: Suggested actions

### Test Report Submission
1. **Format Reports**: Use standard format
2. **Include Data**: Provide all relevant data
3. **Submit Reports**: Share with community
4. **Follow Up**: Respond to feedback

---

**Last Updated**: October 17, 2025  
**Status**: Active Testing  
**Next Review**: As new test cases are developed
