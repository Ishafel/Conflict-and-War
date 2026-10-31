// 006 FR-006/007/011. Mission owns all mutable data; called by its one tick.
// capacity, portion, collect seconds, unload seconds, reach, path timeout, credits/unit.
CWR_EconomyConfig=[100,25,1,2,12,45,1];
CWR_SpawnHarvester={
    private ["_p","_v","_g","_d","_h"]; _p=_this; _h=[];
    _v="Truck5t" createVehicle _p;
    if (isNull _v) then {"Harvester model Truck5t unavailable" call CWR_Status} else {
        _g=createGroup west; "SoldierWB" createUnit [_p,_g,"",0.6,"PRIVATE"];
        if ((count units _g)==0) then {deleteVehicle _v; deleteGroup _g; "Harvester driver unavailable" call CWR_Status} else {
            _d=(units _g) select 0; _d moveInDriver _v; _g setBehaviour "SAFE"; _g setSpeedMode "FULL";
            _h=[_v,_d,0,0,-1,0,[],_g,0,"Idle",objNull];
            CWR_RTS set [24,(CWR_RTS select 24)+[_h]];
        }
    }; _h
};
CWR_HarvesterFor={private ["_found"]; _found=[]; {if ((_x select 0)==_this) then {_found=_x}} forEach (CWR_RTS select 24); _found};
CWR_OwnedUnits={private ["_all"]; _all=+(CWR_RTS select 5); {if (alive (_x select 0)) then {_all set [count _all,_x select 0]}} forEach (CWR_RTS select 24); _all};
CWR_NodeAt={
    private ["_best","_distance","_i","_d"]; _best=-1; _distance=10; _i=0;
    {_d=[_this,_x select 1] call CWR_Distance; if ((_d<_distance) && ((_x select 2)>0)) then {_distance=_d; _best=_i}; _i=_i+1} forEach (CWR_RTS select 25); _best
};
CWR_NearestNode={
    private ["_best","_distance","_i","_d"]; _best=-1; _distance=1e9; _i=0;
    {if ((_x select 2)>0) then {_d=[_this,_x select 1] call CWR_Distance; if (_d<_distance) then {_best=_i; _distance=_d}}; _i=_i+1} forEach (CWR_RTS select 25); _best
};
CWR_SetHarvesterTarget={
    private ["_h","_phase","_target"]; _h=_this select 0; _phase=_this select 1; _target=+(_this select 2);
    _h set [3,_phase]; _h set [6,_target]; _h set [5,time+(CWR_EconomyConfig select 5)];
    (_h select 1) doMove _target; true
};
CWR_ReturnCargo={
    private ["_h","_depot","_d","_nearest","_p"]; _h=_this; _depot=objNull; _nearest=1e9;
    {if (alive _x) then {_d=[getPos (_h select 0),getPos _x] call CWR_Distance; if (_d<_nearest) then {_nearest=_d; _depot=_x}}} forEach (CWR_RTS select 22);
    _h set [10,_depot];
    if (isNull _depot) then {_h set [3,5]; _h set [9,"Waiting for supply depot"]; true} else {
        _p=getPos _depot; _p set [1,(_p select 1)-10];
        [_h,3,_p] call CWR_SetHarvesterTarget; _h set [9,"Returning to depot"]; true
    }
};
CWR_Gather={
    private ["_h","_node","_nodes","_p","_ok"]; _h=_this select 0; _node=_this select 1; _nodes=CWR_RTS select 25; _ok=false;
    if ((alive (_h select 0)) && (alive (_h select 1))) then {
        if ((_h select 2)>=(CWR_EconomyConfig select 0)) then {_ok=_h call CWR_ReturnCargo} else {
            if ((_node<0) || (_node>=(count _nodes))) then {_node=(getPos (_h select 0)) call CWR_NearestNode} else {
                if (((_nodes select _node) select 2)<=0) then {_node=(getPos (_h select 0)) call CWR_NearestNode};
            };
            if (_node<0) then {
                if ((_h select 2)>0) then {_ok=_h call CWR_ReturnCargo} else {_h set [3,0]; _h set [9,"No resources remaining"]};
            } else {
                _h set [4,_node]; _p=+((_nodes select _node) select 1); _p set [1,(_p select 1)-6];
                [_h,1,_p] call CWR_SetHarvesterTarget; _h set [9,"Driving to supplies"]; _ok=true;
            }
        }
    }; _ok
};
CWR_SelectHarvester={
    private ["_v"]; _v=objNull; {if ((alive (_x select 0)) && (isNull _v)) then {_v=_x select 0}} forEach (CWR_RTS select 24);
    if (isNull _v) then {"No live harvester available" call CWR_Status} else {[_v] call CWR_SetSelection}
};
CWR_GatherSelected={
    private ["_node","_h","_ok"]; _node=_this; _ok=false;
    {_h=_x call CWR_HarvesterFor; if ((count _h)>0) then {if ([_h,_node] call CWR_Gather) then {_ok=true}}} forEach (CWR_RTS select 16);
    if (!_ok) then {"Select a live harvester and available supplies" call CWR_Status}; _ok
};
CWR_StopHarvest={private ["_h"]; _h=_this call CWR_HarvesterFor; if ((count _h)>0) then {_h set [3,0]; _h set [9,"Manual move"]}; true};
CWR_ResourceNodes={private ["_nodes"]; _nodes=[]; {if ((_x select 2)>0) then {_nodes set [count _nodes,[_x select 1,_x select 2]]}} forEach (CWR_RTS select 25); _nodes};
CWR_InitEconomy={
    private ["_i","_name","_box","_nodes"]; _nodes=[]; _i=0;
    {_name=format ["CWR_Resource_%1",_i]; _box="ReammoBoxWest" createVehicle _x;
        if (isNull _box) then {"Resource model ReammoBoxWest unavailable" call CWR_Status} else {
            createMarker [_name,_x]; _name setMarkerType "Flag"; _name setMarkerText "SUPPLIES / 1200";
            _nodes set [count _nodes,[_box,+_x,1200,_name]];
        }; _i=_i+1;
    } forEach [[6605,6425,0],[6425,6425,0]];
    CWR_RTS set [25,_nodes]; [6535,6425,0] call CWR_SpawnHarvester; true
};
CWR_ClearEconomy={
    {deleteVehicle (_x select 0); deleteVehicle (_x select 1); deleteGroup (_x select 7)} forEach (CWR_RTS select 24);
    {deleteVehicle (_x select 0); deleteMarker (_x select 3)} forEach (CWR_RTS select 25);
    {deleteVehicle _x} forEach (CWR_RTS select 22); deleteMarker "CWR_Depot";
    CWR_RTS set [22,[]]; CWR_RTS set [24,[]]; CWR_RTS set [25,[]]; true
};
CWR_EconomyTick={
    private ["_h","_v","_phase","_node","_amount","_cargo","_depots"];
    if (time>(CWR_RTS select 26)) then {
        CWR_RTS set [26,time]; _depots=[];
        {if (alive _x) then {_depots set [count _depots,_x]} else {deleteVehicle _x}} forEach (CWR_RTS select 22);
        CWR_RTS set [22,_depots]; if ((count _depots)==0) then {deleteMarker "CWR_Depot"};
        {
            _h=_x; _v=_h select 0; _phase=_h select 3;
            if ((!(alive _v)) || (!(alive (_h select 1)))) then {
                _h set [2,0]; _h set [3,0]; _h set [9,"Harvester lost"];
            } else {
                if (((_phase==3) || (_phase==4)) && (!(alive (_h select 10)))) then {_h call CWR_ReturnCargo; _phase=_h select 3};
                if (_phase==5) then {if ((count _depots)>0) then {_h call CWR_ReturnCargo}};
                if ((_phase==1) || (_phase==3)) then {
                    if (([getPos _v,_h select 6] call CWR_Distance)<=(CWR_EconomyConfig select 4)) then {
                        if (_phase==1) then {_h set [3,2]; _h set [9,"Collecting supplies"]; _h set [5,time+(CWR_EconomyConfig select 2)]} else {
                            _h set [3,4]; _h set [9,"Unloading"]; _h set [5,time+(CWR_EconomyConfig select 3)];
                        }
                    } else {
                        if (time>=(_h select 5)) then {_h set [3,0]; _h set [9,"Path unavailable. Issue a new order."]; (_h select 1) doMove (getPos _v)};
                    }
                };
                if ((_phase==2) && (time>=(_h select 5))) then {
                    _node=(CWR_RTS select 25) select (_h select 4);
                    _amount=CWR_EconomyConfig select 1;
                    if (_amount>(_node select 2)) then {_amount=_node select 2};
                    if (_amount>((CWR_EconomyConfig select 0)-(_h select 2))) then {_amount=(CWR_EconomyConfig select 0)-(_h select 2)};
                    _node set [2,(_node select 2)-_amount]; _h set [2,(_h select 2)+_amount];
                    (_node select 3) setMarkerText format ["SUPPLIES / %1",_node select 2];
                    _h set [5,time+(CWR_EconomyConfig select 2)];
                    if ((_h select 2)>=(CWR_EconomyConfig select 0)) then {_h call CWR_ReturnCargo} else {
                        if ((_node select 2)<=0) then {[_h,-1] call CWR_Gather};
                    }
                };
                if ((_phase==4) && (time>=(_h select 5))) then {
                    _cargo=_h select 2; _h set [2,0]; _h set [3,0];
                    _h set [8,(_h select 8)+_cargo]; CWR_RTS set [0,(CWR_RTS select 0)+_cargo*(CWR_EconomyConfig select 6)];
                    [_h,_h select 4] call CWR_Gather;
                }
            }
        } forEach (CWR_RTS select 24);
    }; true
};
CWR_EconomyUI={
    private ["_tab","_h","_selected","_hover","_def"]; _tab=(CWR_RTS select 14)==0;
    {ctrlShow [_x,_tab]} forEach [7380,7384,7385,7386];
    ctrlEnable [7380,1 call CWR_CanOrder];
    ctrlSetText [7384,1 call CWR_BuildLabel];
    _h=[]; _selected=false;
    {if ((count _h)==0) then {_h=_x call CWR_HarvesterFor}} forEach (CWR_RTS select 16);
    if ((count _h)>0) then {
        _selected=alive (_h select 0);
        ctrlSetText [7383,format ["CARGO %1/%2 | %3",_h select 2,CWR_EconomyConfig select 0,_h select 9]];
        ctrlSetText [7365,"RMB supplies / collect     RMB ground / move     COLLECT / nearest supplies     Home / base"];
    } else {ctrlSetText [7383,"Select vehicle to collect supplies"]};
    ctrlEnable [7382,_selected];
    _hover=_tab && (ctrlIsHovered 7380);
    if (_hover) then {
        {ctrlShow [_x,true]; ctrlEnable [_x,false]} forEach [7362,7363,7367,7368];
        _def=CWR_Catalog select 1; ctrlSetText [7362,"SUPPLY DEPOT"];
        ctrlSetText [7363,format ["%1 credits / %2 seconds\n\nReceives harvester cargo. Credits arrive after unloading.",_def select 2,_def select 3]];
    }; true
};
true
