// FR-011: actual stopped gameplay clock, pending unload must not create income.
triSimUntil { (count CWR_RTS)==27 }
_h=(CWR_RTS select 24) select 0
_d="Camp" createVehicle [6560,6425,0]
CWR_RTS set [22,[_d]]
_h set [2,25]
_h set [3,4]
_h set [10,_d]
_h set [5,time+1]
setAccTime 0
_frozen=time
triSimFrames 20
call CWR_EconomyTick
triAssertNear [time,_frozen,0.001]
triAssertEq [_h select 2,25]
triAssertEq [CWR_RTS select 0,3000]
setAccTime 1
triSimUntil { (_h select 8)==25 }
triAssertEq [CWR_RTS select 0,3025]
triAssertEq [_h select 2,0]
triEndTest
