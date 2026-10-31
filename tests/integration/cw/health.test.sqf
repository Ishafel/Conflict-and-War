// FR-003: own infantry HP persists with full health and no selection.
triSimUntil { (count CWR_RTS)==27 }
triSimUntil { dialog }
_g=createGroup west
"SoldierWB" createUnit [[6533,6480,0],_g,"",0.6,"PRIVATE"]
_a=(units _g) select 0
"SoldierWB" createUnit [[6537,6480,0],_g,"",0.6,"PRIVATE"]
_b=(units _g) select 1
"SoldierWB" createUnit [[6541,6480,0],_g,"",0.6,"PRIVATE"]
_c=(units _g) select 2
{_x disableAI "MOVE"} forEach [_a,_b,_c]
CWR_RTS set [5,[_a,_b,_c]]
_a setDamage 0
_b setDamage 0.5
_c setDamage 0.9
[] call CWR_SetSelection
CWR_RTS set [12,[6537,6480,0]]
CWR_RTS set [13,15]
call CWR_UpdateCamera
triSimFrames 8
_health=call CWR_HealthUnits
triAssertEq [count _health,3]
triAssertNear [(_health select 0) select 1,1,0.01]
triAssertNear [(_health select 1) select 1,0.5,0.01]
triAssertNear [(_health select 2) select 1,0.1,0.01]
triAssertEq [count (CWR_RTS select 16),0]
triScreenshot "infantry_hp_without_selection"
[_b] call CWR_SetSelection
triSimFrames 2
triAssertEq [count (call CWR_HealthUnits),3]
[] call CWR_SetSelection
triSimFrames 2
triAssertEq [count (call CWR_HealthUnits),3]
_b hideObject true
triSimFrames 2
triAssertEq [count (call CWR_HealthUnits),2]
triScreenshot "hidden_soldier_excluded"
_b hideObject false
_c setDamage 1
triSimFrames 2
triAssertEq [count (call CWR_HealthUnits),2]
deleteVehicle _a
triSimFrames 2
triAssertEq [count (call CWR_HealthUnits),1]
// A model outside the mission's owned registry cannot reveal another unit's HP.
_otherGroup=createGroup west
"SoldierWB" createUnit [[6545,6480,0],_otherGroup,"",0.6,"PRIVATE"]
_other=(units _otherGroup) select 0
triSimFrames 2
triAssertEq [count (call CWR_HealthUnits),1]
triAssert [(((call CWR_HealthUnits) select 0) select 0)==_b]
deleteVehicle _other
deleteGroup _otherGroup
triEndTest
