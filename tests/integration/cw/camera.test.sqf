// FR-009: native keyboard and wheel events, while sidebar owns focus.
triSimUntil { (count CWR_RTS)==20 }
triSimUntil { dialog }
triAssertEq [triGetCinemaBorder,false]
triClick 7321
_focus=+(CWR_RTS select 12)
triKeyDown 7
triSimFrames 25
triKeyUp 7
triSimFrames 2
triAssertGt [((CWR_RTS select 12) select 0)-(_focus select 0),0.2]
_after=+(CWR_RTS select 12)
triSimFrames 10
triAssertEq [((CWR_RTS select 12) select 0),_after select 0]
_alt=CWR_RTS select 13
triCursorMoveControl 7301
triSimFrames 5
triCursorScroll 1
triSimFrames 5
triAssertLt [CWR_RTS select 13,_alt]
triClick 7315
triSimFrames 5
triAssertEq [((CWR_RTS select 12) select 0),((getPos (CWR_RTS select 1)) select 0)]
triAssertEq [CWR_RTS select 13,55]
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
triEndTest
