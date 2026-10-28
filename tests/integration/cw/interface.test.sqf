// FR-009/010 and SC-005: real viewport input, minimap isolation and 3D production.
triSimUntil { (count CWR_RTS)==18 }
triSimUntil { dialog }
triAssert [(triGetControlVisible 7301)]
triAssert [(triGetControlVisible 7304)]
triAssertEq [(triControlText 7310),""]
triAssertEq [(triControlText 7302),"CREDITS 3000"]
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
triAssertEq [CWR_RTS select 7,1]
triClickAt [7304,0.5,0.5]
triAssertEq [CWR_RTS select 7,1]
triAssertEq [CWR_RTS select 0,3000]
triClickAt [7301,0.5,0.5,1]
triAssertEq [CWR_RTS select 7,0]
triAssertEq [CWR_RTS select 0,3000]
// Search visible open terrain through actual native world clicks, not script placement.
triClick 7310
_clicked=false;
{_u=_x; {if (!_clicked) then {triClickAt [7301,_u,_x]; if (!(isNull (CWR_RTS select 2))) then {_clicked=true}}} forEach [0.35,0.45,0.55,0.65,0.75]} forEach [0.2,0.35,0.5,0.65,0.8,0.9];
triAssert [_clicked]
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
