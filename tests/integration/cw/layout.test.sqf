// FR-036: real control geometry and input remain at the physical viewport edges.
triSimUntil { (count CWR_RTS)==20 }
triSimUntil { dialog }
_panel=triGetControlRect 7371
triAssertEq [count _panel,4]
triAssertNear [_panel select 0,0.76,0.0001]
triAssertNear [(_panel select 0)+(_panel select 2),1,0.0001]
triAssertNear [_panel select 1,0,0.0001]
triAssertNear [_panel select 3,1,0.0001]
_world=triGetControlRect 7301
triAssertNear [_world select 0,0,0.0001]
triAssertNear [_world select 2,0.76,0.0001]
triScreenshot "sidebar_initial_edges"
triCursorMoveControl 7301
triMouseLeft 1
triSimFrames 2
triSetDisplayStyle 1
triSimFrames 3
triMouseLeft 0
triSimFrames 3
triAssertEq [count (CWR_RTS select 16),0]
triAssertEq [CWR_RTS select 0,3000]
_changed=triGetControlRect 7371
triAssertNear [_changed select 0,0.76,0.0001]
triAssertNear [(_changed select 0)+(_changed select 2),1,0.0001]
triScreenshot "sidebar_changed_band"
triCursorMoveControl 7310
triSimFrames 12
triAssert [ctrlIsHovered 7310]
triAssert [triGetControlVisible 7363]
triSetDisplayStyle 0
triSimFrames 3
_restored=triGetControlRect 7371
triAssertNear [_restored select 0,0.76,0.0001]
triAssertNear [(_restored select 0)+(_restored select 2),1,0.0001]
triCursorMoveControl 7301
triSimFrames 12
triAssertEq [triGetControlVisible 7363,0]
triScreenshot "sidebar_restored_edges"
triEndTest
