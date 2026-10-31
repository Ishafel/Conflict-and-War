// FR-009: native keyboard and wheel events, while sidebar owns focus.
triSimUntil { (count CWR_RTS)==27 }
triSimUntil { dialog }
triAssertEq [triGetCinemaBorder,false]
_map=ctrlMapGetCenter 7304
triAssertEq [count _map,3]
triAssertLt [[_map,call CWR_CameraTarget] call CWR_Distance,0.1]
_mapBefore=+_map
triScreenshot "minimap_initial"
triClick 7321
_focus=+(CWR_RTS select 12)
triKeyDown 7
triSimFrames 25
triKeyUp 7
triSimFrames 2
triAssertGt [((CWR_RTS select 12) select 0)-(_focus select 0),0.2]
_map=ctrlMapGetCenter 7304
triAssertLt [[_map,call CWR_CameraTarget] call CWR_Distance,0.1]
triAssertGt [[_map,_mapBefore] call CWR_Distance,0.2]
triScreenshot "minimap_after_pan"
_after=+(CWR_RTS select 12)
triSimFrames 10
triAssertEq [((CWR_RTS select 12) select 0),_after select 0]
_alt=CWR_RTS select 13
triCursorMoveControl 7301
triSimFrames 5
triCursorScroll 1
triSimFrames 5
triAssertLt [CWR_RTS select 13,_alt]
triKeyDown 74
triSimFrames 2
triKeyUp 74
triSimFrames 5
triAssertEq [((CWR_RTS select 12) select 0),((getPos (CWR_RTS select 1)) select 0)]
triAssertEq [CWR_RTS select 13,55]
triAssertLt [[ctrlMapGetCenter 7304,call CWR_CameraTarget] call CWR_Distance,0.1]
triScreenshot "minimap_home"
// Home must clear the remaining smooth wheel impulse and stay still.
triSimFrames 15
triAssertEq [CWR_RTS select 13,55]
triCursorMoveControl 7301
triCursorScroll 4
triSimFrames 2
triKeyDown 74
triSimFrames 2
triKeyUp 74
triSimFrames 15
triAssertEq [CWR_RTS select 13,55]
// Minimum zoom is half the old altitude, and remains clamped.
triCursorMoveControl 7301
triCursorScroll 100
triSimFrames 30
triAssertEq [CWR_RTS select 13,15]
triScreenshot "camera_closest"
triCursorScroll -100
triSimFrames 30
triAssertEq [CWR_RTS select 13,150]
triScreenshot "camera_farthest"
// Compare actual model height with the previous closest camera, same unit/window.
_g=createGroup west
"SoldierWB" createUnit [[6535,6480,0],_g,"",0.6,"PRIVATE"]
_u=(units _g) select 0
_u disableAI "MOVE"
CWR_RTS set [5,[_u]]
_p=getPos _u
_cam=CWR_RTS select 8
_cam camSetTarget _p
_cam camSetPos [(_p select 0)-12,(_p select 1)-12-30*0.85,30]
_cam camCommit 0
triSimFrames 5
_oldRect=triGetRTSUnitRect [7301,_u]
triAssertEq [count _oldRect,4]
_oldHeight=(_oldRect select 3)-(_oldRect select 1)-12
triAssertGt [_oldHeight,0]
triScreenshot "camera_previous_closest_reference"
CWR_RTS set [12,+_p]
CWR_RTS set [13,15]
call CWR_UpdateCamera
triSimFrames 5
_newRect=triGetRTSUnitRect [7301,_u]
triAssertEq [count _newRect,4]
_newHeight=(_newRect select 3)-(_newRect select 1)-12
triAssertGt [_newHeight/_oldHeight,1.5]
triScreenshot "camera_new_closest_unit"
triEndTest
