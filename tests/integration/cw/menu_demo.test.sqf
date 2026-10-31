// FR-007: own main menu, settings retained, direct playable Everon entry.
triAssertEq [triDisplay,0]
triAssert [(triGetControlVisible 7390)]
triAssertIncludes [triVisibleTexts,"CONFLICT & WAR"]
triScreenshot "main_menu"
triClick 102
triAssertEq [triDisplay,9099]
triScreenshot "settings"
triSendKey 41
triSimFrames 5
triAssertEq [triDisplay,0]
triClick 7390
triSimUntil { (count CWR_RTS)==27 }
triSimUntil { dialog }
triAssertEq [triGetCinemaBorder,false]
triAssert [(triGetControlVisible 7301)]
triAssert [isObjectHidden player]
triAssertEq [CWR_RTS select 13,55]
triScreenshot "everon_from_menu"
triClick 7316
triSimUntil { triDisplay==0 }
triAssert [(triGetControlVisible 7390)]
triScreenshot "returned_to_menu"
triEndTest
