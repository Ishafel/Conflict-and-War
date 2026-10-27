# First slice: Everon RTS

C&W is a modified fork, not an official Bohemia Interactive product. This slice uses external Everon terrain and base models from the local game installation; they are not shipped in this repository.

Build with `./build.cmd -Component Cpp`. Launch the main menu:

```powershell
./scripts/run-cw.ps1 -DataDir '<external Remastered directory>'
```

Choose **EVERON / ESTABLISH BASE**, or add `-Slice` to go directly to the mission. The launcher takes an explicit data directory and never modifies it. The executable and own content live under dist/x64-win-rwdi.

The main play area is actual 3D Everon. WASD/arrows move the camera, mouse wheel zooms, HQ/Home centers the base. The small map is only a minimap.

Click BUILD and the barracks card, then an open site22–150m from HQ. Right-click cancels placement free. Construction costs1000 and takes15s. Once ready, choose INFANTRY and recruit a rifleman for100/5s. Up to5 orders queue sequentially. Left-click a soldier to select; then left-click empty terrain to move. Right-click also moves the selection. The starting3000 credits are finite in this sandbox. MENU ends the session and returns to the menu.

Original generated artwork and prompts: [ARTWORK.md](../content/cw/ui/ARTWORK.md). Requirements and tasks: [Spec Kit feature](../specs/003-everon-rts-slice/spec.md), [tasks](../specs/003-everon-rts-slice/tasks.md). Validation and remaining gaps: [verification](../specs/003-everon-rts-slice/verification.md).

Next feature candidates (separate Spec Kit specifications): resource gathering/economy, building ghosts and terrain/slope previews, box selection and formation orders, opponents/combat/win conditions, more buildings and vehicles, fog of war, save/load and multiplayer. The first slice does not claim these systems.
