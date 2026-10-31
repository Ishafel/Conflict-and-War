// FR-011: remove seated crew as well as vehicle, resources and depot on restart.
triSimUntil { (count CWR_RTS)==27 }
_h=(CWR_RTS select 24) select 0
_v=_h select 0
_driver=_h select 1
_node=((CWR_RTS select 25) select 0) select 0
call CWR_Start
triAssert [isNull _v]
triAssert [isNull _driver]
triAssert [isNull _node]
triAssertEq [count (CWR_RTS select 24),1]
triAssertEq [CWR_RTS select 0,3000]
triEndTest
