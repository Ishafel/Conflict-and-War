// FR-013/SC-006: cursor/button state, normal UI hit testing (no direct control click).
triSimUntil { (count CWR_RTS)==20 }
call CWR_Build
triSimUntil { CWR_RTS select 18 }
triSimUntil { dialog }
_site=[];
{_dx=_x; {_p=[6519.04+_dx,6473.68+_x,0]; if ((count _site)==0) then {if ((_p call CWR_SiteError)=="") then {_site=+_p}}} forEach [-60,-40,-20,20,40,60]} forEach [-60,-40,-20,20,40,60];
triAssertEq [count _site,3]
_ok=_site call CWR_Place
triAssert [_ok]
triSimUntil { (CWR_RTS select 3)<0 }
call CWR_Train; call CWR_Train
triSimUntil { (count (CWR_RTS select 5))==2 }
_first=(CWR_RTS select 5) select 0
_second=(CWR_RTS select 5) select 1
// Put a known unit exactly on the camera's centre ray, without changing its position.
_p=getPos _first
CWR_RTS set [12,[(_p select 0)-12,(_p select 1)-12,0]]
call CWR_UpdateCamera
triSimFrames 10
triCursorMove [0,0]
triMouseLeft 1
triSimFrames 2
triMouseLeft 0
triSimFrames 2
triAssert [(CWR_RTS select 6)==_first]
triScreenshot "normal_dispatch_selection"
// Empty terrain reached by a second left click issues a move, including rapid clicks.
_before=getPos _first
triCursorMove [-0.5,0.3]
triMouseLeft 1
triSimFrames 2
triMouseLeft 0
triSimFrames 2
triAssertEq [count (CWR_RTS select 15),3]
triAssertEq [CWR_RTS select 9,"Move order issued"]
triSimUntil { ([getPos _first,_before] call CWR_Distance)>5 }
triScreenshot "left_click_movement"
// Another unit must be selectable through the same path.
_p=getPos _second
CWR_RTS set [12,[(_p select 0)-12,(_p select 1)-12,0]]
call CWR_UpdateCamera
triSimFrames 10
triCursorMove [0,0]
triMouseLeft 1
triSimFrames 2
triMouseLeft 0
triSimFrames 2
triAssert [(CWR_RTS select 6)==_second]
_target=+(CWR_RTS select 15)
triCursorMoveControl 7320
triMouseLeft 1
triSimFrames 2
triMouseLeft 0
triSimFrames 4
triAssertEq [CWR_RTS select 14,0]
triAssertEq [CWR_RTS select 15,_target]
triAssertEq [CWR_RTS select 0,1800]
triEndTest
