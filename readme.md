# T6 PAP Autosplit for BO2 Zombies

A LiveSplit autosplitter script designed for the *Buried Pack-a-Punch* speedrun category in Call of Duty: Black Ops 2 Zombies.

## Description
This script automatically starts and splits your timer when specific in-game events occur during the Buried Pack-a-Punch speedrun. It's specifically optimized for the paralyzer acquisition and upgrade process.

## Features
- **Automatic Start Detection** (with reset via fast reload)
- **Auto-split triggers**:
  - Paralyzer acquisition
  - Go in bank ***(optional)***
  - Power activation
  - Mansion entry
  - Paralyzer Pack-a-Punch completion

## Version Information
Two script versions are available:
- **Without Bank**: `/T6PP_monitor.gsc` and `/T6PP_Buried.asl`
- **With Bank**: `/with_bank/T6PP_monitor_bank.gsc` and `/with_bank/T6PP_Buried_bank.asl`

## Installation
1. Place the chosen script file in:
```
C:\Users%username%\AppData\Local\Plutonium\storage\t6\scripts\zm
```
2. In LiveSplit, add the `T6PP_buried.asl` script to your layout. Make sure you have chosen the version with or without bank, depending on what you want. 

## Credits
Original code adapted from [HuthT/T6-EE-LiveSplit](https://github.com/HuthTV/T6-EE-LiveSplit). Modified specifically for the Buried Pack-a-Punch category.

## Notes
- Requires Plutonium BO2 client
- Designed for Zombies mode only
- Tested on Buried map