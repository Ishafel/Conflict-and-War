// FR-008: readiness also accepts an ordinary authored mission without an RTS dialog.
triAssertEq [triDisplay,46]
triMissionPlayerReady
triSimFrames 10
triAssertEq [dialog,false]
triEndTest
