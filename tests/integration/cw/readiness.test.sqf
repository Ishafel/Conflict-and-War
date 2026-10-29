// FR-008: readiness also accepts an ordinary authored mission without an RTS dialog.
triAssertEq [triDisplay,46]
triAssertEq [triGetCinemaBorder,true]
triMissionPlayerReady
triSimFrames 10
triAssertEq [dialog,false]
triEndTest
