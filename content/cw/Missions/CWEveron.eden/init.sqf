call preprocessFile "session.sqf";
call preprocessFile "groups.sqf";
call preprocessFile "catalog.sqf";
call preprocessFile "economy.sqf";
if (call CWR_Start) then {[] exec "tick.sqs"};
