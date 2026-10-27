// FR-003/005/006/008, SC-002: exercise real mission callbacks and simulation.
triSimUntil { (count CWR_RTS) == 16 }
triAssertEq [CWR_RTS select 0,3000]
triAssert [alive (CWR_RTS select 1)]
_rejected=call CWR_Train
triAssertEq [_rejected,false]
triAssertEq [CWR_RTS select 0,3000]
call CWR_Build
triAssertEq [[7000,7000,0] call CWR_Click,false]
triAssertEq [CWR_RTS select 0,3000]
triAssertEq [[6519,6473,0] call CWR_Click,false]
call CWR_Cancel
triAssertEq [CWR_RTS select 0,3000]
call CWR_Build
_site=[];
{_dx=_x; { _candidate=[6519.04+_dx,6473.68+_x,0]; if ((count _site)==0) then {if ((_candidate call CWR_SiteError)=="") then {_site=+_candidate}} } forEach [-60,-40,-20,20,40,60]} forEach [-60,-40,-20,20,40,60];
triAssertEq [count _site,3]
_placed=_site call CWR_Click
triScreenshot "barracks_construction"
triAssertEq [format ["%1: %2",_placed,CWR_RTS select 9],"true: Barracks under construction"]
triAssertEq [CWR_RTS select 0,2000]
_duplicate=[6580,6473,0] call CWR_Place
triAssertEq [_duplicate,false]
triAssertEq [CWR_RTS select 0,2000]
_rejected=call CWR_Train
triAssertEq [_rejected,false]
triSimUntil { (CWR_RTS select 3)<0 }
_trained=call CWR_Train
triAssert [_trained]
_trained=call CWR_Train
triAssert [_trained]
triAssertEq [CWR_RTS select 0,1800]
triSimUntil { (count (CWR_RTS select 5))==2 }
triAssertEq [count (CWR_RTS select 4),0]
_unit=(CWR_RTS select 5) select 0
call CWR_Select
_selected=(getPos _unit) call CWR_Click
triAssert [_selected]
triAssert [(CWR_RTS select 6)==_unit]
_before=getPos _unit
call CWR_Move
_destination=[(_before select 0)+20,(_before select 1)+5,0]
_moved=_destination call CWR_Click
triAssert [_moved]
triScreenshot "infantry_move_order"
triSimUntil { ([getPos _unit,_before] call CWR_Distance)>5 }
// FIFO capacity: six clicks pay for only five orders.
call CWR_Train; call CWR_Train; call CWR_Train; call CWR_Train; call CWR_Train
_rejected=call CWR_Train
triAssertEq [_rejected,false]
triAssertEq [count (CWR_RTS select 4),5]
triAssertEq [CWR_RTS select 0,1300]
(CWR_RTS select 2) setDammage 1
triSimUntil { isNull (CWR_RTS select 2) }
triAssertEq [CWR_RTS select 0,1800]
triAssertEq [count (CWR_RTS select 4),0]
call CWR_Start
triAssertEq [CWR_RTS select 0,3000]
triAssertEq [count (CWR_RTS select 5),0]
triAssertEq [count (CWR_RTS select 4),0]
triEndTest
