// FR-007: actual UI, native manual driving and explicit COLLECT at target resolution.
triSimUntil { (count CWR_RTS)==27 }
triSimUntil { dialog }
triAssertNear [(triGetControlRect 7371) select 2,0.2,0.0001]
triClick 7381
_h=(CWR_RTS select 24) select 0
_v=_h select 0
triAssert [(CWR_RTS select 6)==_v]
triSimFrames 8
triAssertIncludes [triControlText 7383,"CARGO 0/100"]
_start=getPos _v
call CWR_Move
triAssert [[6500,6425,0] call CWR_Click]
triSimUntil { ([getPos _v,_start] call CWR_Distance)>5 }
triAssertEq [_h select 3,0]
triAssertEq [CWR_RTS select 0,3000]
CWR_RTS set [12,getPos _v]
call CWR_UpdateCamera
triSimFrames 4
triScreenshot "harvester_manual_move"
triClick 7382
triAssertEq [_h select 3,1]
triSimFrames 8
triAssertIncludes [triControlText 7383,"Driving to supplies"]
CWR_RTS set [12,((CWR_RTS select 25) select 0) select 1]
call CWR_UpdateCamera
triSimFrames 4
triScreenshot "resource_and_cargo"
triCursorMoveControl 7380
triSimFrames 12
triAssert [triGetControlVisible 7363]
triAssertIncludes [triControlText 7363,"Receives harvester cargo"]
triScreenshot "depot_tooltip"
triClick 7380
triAssertEq [CWR_RTS select 0,2400]
triSimUntil { CWR_RTS select 18 }
triAssertEq [triControlText 7384,"READY / PLACE"]
triScreenshot "depot_ready"
triEndTest
