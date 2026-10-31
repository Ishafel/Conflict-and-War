// FR-009/010 and SC-005: real viewport input, minimap isolation and 3D production.
triSimUntil { (count CWR_RTS)==20 }
triSimUntil { dialog }
triAssertEq [triGetCinemaBorder,false]
triAssert [(triGetControlVisible 7301)]
triAssert [(triGetControlVisible 7304)]
triAssertEq [(triControlText 7310),""]
triAssertEq [(triControlText 7302),"3000"]
triScreenshot "world_and_sidebar"
_focus=+(CWR_RTS select 12)
triKeyDown 7
triSimFrames 25
triKeyUp 7
triSimFrames 2
triAssertGt [((CWR_RTS select 12) select 0)-(_focus select 0),0.2]
triClick 7315
triSimFrames 5
triClick 7310
triSimUntil { CWR_RTS select 18 }
triClick 7310
triAssertEq [CWR_RTS select 7,1]
triClickAt [7304,0.5,0.5]
triAssertEq [CWR_RTS select 7,1]
triAssertEq [CWR_RTS select 0,2000]
triClickAt [7301,0.5,0.5,1]
triAssertEq [CWR_RTS select 7,0]
triAssertEq [CWR_RTS select 0,2000]
// Validate a world site before aiming: a fixed screen grid can miss every
// clearing when the platform changes the drawable aspect. Placement still
// goes through the native viewport click and must agree with its model preview.
_site=[];
{_dx=_x; {_p=[6519.04+_dx,6473.68+_x,0]; if ((count _site)==0) then {if ((_p call CWR_SiteError)=="") then {_site=+_p}}} forEach [-60,-40,-20,20,40,60]} forEach [-60,-40,-20,20,40,60];
triAssertEq [count _site,3]
CWR_RTS set [12,[(_site select 0)-12,(_site select 1)-12,0]]
call CWR_UpdateCamera
triSimFrames 6
triClick 7310
triCursorMove [0,0]
triSimFrames 6
triAssertEq [count (CWR_RTS select 17),2]
triAssert [(CWR_RTS select 17) select 1]
_expected=+((CWR_RTS select 17) select 0)
triClickAt [7301,0.6578947,0.5]
triAssert [!(isNull (CWR_RTS select 2))]
triAssertLt [[getPos (CWR_RTS select 2),_expected] call CWR_Distance,0.1]
triAssertEq [CWR_RTS select 0,2000]
triSimFrames 10
triScreenshot "world_construction"
triSimUntil { (CWR_RTS select 3)<0 }
triClick 7321
triSimFrames 10
triAssert [(triGetControlVisible 7311)]
triClick 7311
triClick 7311
triAssertEq [CWR_RTS select 0,1800]
triSimUntil { (count (CWR_RTS select 5))==2 }
_unit=(CWR_RTS select 5) select 0
_p=getPos _unit
CWR_RTS set [12,[(_p select 0)-12,(_p select 1)-12,0]]
call CWR_UpdateCamera
triSimFrames 15
triClickAt [7301,0.6578947,0.5]
triAssert [(CWR_RTS select 6)==_unit]
triScreenshot "selected_infantry"
_before=getPos (CWR_RTS select 6)
triClickAt [7301,0.3,0.65,1]
triAssertEq [count (CWR_RTS select 15),3]
triSimUntil { ([getPos (CWR_RTS select 6),_before] call CWR_Distance)>5 }
triScreenshot "infantry_moved"
triEndTest
