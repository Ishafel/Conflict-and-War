// 006 FR-006/007/011: boundary-state fixtures, authoritative tick; no artificial credits.
triSimUntil { (count CWR_RTS)==27 }
_h=(CWR_RTS select 24) select 0
_v=_h select 0
_nodes=CWR_RTS select 25
_node=_nodes select 0
// Two collectors contend for only 30 remaining resources; sequential tick conserves quantity.
_h2=[6540,6425,0] call CWR_SpawnHarvester
triAssertEq [count _h2,11]
_node set [2,30]
{_x set [2,0]; _x set [3,2]; _x set [4,0]; _x set [5,time-1]; _x set [6,getPos (_x select 0)]} forEach [_h,_h2]
CWR_RTS set [26,time-1]
call CWR_EconomyTick
triAssertEq [(_h select 2)+(_h2 select 2),30]
triAssertEq [_node select 2,0]
triAssertEq [CWR_RTS select 0,3000]
// Identical gameplay time cannot double collect or unload (also applies while paused).
_cargo=_h select 2
call CWR_EconomyTick
triAssertEq [_h select 2,_cargo]
// Depleted node chooses the next non-empty node.
_h set [3,0]
triAssert [[_h,0] call CWR_Gather]
triAssertEq [_h select 4,1]
// A full vehicle with no depot waits with its cargo.
_h set [2,100]
[_h,1] call CWR_Gather
triAssertEq [_h select 3,5]
triAssertEq [_h select 2,100]
// A real depot becoming available resumes return; losing it retains cargo.
_d="Camp" createVehicle [6560,6425,0]
CWR_RTS set [22,[_d]]
CWR_RTS set [26,time-1]
call CWR_EconomyTick
triAssertEq [_h select 3,3]
triAssertEq [_h select 10,_d]
_h set [3,4]
_h set [5,time-1]
_d setDamage 1
CWR_RTS set [26,time-1]
call CWR_EconomyTick
triAssertEq [_h select 3,5]
triAssertEq [_h select 2,100]
triAssertEq [CWR_RTS select 0,3000]
// Bounded path deadline, with a real driver deliberately stopped for this fixture.
_h set [2,25]
[_h,1] call CWR_Gather
(_h select 1) disableAI "MOVE"
_h set [5,time-1]
CWR_RTS set [26,time-1]
call CWR_EconomyTick
triAssertEq [_h select 3,0]
triAssertEq [_h select 2,25]
triAssertIncludes [_h select 9,"Path"]
// An expired unloading deadline credits the real cargo once, including duplicate ticks.
_d2="Camp" createVehicle [6560,6425,0]
CWR_RTS set [22,[_d2]]
_h2 set [3,0]
_h set [2,100]
_h set [3,4]
_h set [10,_d2]
_h set [5,time-1]
CWR_RTS set [26,time-1]
call CWR_EconomyTick
triAssertEq [_h select 2,0]
triAssertEq [_h select 8,100]
triAssertEq [CWR_RTS select 0,3100]
call CWR_EconomyTick
triAssertEq [CWR_RTS select 0,3100]
triAssertEq [_h select 8,100]
_h set [2,25]
// Destruction loses the actual held cargo without crediting it.
_v setDamage 1
CWR_RTS set [26,time-1]
call CWR_EconomyTick
triAssertEq [_h select 2,0]
triAssertEq [CWR_RTS select 0,3100]
// No remaining node => idle, no repeated movement orders.
{_x set [2,0]} forEach _nodes
_h2 set [2,0]
triAssertEq [[_h2,0] call CWR_Gather,false]
triAssertEq [_h2 select 3,0]
{deleteVehicle _x} forEach (CWR_RTS select 22)
CWR_RTS set [22,[]]
// The shared construction producer refunds unfinished orders exactly once.
triAssert [1 call CWR_OrderBuilding]
triAssertEq [CWR_RTS select 0,2500]
(CWR_RTS select 1) setDamage 1
call CWR_Tick
triAssertEq [CWR_RTS select 0,3100]
call CWR_Tick
triAssertEq [CWR_RTS select 0,3100]
triAssertEq [CWR_RTS select 3,-1]
triEndTest
