# BattleRoyale3D

Original 3D Battle Royale mobile game prototype built with **Godot 4.3**.

## Features (Prototype)

- Third-person player controller with touch controls (virtual joystick + buttons)
- Shooting system with ammo and reload
- Health system and death
- AI Bots that wander, chase and shoot
- Collectible pickups (ammo / health)
- Shrinking safe zone that damages players outside
- HUD (health, ammo, alive count, zone radius)
- Win / Lose screen
- Mobile-optimized renderer settings
- Ready for GitHub Actions Android APK build

## How to play (on device after install)

- Left side of screen: Virtual joystick for movement
- Right side: Drag to look around
- Red button: Shoot
- Blue button: Jump
- Yellow button: Reload
- Green button: Sprint

## Building the APK

This repository is configured with GitHub Actions.

1. Push any change to the `main` branch (or run the workflow manually from the Actions tab).
2. Wait for the workflow **Build Android APK** to finish.
3. Download the artifact named `BattleRoyale3D-APK`.
4. Install the APK on your Android phone (enable "Install from unknown sources" if needed).

## Project Structure

```
BattleRoyale3D/
├── project.godot
├── export_presets.cfg
├── scenes/
│   ├── main.tscn
│   ├── player.tscn
│   ├── bot.tscn
│   ├── bullet.tscn
│   ├── pickup.tscn
│   └── safe_zone.tscn
├── scripts/
│   ├── main.gd
│   ├── player.gd
│   ├── bot.gd
│   ├── bullet.gd
│   ├── game_manager.gd
│   ├── safe_zone.gd
│   ├── touch_controls.gd
│   ├── ui.gd
│   └── pickup.gd
└── .github/workflows/android.yml
```

## Notes

- This is a functional prototype, not a finished commercial game.
- No external 3D assets are required (uses built-in PrimitiveMeshes).
- Multiplayer is not included in this version (local bots only).
- First GitHub Actions build may take 10–20 minutes.

Made for mobile-only development workflow.
