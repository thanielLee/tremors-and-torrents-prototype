# Tremors and Torrents

### A Virtual Reality Game on Disaster and Risk Management in the Context of the Philippines

---

**Ateneo de Manila University**  
**Department:** Ateneo Laboratory for the Learning Sciences (ALLS)  
**Developers:** Marco Emmanuel C. Gimena · Johnver Christian B. Laviña · Thaniel C. Lee  
**Adviser:** Eric Cesar E. Vidal, Jr., Ph.D.

## System Requirements

| Component  | Requirement                                                           |
| ---------- | --------------------------------------------------------------------- |
| OS         | Windows 10 / 11 (64-bit)                                              |
| GPU        | NVIDIA GTX 1070 / AMD RX 5700 or better (VR-capable)                  |
| RAM        | 8 GB minimum, 16 GB recommended                                       |
| Storage    | ~600 MB                                                               |
| VR Headset | Any SteamVR-compatible headset (tested on Meta Quest 3 via QuestLink) |
| Software   | Steam + SteamVR installed                                             |

---

## First-Time Setup (Windows)

If Windows prevents the game from running or displays an **"Unknown Publisher"** warning, complete the following steps before launching the game:

1. Right-click `TremorsAndTorrents.exe` and select **Properties**.
2. If you see a security message at the bottom of the **General** tab stating that the file came from another computer, check **Unblock**.
3. Click **Apply**, then **OK**.

> This only needs to be done once on each PC.

### Running the Game

> **Important:** SteamVR must be running before launching the game.

1. Connect the VR headset to the PC (Quest Link, Air Link, or another supported PC VR connection).
2. Launch **SteamVR** and verify that the headset is detected.
3. If SteamVR has not yet been configured as the default OpenXR runtime:
   - Open **SteamVR → Settings → Developer**
   - Click **Set SteamVR as OpenXR Runtime**
4. Open the game folder and double-click `TremorsAndTorrents.exe`.
5. The game will automatically launch inside the headset.

---

## Controls

| Action                    | Controller Input                              |
| ------------------------- | --------------------------------------------- |
| Move                      | Left thumbstick                               |
| Turn                      | Right thumbstick                              |
| Grab / Interact           | Grip button (either hand)                     |
| Trigger actions           | Right trigger                                 |
| Bandaging (twist gesture) | Rotate right controller                       |
| Duck Cover Hold           | Physically crouch + bring controllers to head |
| Advance dialogue          | Right trigger                                 |
| Exit level                | Hold both triggers simultaneously             |

---

## Building from Source

### Prerequisites

1. **Godot 4.4.1** (standard version, not .NET/Mono)
   - Download from: https://godotengine.org/download
   - Use the exact version (4.4.1) to avoid compatibility issues.

2. **Export Templates for Godot 4.4.1**
   - In the Godot editor: **Editor → Manage Export Templates → Download**
   - Select version 4.4.1 and download the Windows templates.

3. **Git** (to clone the repository)

### Setup Steps

```bash
# 1. Clone the repository
git clone https://github.com/thanielLee/tremors-and-torrents-prototype.git
cd tremors-and-torrents-prototype

# 2. Open in Godot
# Launch Godot 4.4.1, click "Import", navigate to the project folder,
# and select project.godot
```

4. Once the project is open in the editor, let it **reimport all assets** on first load (this may take a few minutes).

5. Verify addons are enabled:
   - Go to **Project → Project Settings → Plugins**
   - Confirm **GodotXRTools** and **AVES** are both enabled (checkmark on)

### Exporting a Windows Build

1. In the Godot editor, go to **Project → Export**

2. If no export preset exists, click **Add** and select **Windows Desktop**

3. Configure the export preset:
   - Architecture: **x86_64**
   - Export Path: `build/TremorsAndTorrents.exe`

4. Click **Export Project**.

### Running in Editor (without exporting)

1. Make sure SteamVR is running and your headset is connected.
2. Open the project in Godot 4.4.1.
3. Press **F5** or click the **Play** button.
4. The game will launch into your headset via OpenXR.

---

## Known Issues

- SteamVR must be running before launching the game.
- If Windows SmartScreen appears, click **More info** → **Run anyway**.
- If the game opens on the monitor instead of the headset, close the game, verify that SteamVR detects the headset, then relaunch.
- If controller tracking is lost, restart SteamVR and relaunch the game.

---

## Contact

For questions regarding the project, please contact the development team through the Ateneo Laboratory for the Learning Sciences (ALLS), Ateneo de Manila University.
