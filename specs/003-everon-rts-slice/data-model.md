# Data model

CWR_RTS is the explicit mission-owned state array initialized by CWR_Start:

| Index | Field | Contract |
|---|---|---|
| 0 | credits | starts3000; debit only after accepted command |
| 1 | HQ | external base class MASH |
| 2 | barracks | null until placement; external class Barracks |
| 3 | buildDeadline | mission seconds, -1 means ready |
| 4 | training FIFO | paid per-order completion deadlines, max5 |
| 5 | soldiers | owned SoldierWB objects, separate AI group each |
| 6 | selected | owned live soldier or null |
| 7 | command mode | 0 default select,1 place,2 select,3 move |
| 8 | camera | mission-owned camera object |
| 9 | status | last command outcome |
| 10 | running | scheduler lifetime flag |
| 11 | action ID | removed during cleanup |
| 12 | focus | camera ground focus [X,Z,ATL] |
| 13 | altitude | zoom in [30,200]m |
| 14 | category | 0 buildings,1 infantry |
| 15 | move target | last accepted destination, observable for testing |
| 16 | selected group | owned live objects selected by click/rectangle; [6] is the primary member |
| 17 | preview feedback | [] when hidden, otherwise [actual candidate position,valid] |

CWR_Config=[barracksPrice1000,buildSeconds15,infantryPrice100,trainSeconds5,baseRadius150,maxQueue5]. One scheduler tick.sqs invokes CWR_Tick every0.1s; button callbacks are synchronous. UI reads state and never calculates prices or debits.

Transitions: idle -> placement -> construction -> ready. Right-click cancels placement free. Ready -> training -> ready; one unit per deadline. Loss/deletion of barracks refunds pending training. Invalid commands return false and only update status. CWR_Clear releases camera, objects, groups, markers and player action; CWR_Start resets all session state. No persistence or multiplayer in this slice.

CWR_WorldClick receives native _pos=[X,Z,ATL], _button=0/1, _sea. Native control only projects/picks; script validates placement and applies orders. Camera input receives _panX/_panY seconds, _zoom wheel delta and _home bool; script clamps focus to worldSize and altitude. Direct doMove uses the existing engine command path.

The state has 18 fields. Native world clicks also supply _unit from projected model bounds; rectangle completion supplies _units. CWR_SetSelection filters owned/live membership and sets the group and primary together; movement uses one destination with 3 m spacing per selected unit. Legacy direct CWR_Click still supports ground-coordinate command tests.

Preview candidate and ObjectColored ghost are viewport-owned refs, never inserted into the simulation. Candidate PlaceOnSurface matches the committed building's setPos/land-contact transform; [17] records the model origin rather than raw cursor terrain coordinates. Render-list refs expire after the frame and viewport refs release when placement ends. A pure common validator handles preview and commit; drawing does not debit credits.

BuildCardState and TrainCardState expose [fraction,queueCount,ready] derived from the same production deadlines. Native card overlays own only visual flash timing. They cannot change orders, credits or completion deadlines.
