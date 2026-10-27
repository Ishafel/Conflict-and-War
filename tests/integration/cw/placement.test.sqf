// FR-011/SC-006: rotated building edges outside the old 12m origin test.
triSimUntil { (count CWR_RTS)==16 }
_site=[];
{_dx=_x; {_p=[6519.04+_dx,6473.68+_x,0]; if ((count _site)==0) then {
    if (isNull (NearestObjectDistance [_p,"",12])) then {if ((_p call CWR_SiteError)=="") then {_site=+_p}};
}} forEach [-100,-80,-60,-40,-20,20,40,60,80,100]} forEach [-100,-80,-60,-40,-20,20,40,60,80,100];
triAssertEq [count _site,3]
triSimFrames 2
_balance=CWR_RTS select 0
_obstacle="Barracks" camCreate [(_site select 0)+13,(_site select 1),0]
_obstacle setDir 45
triAssert [!(isNull _obstacle)]
triAssert [isNull (NearestObjectDistance [_site,"",12])]
_reason=_site call CWR_SiteError
triAssertIncludes [_reason,"Site obstructed"]
_accepted=_site call CWR_Place
triAssertEq [_accepted,false]
triAssertEq [CWR_RTS select 0,_balance]
triAssert [isNull (CWR_RTS select 2)]
triScreenshot "rotated_building_rejected"
deleteVehicle _obstacle
triAssertEq [_site call CWR_SiteError,""]
// Missing candidate geometry must fail closed instead of approving placement.
_logic="Logic" camCreate _site
triAssertEq [objectPlacementClear _logic,false]
deleteVehicle _logic
_accepted=_site call CWR_Place
triAssert [_accepted]
triAssertEq [CWR_RTS select 0,2000]
triEndTest
