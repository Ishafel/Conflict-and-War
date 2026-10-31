# Data model

CWR_RTS is the explicit mission-owned state array initialized by CWR_Start:

| Index | Field | Contract |
|---|---|---|
| 0 | credits | starts3000; debit only after accepted command |
| 1 | HQ | external base class MASH |
| 2 | barracks | null until placement; external class Barracks |
| 3 | buildDeadline | mission seconds, -1 means no active production |
| 4 | training FIFO | paid per-order completion deadlines, max5 |
| 5 | soldiers | owned SoldierWB objects, separate AI group each |
| 6 | selected | owned live soldier or null |
| 7 | command mode | 0 default select,1 place,2 select,3 move |
| 8 | camera | mission-owned camera object |
| 9 | status | last command outcome |
| 10 | running | scheduler lifetime flag |
| 11 | action ID | removed during cleanup |
| 12 | focus | camera ground focus [X,Z,ATL] |
| 13 | altitude | zoom in [30,150]m, starts55 |
| 14 | category | 0 buildings,1 infantry |
| 15 | move target | last accepted destination, observable for testing |
| 16 | selected group | owned live objects selected by click/rectangle; [6] is the primary member |
| 17 | preview feedback | [] when hidden, otherwise [actual candidate position,valid] |
| 18 | building ready | paid production complete, awaiting deployment |
| 19 | camera reset epoch | increments on Home; native viewport clears smoothing before consuming more input |

CWR_Config=[barracksPrice1000,buildSeconds15,infantryPrice100,trainSeconds5,baseRadius150,maxQueue5]. One scheduler tick.sqs invokes CWR_Tick every0.1s; button callbacks are synchronous. UI reads state and never calculates prices or debits.

Transitions: idle -> producing -> READY -> placement -> deployed. Right-click returns to READY with no additional debit. Deployed -> training -> deployed; one unit per deadline. Loss/deletion of barracks refunds pending training. Invalid commands return false and only update status. CWR_Clear releases camera, objects, groups, markers and player action; CWR_Start resets all session state. No persistence or multiplayer in this slice.

CWR_WorldClick receives native _pos=[X,Z,ATL], _button=0/1, _sea. Native control only projects/picks; script validates placement and applies orders. Camera input receives _panX/_panY seconds, _zoom wheel delta and _home bool; script clamps focus to worldSize and altitude. Direct doMove uses the existing engine command path.

The state has 20 fields. Native world clicks also supply _unit from projected model bounds; rectangle completion supplies _units. CWR_SetSelection filters owned/live membership and sets the group and primary together; movement uses one destination with 3 m spacing per selected unit. Legacy direct CWR_Click still supports ground-coordinate command tests.

Preview candidate and ObjectColored ghost are viewport-owned refs, never inserted into the simulation. Candidate PlaceOnSurface matches the committed building's setPos/land-contact transform; [17] records the model origin rather than raw cursor terrain coordinates. Render-list refs expire after the frame and viewport refs release when placement ends. A pure common validator handles preview and commit; drawing does not debit credits.

BuildCardState and TrainCardState expose [fraction,queueCount,ready] derived from the same production deadlines. Native card overlays own only visual flash timing. They cannot change orders, credits or completion deadlines.

## Revised barracks order (FR-023)
State[18] is a paid-ready bool; state[3]>=0 means producing, -1 means no active production. Idle: null barracks, deadline=-1, ready=false. Producing: null barracks, deadline>=0, ready=false. Ready/preview: null barracks, deadline=-1, ready=true. Deployed: live barracks, deadline=-1, ready=false. Only idle→producing debits; cancel preview retains ready, failed spawn retains ready. Loss returns to idle and refunds pending infantry only.

Presentation pass FR-029–032 keeps economic/selection state and20-field contract. Context copy is derived from category, order deadline, READY, barracks and selected-owned units; no UI-owned price/timer logic. Camera smoothing, if adopted, is per viewport and cleared on focus loss/dialog lifecycle.

CWR_CameraConfig=[initialAltitude55,FOV0.58,minAltitude30,maxAltitude150,panSpeedPerAltitude0.65]. Wheel adjusts altitude proportionally; native smoothing integrates input over time. Home resets epoch[19] and desired view synchronously.

FR-033–035 retain20-field state. Tooltip visibility is derived from visible card hover and current category, with no stored hover flag. Minimap world center is the camera ground target focus+[12,12], while map zoom retains its map scale.
