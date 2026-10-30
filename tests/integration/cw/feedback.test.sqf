// FR-018..022: actual pointer preview, production phases, exact clicks and group drag.
triSimUntil { (count CWR_RTS)==20 }
triSimUntil { dialog }
triAssertEq [triGetCinemaBorder,false]
triAssertExcludes [triVisibleTexts,"ONLINE"]
triAssert [isObjectHidden player]
triScreenshot "first_rts_view"
triClick 7310
triSimFrames 2
triAssertEq [CWR_RTS select 0,2000]
triAssert [isNull (CWR_RTS select 2)]
triAssertEq [CWR_RTS select 7,0]
triAssertEq [count (CWR_RTS select 17),0]
_early=(call CWR_BuildCardState) select 0
_deadline=CWR_RTS select 3
triScreenshot "build_clock_start"
triClick 7310
triAssertEq [CWR_RTS select 3,_deadline]
triAssertEq [CWR_RTS select 0,2000]
_wait=time+5
triSimUntil { time>=_wait }
triAssert [isNull (CWR_RTS select 2)]
triAssertGt [(call CWR_BuildCardState) select 0,_early]
triScreenshot "build_clock_middle"
triSimUntil { CWR_RTS select 18 }
triAssert [isNull (CWR_RTS select 2)]
triSimFrames 2
_wait=time+2
triSimUntil { time>=_wait }
triAssertEq [triControlText 7330,"READY / PLACE"]
triScreenshot "build_ready"
triClick 7310
triCursorMove [0,0]
triSimFrames 6
triAssertEq [(CWR_RTS select 17) select 1,false]
triScreenshot "preview_red"
triMouseLeft 1
triSimFrames 2
triMouseLeft 0
triSimFrames 2
triAssertEq [CWR_RTS select 0,2000]
triAssert [isNull (CWR_RTS select 2)]
_site=[];
{_dx=_x; {_p=[6519.04+_dx,6473.68+_x,0]; if ((count _site)==0) then {if ((_p call CWR_SiteError)=="") then {_site=+_p}}} forEach [-60,-40,-20,20,40,60]} forEach [-60,-40,-20,20,40,60];
triAssertEq [count _site,3]
CWR_RTS set [12,[(_site select 0)-12,(_site select 1)-12,0]]
call CWR_UpdateCamera
triSimFrames 6
triAssert [(CWR_RTS select 17) select 1]
triAssertEq [CWR_RTS select 0,2000]
triScreenshot "preview_green"
triCursorMoveControl 7321
triSimFrames 4
triAssertEq [count (CWR_RTS select 17),0]
triScreenshot "preview_hidden_sidebar"
triCursorMove [0,0]
triSimFrames 4
triAssert [(CWR_RTS select 17) select 1]
triMouseRight 1
triSimFrames 2
triMouseRight 0
triSimFrames 3
triAssertEq [CWR_RTS select 7,0]
triAssertEq [count (CWR_RTS select 17),0]
triAssertEq [CWR_RTS select 0,2000]
triAssert [CWR_RTS select 18]
triClick 7310
triCursorMove [0,0]
triSimFrames 4
_previewPosition=+((CWR_RTS select 17) select 0)
triMouseLeft 1
triSimFrames 2
triMouseLeft 0
triSimFrames 3
triAssert [!(isNull (CWR_RTS select 2))]
triAssertLt [[getPos (CWR_RTS select 2),_previewPosition] call CWR_Distance,0.1]
triAssertEq [CWR_RTS select 0,2000]
triAssertEq [count (CWR_RTS select 17),0]
triAssertEq [CWR_RTS select 18,false]
triAssertEq [CWR_RTS select 3,-1]
triClick 7321
triSimFrames 5
triClick 7311
triClick 7311
triSimFrames 3
triAssertEq [CWR_RTS select 0,1800]
triScreenshot "train_clock_start"
_wait=time+3
triSimUntil { time>=_wait }
triScreenshot "train_clock_middle"
triSimUntil { (count (CWR_RTS select 5))==1 }
triAssertEq [count (CWR_RTS select 4),1]
triAssertLt [(call CWR_TrainCardState) select 0,0.3]
triScreenshot "train_clock_next_order"
triSimUntil { (count (CWR_RTS select 5))==2 }
_first=(CWR_RTS select 5) select 0
_second=(CWR_RTS select 5) select 1
triAssertEq [isObjectHidden _first,false]
triAssertEq [isObjectHidden _second,false]
_p=getPos _first
CWR_RTS set [12,[(_p select 0)-12,(_p select 1)-12,0]]
CWR_RTS set [13,35]
call CWR_UpdateCamera
triSimFrames 8
triCursorMove [0,0]
triMouseLeft 1
triSimFrames 2
triMouseLeft 0
triSimFrames 2
triAssert [(CWR_RTS select 6)==_first]
triAssertEq [count (CWR_RTS select 16),1]
triScreenshot "exact_unit_click_near"
CWR_RTS set [13,150]
call CWR_UpdateCamera
triSimFrames 8
triCursorMove [0,0]
triMouseLeft 1
triSimFrames 2
triMouseLeft 0
triSimFrames 2
triAssert [(CWR_RTS select 6)==_first]
triScreenshot "exact_unit_click_far"
triCursorMove [0.3,0.3]
triMouseLeft 1
triSimFrames 2
triCursorMove [-0.3,-0.3]
triSimFrames 4
triScreenshot "selection_rectangle"
triMouseLeft 0
triSimFrames 3
triAssertEq [count (CWR_RTS select 16),2]
triScreenshot "group_selected"
_beforeFirst=getPos _first
_beforeSecond=getPos _second
triCursorMove [-0.5,0.3]
triMouseLeft 1
triSimFrames 2
triMouseLeft 0
triSimFrames 2
triAssertEq [CWR_RTS select 9,"Move order issued"]
triSimUntil { (([getPos _first,_beforeFirst] call CWR_Distance)>3) && (([getPos _second,_beforeSecond] call CWR_Distance)>3) }
triScreenshot "group_movement"
_target=+(CWR_RTS select 15)
triCursorMoveControl 7320
triMouseLeft 1
triSimFrames 2
triMouseLeft 0
triSimFrames 3
triAssertEq [CWR_RTS select 15,_target]
triAssertEq [CWR_RTS select 0,1800]
// Inspect an actual developed base, using the same player camera and units.
_baseA=getPos (CWR_RTS select 1)
_baseB=getPos (CWR_RTS select 2)
CWR_RTS set [12,[((_baseA select 0)+(_baseB select 0))*0.5-12,((_baseA select 1)+(_baseB select 1))*0.5-12,0]]
CWR_RTS set [13,75]
call CWR_UpdateCamera
triSimFrames 12
triScreenshot "base_overview"
call CWR_Clear
triAssertEq [isObjectHidden player,false]
call CWR_Start
triAssert [isObjectHidden player]
triAssertEq [count (CWR_RTS select 16),0]
triAssertEq [count (CWR_RTS select 17),0]
triEndTest
