# First slice: Everon RTS

C&W is a modified fork, not an official Bohemia Interactive product. This slice uses external Everon terrain and base models from the local game installation; they are not shipped in this repository.

Build with `./build.cmd -Component Cpp`. Launch the main menu:

```powershell
./scripts/run-cw.ps1 -DataDir '<external Remastered directory>'
```

Choose **EVERON / ESTABLISH BASE**, or add `-Slice` to go directly to the mission. The launcher takes an explicit data directory and never modifies it. The executable and own content live under dist/x64-win-rwdi.

The main play area is actual 3D Everon. WASD/arrows move the camera, mouse wheel zooms, HQ/Home centers the base. The small map is only a minimap.

Click BUILD and the barracks card to pay1000 and start15s production. When READY, click the card again and choose an open site22–150m from HQ. Right-click cancels the cursor and keeps the paid READY order. Deployment is immediate, then choose INFANTRY and recruit a rifleman for100/5s. Up to5 orders queue sequentially. Left-click a soldier to select; then left-click empty terrain to move. Right-click also moves the selection. The starting3000 credits are finite in this sandbox. MENU ends the session and returns to the menu.

Original generated artwork and prompts: [ARTWORK.md](../content/cw/ui/ARTWORK.md). Requirements and tasks: [Spec Kit feature](../specs/003-everon-rts-slice/spec.md), [tasks](../specs/003-everon-rts-slice/tasks.md). Validation and remaining gaps: [verification](../specs/003-everon-rts-slice/verification.md).

Placement now has a translucent green/red model following the mouse: green accepts, red rejects. Right-click keeps the paid building READY. Drag the left mouse button over infantry to select a group and then click the ground to move it; individual clicks select the model on screen. Production portraits reveal clockwise with queue counts and completion feedback. CENTER HQ is a camera shortcut; the inactive HQ ONLINE production-grid placeholder was removed.

Next feature candidates (separate Spec Kit specifications): resource gathering/economy, terrain/slope previews, formation orders, opponents/combat/win conditions, more buildings and vehicles, fog of war, save/load and multiplayer. The first slice does not claim these systems.

The presentation pass uses original island key art, matching production portraits and a graphite/brass native interface. Camera starts at55m with a narrower0.58 FOV, scales pan speed with height, eases into motion and stops on key release. Wheel zoom settles smoothly; Home clears pending motion. Structures/infantry tabs show active feedback and compact production cards with preserved image proportions. Descriptions appear only while hovering a card, including locked/producing cards; there is no Base Command panel. The minimap follows the camera ground target during pan and Home reset. No empty future-unit placeholders or debug instruction strip are shown.
