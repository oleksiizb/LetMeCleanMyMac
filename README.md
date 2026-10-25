# LetMeCleanMyMac

Did you ever met a problem with wiping your screen/keybord/touchpad?
This Swift application is created exactly to solve this problem.
Just start it and your sceen will turn black with a message explaining how to exit.
Your keybord and touchpad will be disabled to there would be no other option to exit :)

[![Download for macOS](https://img.shields.io/badge/Download-macOS-blue?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/oleksiizb/LetMeCleanMyMac/releases/latest/download/LetMeCleanMyMac.zip)
![Latest release](https://img.shields.io/github/v/release/oleksiizb/LetMeCleanMyMac?style=for-the-badge)

## Installation

1. Download `LetMeCleanMyMac.zip` using the button above, or from the [Releases](https://github.com/oleksiizb/LetMeCleanMyMac/releases) page.
2. Unzip it and move `MyApp.app` to your **Applications** folder.
3. The app is not notarized, so macOS will block the first launch. Either:
   - System Settings → Privacy & Security → Open Anyway, or
   - Run this in Terminal:
     ```bash
     xattr -cr /Applications/LetMeCleanMyMac.app
     ```

## Permissions

The app needs two permissions to filter input system-wide. Grant both in **System Settings → Privacy & Security**:

- **Accessibility(Device Control and Data Access)**
- **Input Monitoring**

If the app doesn't appear in a list, click **+** and add it manually. After granting the permissions, relaunch the app once. If you update to a new version and the lock stops working, remove the old entry with **−** and add the app again.

## How to exit

| Method | Shortcut |
|---|---|
| Quit the app | `Cmd + Opt + Shift + Q` |
| Last resort | Hold the power button |

## Building from source

Requirements: macOS 27 or later, Xcode 15 or later.

```bash
git clone https://github.com/oleksiizb/LetMeCleanMyMac.git
cd REPO
open LetMeCleanMyMac.xcodeproj
```

In Xcode, open **Signing & Capabilities** and make sure **App Sandbox** is removed (event taps don't work in a sandboxed app), then press **Run**.
