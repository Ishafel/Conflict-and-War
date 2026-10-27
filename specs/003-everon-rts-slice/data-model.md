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

CWR_Config=[barracksPrice1000,buildSeconds15,infantryPrice100,trainSeconds5,baseRadius150,maxQueue5]. One scheduler tick.sqs invokes CWR_Tick every0.1s; button callbacks are synchronous. UI reads state and never calculates prices or debits.

Transitions: idle -> placement -> construction -> ready. Right-click cancels placement free. Ready -> training -> ready; one unit per deadline. Loss/deletion of barracks refunds pending training. Invalid commands return false and only update status. CWR_Clear releases camera, objects, groups, markers and player action; CWR_Start resets all session state. No persistence or multiplayer in this slice.

CWR_WorldClick receives native _pos=[X,Z,ATL], _button=0/1, _sea. Native control only projects/picks; script validates placement and applies orders. Camera input receives _panX/_panY seconds, _zoom wheel delta and _home bool; script clamps focus to worldSize and altitude. Direct doMove uses the existing engine command path.
