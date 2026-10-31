// 006 FR-002/011. Mission-owned control groups; no persistent/global input state.
CWR_LiveOwned={
    private ["_live"]; _live=[];
    {if ((alive _x) && (_x in (call CWR_OwnedUnits)) && (!(_x in _live))) then {_live set [count _live,_x]}} forEach _this;
    _live
};
CWR_PruneGroups={
    private ["_groups","_i"]; _groups=CWR_RTS select 20; _i=0;
    {_groups set [_i,_x call CWR_LiveOwned]; _i=_i+1} forEach _groups;
    CWR_RTS set [20,_groups]; true
};
CWR_ControlGroup={
    private ["_groups","_members","_current"];
    call CWR_PruneGroups;
    _groups=CWR_RTS select 20;
    if (_assign) then {
        _current=(CWR_RTS select 16) call CWR_LiveOwned;
        if ((count _current)>0) then {
            _groups set [_number,+_current]; CWR_RTS set [20,_groups];
            CWR_RTS set [9,format ["Group %1 assigned (%2)",_number,count _current]];
        } else {"Select units to assign a group" call CWR_Status};
    } else {
        _members=_groups select _number;
        if ((count _members)>0) then {_members call CWR_SetSelection} else {format ["Group %1 is empty",_number] call CWR_Status};
    }; true
};
true
