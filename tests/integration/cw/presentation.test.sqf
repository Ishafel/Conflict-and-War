// FR-033/034: compact cards and descriptions only on physical hover.
triSimUntil { (count CWR_RTS)==27 }
triSimUntil { dialog }
triCursorMoveControl 7301
triSimFrames 12
triAssertEq [triGetCinemaBorder,false]
triAssertEq [triControlText 7302,"3000"]
triAssertExcludes [triVisibleTexts,"BASE COMMAND"]
triAssertExcludes [triVisibleTexts,"CENTER HQ"]
triAssertEq [triGetControlVisible 7363,0]
triScreenshot "compact_base"
triCursorMoveControl 7310
triSimFrames 12
triAssert [ctrlIsHovered 7310]
triAssert [triGetControlVisible 7363]
triAssertIncludes [triControlText 7363,"Infantry facility"]
triScreenshot "barracks_hover"
triCursorMoveControl 7301
triSimFrames 12
triAssertEq [triGetControlVisible 7363,0]
triCursorMoveControl 7321
triClick 7321
triSimFrames 12
triAssert [triGetControlVisible 7361]
triAssertEq [triGetControlVisible 7360,0]
triAssert [triGetControlVisible 7366]
triAssertEq [triGetControlVisible 7363,0]
triCursorMoveControl 7311
triSimFrames 12
triAssert [ctrlIsHovered 7311]
triAssert [triGetControlVisible 7363]
triAssertIncludes [triControlText 7363,"Requires deployed barracks"]
triScreenshot "locked_infantry_hover"
triClick 7311
triAssertEq [CWR_RTS select 0,3000]
triAssertEq [count (CWR_RTS select 4),0]
triCursorMoveControl 7320
triClick 7320
triSimFrames 12
triAssertEq [triGetControlVisible 7363,0]
triScreenshot "hover_cleared"
triClick 7310
triCursorMoveControl 7310
_expectedCursor=triCursorPos
triSimFrames 12
triScreenshot "producing_hover_before_assert"
triAssertEq [triCursorPos,_expectedCursor]
triAssert [!(ctrlEnabled 7310)]
triAssert [ctrlIsHovered 7310]
triAssert [triGetControlVisible 7363]
triAssertIncludes [triControlText 7363,"Production underway"]
triScreenshot "producing_hover"
triCursorMoveControl 7301
triSimFrames 12
triAssertEq [triGetControlVisible 7363,0]
triEndTest
