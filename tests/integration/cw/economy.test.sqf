// 006 FR-006/007/009/011: real driving, delivery, catalogue and native resource click.
triSimUntil { (count CWR_RTS)==27 }
triSimUntil { dialog }
triAssertEq [CWR_RTS select 0,3000]
triAssertEq [count (CWR_RTS select 24),1]
_h=(CWR_RTS select 24) select 0
_v=_h select 0
triAssert [alive _v]
triAssert [alive (_h select 1)]
triAssertEq [count (CWR_RTS select 5),0]
triAssertEq [count (CWR_RTS select 25),2]
triScreenshot "economy_initial"
triClick 7380
triAssertEq [CWR_RTS select 0,2400]
triAssertEq [CWR_RTS select 23,1]
triAssertEq [call CWR_Build,false]
triAssertEq [CWR_RTS select 23,1]
triAssertEq [CWR_RTS select 0,2400]
triSimUntil { CWR_RTS select 18 }
triClick 7380
triAssertEq [CWR_RTS select 7,1]
call CWR_Cancel
triAssert [CWR_RTS select 18]
triAssertEq [CWR_RTS select 0,2400]
triClick 7380
_site=[];
{_dx=_x; {_p=[6519.04+_dx,6473.68+_x,0]; if ((count _site)==0) then {if ((_p call CWR_SiteError)=="") then {_site=+_p}}} forEach [-60,-40,-20]} forEach [40,60,80];
triAssertEq [count _site,3]
// Preview and commit use the same Camp model through native world input.
CWR_RTS set [12,+_site]
call CWR_UpdateCamera
triCursorMove [0,0]
triSimFrames 5
triAssert [(CWR_RTS select 17) select 1]
triScreenshot "depot_preview"
triMouseLeft 1
triSimFrames 2
triMouseLeft 0
triSimFrames 3
triAssertEq [count (CWR_RTS select 22),1]
triAssertEq [CWR_RTS select 0,2400]
_depot=(CWR_RTS select 22) select 0
triAssert [alive _depot]
triAssertEq [CWR_RTS select 18,false]
triClick 7381
triAssert [(CWR_RTS select 6)==_v]
_node=((CWR_RTS select 25) select 0) select 1
CWR_RTS set [12,+_node]
call CWR_UpdateCamera
triSimFrames 5
_start=getPos _v
triCursorMove [0,0]
triMouseRight 1
triSimFrames 2
triMouseRight 0
triSimFrames 3
triAssertEq [_h select 3,1]
triSimUntil { ([getPos _v,_start] call CWR_Distance)>5 }
triSimUntil { (_h select 3)!=1 }
CWR_RTS set [12,getPos _v]
call CWR_UpdateCamera
triSimFrames 2
triScreenshot "arrival_diagnostic"
triAssertEq [format ["%1 / %2 / %3 / %4",_h select 3,getPos _v,_h select 6,_h select 9],format ["2 / %1 / %2 / Collecting supplies",getPos _v,_h select 6]]
triScreenshot "harvester_collecting"
triSimUntil { (_h select 3)==3 }
triAssertEq [_h select 2,100]
triAssertEq [CWR_RTS select 0,2400]
triScreenshot "harvester_returning_loaded"
triSimUntil { (_h select 3)!=3 }
CWR_RTS set [12,getPos _v]
call CWR_UpdateCamera
triSimFrames 2
triScreenshot "unload_arrival_diagnostic"
triAssertEq [format ["%1 / %2 / %3 / %4",_h select 3,getPos _v,_h select 6,_h select 9],format ["4 / %1 / %2 / Unloading",getPos _v,_h select 6]]
triSimUntil { (_h select 8)>0 }
triAssertEq [CWR_RTS select 0,2500]
triAssertEq [_h select 2,0]
triSimUntil { (_h select 8)>=300 }
triAssertEq [_h select 8,300]
triAssertEq [CWR_RTS select 0,2700]
_total=0
{_total=_total+(_x select 2)} forEach (CWR_RTS select 25)
triAssertEq [_total+(_h select 2)+(_h select 8),2400]
triScreenshot "three_deliveries"
// Explicit ordinary move stops automation and preserves cargo; native groups include vehicle.
triClick 7381
_cargo=_h select 2
call CWR_Move
triAssert [[6550,6425,0] call CWR_Click]
triAssertEq [_h select 3,0]
triAssertEq [_h select 2,_cargo]
triAssertEq [count (call CWR_HealthUnits),1]
triAssertIncludes [triControlText 7383,"CARGO"]
_oldNode=((CWR_RTS select 25) select 0) select 0
_oldDriver=_h select 1
call CWR_Start
triAssert [isNull _v]
triAssert [isNull _depot]
triAssert [isNull _oldNode]
triAssert [isNull _oldDriver]
triAssertEq [CWR_RTS select 0,3000]
triAssertEq [count (CWR_RTS select 22),0]
triAssertEq [((CWR_RTS select 24) select 0) select 2,0]
triEndTest
