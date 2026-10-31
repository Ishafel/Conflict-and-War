// 006 FR-002/011: native physical keys, repeat, dead members and session lifecycle.
triSimUntil { (count CWR_RTS)==27 }
triSimUntil { dialog }
_g=createGroup west
"SoldierWB" createUnit [[6535,6480,0],_g,"",0.6,"PRIVATE"]
_a=(units _g) select 0
"SoldierWB" createUnit [[6538,6480,0],_g,"",0.6,"PRIVATE"]
_b=(units _g) select 1
CWR_RTS set [5,[_a,_b]]
[_a,_b] call CWR_SetSelection
// Sidebar keeps focus; Ctrl+digits still reach the command viewport.
triClick 7321
{_n=_x; triKeyDown 224; triKeyDown _n; triSimFrames 2; triKeyUp _n; triKeyUp 224; triSimFrames 2} forEach [39,30,31,32,33,34,35,36,37,38]
{triAssertEq [count _x,2]} forEach (CWR_RTS select 20)
{_n=_x; [] call CWR_SetSelection; triKeyDown _n; triSimFrames 2; triKeyUp _n; triSimFrames 2; triAssertEq [CWR_RTS select 16,[_a,_b]]} forEach [39,30,31,32,33,34,35,36,37,38]
[] call CWR_SetSelection
triKeyDown 32
triSimFrames 2
triKeyUp 32
triSimFrames 2
triAssertEq [CWR_RTS select 16,[_a,_b]]
[_a] call CWR_SetSelection
triKeyDown 224
triKeyDown 32
triSimFrames 2
[_b] call CWR_SetSelection
triKeyRepeat 32
triSimFrames 2
triKeyUp 32
triKeyUp 224
triSimFrames 2
triAssertEq [(CWR_RTS select 20) select 3,[_a]]
// Empty assignment retains existing membership.
[] call CWR_SetSelection
triKeyDown 224
triKeyDown 32
triSimFrames 2
triKeyUp 32
triKeyUp 224
triSimFrames 2
triAssertEq [(CWR_RTS select 20) select 3,[_a]]
_a setDamage 1
triSimFrames 12
triAssertEq [count ((CWR_RTS select 20) select 3),0]
[_b] call CWR_SetSelection
triKeyDown 32
triSimFrames 2
triKeyUp 32
triSimFrames 2
triAssertEq [CWR_RTS select 16,[_b]]
// Released modifier must not turn plain digit into assignment.
triKeyDown 31
triSimFrames 2
triKeyUp 31
triSimFrames 2
triAssertEq [(CWR_RTS select 20) select 2,[_b]]
// Reopening the dialog clears held input; a released Ctrl cannot stick.
triKeyDown 224
triSimFrames 2
closeDialog 0
call CWR_Command
[_b] call CWR_SetSelection
triKeyDown 30
triSimFrames 2
triKeyUp 30
triKeyUp 224
triSimFrames 2
triAssertEq [(CWR_RTS select 20) select 1,[_b]]
call CWR_Start
triAssertEq [count (CWR_RTS select 20),10]
{triAssertEq [count _x,0]} forEach (CWR_RTS select 20)
triAssertEq [count (CWR_RTS select 21),0]
triEndTest
