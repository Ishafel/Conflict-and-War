// FR-030..032: readable initial state and locked/active category feedback.
triSimUntil { (count CWR_RTS)==20 }
triSimUntil { dialog }
triAssertEq [triGetCinemaBorder,false]
triAssertEq [triControlText 7302,"3000"]
triAssert [triGetControlVisible 7360]
triAssertEq [triGetControlVisible 7361,0]
triAssertEq [triGetControlVisible 7366,0]
triScreenshot "base_presentation"
triClick 7321
triSimFrames 10
triAssert [triGetControlVisible 7361]
triAssertEq [triGetControlVisible 7360,0]
triAssert [triGetControlVisible 7366]
triAssertIncludes [triControlText 7363,"Requires deployed barracks"]
triScreenshot "infantry_locked"
triClick 7311
triAssertEq [CWR_RTS select 0,3000]
triAssertEq [count (CWR_RTS select 4),0]
triClick 7320
triSimFrames 10
triAssert [triGetControlVisible 7360]
triAssertEq [triGetControlVisible 7366,0]
triCursorMoveControl 7310
triSimFrames 5
triScreenshot "production_hover"
titleRsc ["CWR_Startup","PLAIN"]
_splashReady=time+0.75
triSimUntil { time>=_splashReady }
triScreenshot "startup_presentation"
triEndTest
