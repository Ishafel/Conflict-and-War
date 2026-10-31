// FR-013: left selects, right commands; use normal viewport input dispatch.
triSimUntil { (count CWR_RTS)==27 }
triSimUntil { dialog }
triClick 7381
_h=(CWR_RTS select 24) select 0
_v=_h select 0
triAssert [(CWR_RTS select 6)==_v]
_target=+(CWR_RTS select 15)
_feedback=+(CWR_RTS select 21)
triCursorMove [-0.5,0.3]
triMouseLeft 1
triSimFrames 2
triMouseLeft 0
triSimFrames 2
triAssertEq [CWR_RTS select 15,_target]
triAssertEq [CWR_RTS select 21,_feedback]
triAssertEq [count (CWR_RTS select 16),0]
// Two rapid left clicks on ground cannot command movement either.
triClick 7381
triCursorMove [-0.5,0.3]
triMouseLeft 1
triSimFrames 1
triMouseLeft 0
triSimFrames 1
triMouseLeft 1
triSimFrames 1
triMouseLeft 0
triSimFrames 2
triAssertEq [CWR_RTS select 15,_target]
triAssertEq [CWR_RTS select 21,_feedback]
triClick 7381
triCursorMove [-0.5,0.3]
triMouseRight 1
triSimFrames 2
triMouseRight 0
triSimFrames 2
triAssertEq [CWR_RTS select 9,"Move order issued"]
triAssertEq [count (CWR_RTS select 15),3]
triAssertEq [count (CWR_RTS select 21),2]
_target=+(CWR_RTS select 15)
_feedback=+(CWR_RTS select 21)
_node=((CWR_RTS select 25) select 0) select 1
CWR_RTS set [12,+_node]
call CWR_UpdateCamera
triSimFrames 4
triCursorMove [0,0]
triMouseLeft 1
triSimFrames 2
triMouseLeft 0
triSimFrames 2
triAssertEq [_h select 3,0]
triAssertEq [CWR_RTS select 15,_target]
triAssertEq [CWR_RTS select 21,_feedback]
triClick 7381
triCursorMove [0,0]
triMouseRight 1
triSimFrames 2
triMouseRight 0
triSimFrames 2
triAssertEq [_h select 3,1]
triAssertEq [_h select 4,0]
// Left click only clears selection, preserving the already running resource order.
triMouseLeft 1
triSimFrames 2
triMouseLeft 0
triSimFrames 2
triAssertEq [count (CWR_RTS select 16),0]
triAssertGt [_h select 3,0]
triAssertEq [_h select 4,0]
triScreenshot "right_click_commands_only"
triEndTest
