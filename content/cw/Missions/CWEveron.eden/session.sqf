// FR-003..025. Mission-owned state. init.sqf starts exactly one tick.sqs worker.
// Indices: 0 credits,1 HQ,2 barracks,3 production deadline (-1 inactive),4 FIFO deadlines,
// 5 soldiers,6 selection,7 mode(0 select/1 place/2 select/3 move),8 camera,
// 9 status,10 running,11 action ID,12 focus,13 altitude,14 tab,15 move target,
// 16 selected group,17 placement feedback [position,valid],18 paid building READY,19 camera reset epoch,
// 20 ten control groups,21 accepted move feedback [position,time] or [],
// 22 depots,23 construction type,24 harvesters,25 resource nodes,26 economy tick time.
// Use ordinary conditional expressions: legacy exitWith leaks EvalBreak through
// call boundaries in this engine; command functions must return a regular bool.
CWR_RTS=[];
CWR_Config=[1000,15,100,5,150,5];
// 006 FR-005: altitude, FOV, min/max zoom, pan speed per altitude, pitch (degrees).
CWR_CameraConfig=[55,0.58,15,150,0.65,55];
CWR_Distance={private ["_a","_b"]; _a=_this select 0; _b=_this select 1; sqrt (((_a select 0)-(_b select 0))^2+((_a select 1)-(_b select 1))^2)};
CWR_Status={CWR_RTS set [9,_this]; false};
CWR_Clear={
    if ((count CWR_RTS)>0) then {
        call CWR_ClearEconomy;
        CWR_RTS set [10,false]; onMapSingleClick ""; player hideObject false;
        player removeAction (CWR_RTS select 11);
        if (dialog) then {closeDialog 0};
        (CWR_RTS select 8) cameraEffect ["terminate","back"];
        camDestroy (CWR_RTS select 8);
        {private ["_g"]; _g=group _x; deleteVehicle _x; deleteGroup _g} forEach (CWR_RTS select 5);
        deleteVehicle (CWR_RTS select 1); deleteVehicle (CWR_RTS select 2);
        deleteMarker "CWR_HQ"; deleteMarker "CWR_Barracks";
        CWR_RTS set [20,[[],[],[],[],[],[],[],[],[],[]]]; CWR_RTS set [21,[]];
    }; true
};
CWR_CameraTarget={+(CWR_RTS select 12)};
CWR_SyncMap={if (dialog) then {ctrlMapCenter [7304,call CWR_CameraTarget]}; true};
CWR_UpdateCamera={
    private ["_f","_alt","_cam"];
    _f=CWR_RTS select 12; _alt=CWR_RTS select 13; _cam=CWR_RTS select 8;
    _cam camSetTarget (call CWR_CameraTarget);
    _cam camSetPos [_f select 0,(_f select 1)-_alt/(tan (CWR_CameraConfig select 5)),_alt]; _cam camCommit 0; call CWR_SyncMap; true
};
CWR_Command={CWR_RTS set [7,0]; if (!dialog) then {createDialog "CWR_Command"}; call CWR_SyncMap; call CWR_Tick; true};
CWR_Start={
    private ["_hq","_cam","_p"];
    call CWR_Clear; _p=[6519.04,6473.68,0]; _hq="MASH" createVehicle _p;
    if (isNull _hq) then {hint "C&W: HQ class MASH unavailable"; false} else {
        player allowDamage false; removeAllWeapons player; player hideObject true;
        _cam="camera" camCreate [6519.04,6390,70]; _cam cameraEffect ["internal","back"];
        _cam camSetFov (CWR_CameraConfig select 1); showCinemaBorder false;
        CWR_RTS=[3000,_hq,objNull,-1,[],[],objNull,0,_cam,"",true,-1,+_p,CWR_CameraConfig select 0,0,[],[],[],false,0,[[],[],[],[],[],[],[],[],[],[]],[],[],0,[],[],time];
        createMarker ["CWR_HQ",_p]; "CWR_HQ" setMarkerType "Flag"; "CWR_HQ" setMarkerText "C&W HQ";
        CWR_RTS set [11,player addAction ["C&W: Command base","command.sqs"]];
        call CWR_InitEconomy;
        call CWR_UpdateCamera; call CWR_Command; call CWR_Tick; true
    }
};
CWR_PreviewSite={
    private ["_reason","_valid"];
    _reason=[_pos,_candidate] call CWR_SiteErrorWithProbe;
    if (_sea) then {_reason="Cannot build in water"};
    _valid=_reason=="";
    CWR_RTS set [17,[getPos _candidate,_valid]];
    if (_valid) then {CWR_RTS set [9,"Site clear. Click to build; right-click cancels."]} else {CWR_RTS set [9,_reason]};
    _valid
};
CWR_Train={
    private ["_q","_deadline","_reason"];
    _q=CWR_RTS select 4; _reason="";
    if ((isNull (CWR_RTS select 2)) || (!(alive (CWR_RTS select 2))) || ((CWR_RTS select 3)>=0)) then {_reason="A completed barracks is required"};
    if ((count _q)>=(CWR_Config select 5)) then {_reason="Training queue full (5)"};
    if ((CWR_RTS select 0)<(CWR_Config select 2)) then {_reason="Insufficient credits"};
    if (_reason!="") then {_reason call CWR_Status} else {
        _deadline=time+(CWR_Config select 3);
        if ((count _q)>0) then {_deadline=(_q select ((count _q)-1))+(CWR_Config select 3)};
        CWR_RTS set [0,(CWR_RTS select 0)-(CWR_Config select 2)];
        _q set [count _q,_deadline]; CWR_RTS set [4,_q]; CWR_RTS set [9,"Infantry queued"]; true
    }
};
CWR_Select={CWR_RTS set [7,2]; CWR_RTS set [9,"Left-click an owned unit"]; true};
CWR_Move={CWR_RTS set [7,3]; CWR_RTS set [9,"Right-click a destination"]; true};
CWR_Cancel={CWR_RTS set [17,[]]; CWR_RTS set [7,0]; CWR_RTS set [9,"Command cancelled"]; true};
CWR_UnitAt={
    private ["_p","_best","_distance","_d"]; _p=_this; _best=objNull; _distance=4;
    {if (alive _x) then {_d=[getPos _x,_p] call CWR_Distance; if (_d<_distance) then {_best=_x; _distance=_d}}} forEach (call CWR_OwnedUnits);
    _best
};
CWR_SetSelection={
    private ["_selected"]; _selected=[];
    {if ((alive _x) && (_x in (call CWR_OwnedUnits))) then {_selected set [count _selected,_x]}} forEach _this;
    CWR_RTS set [16,_selected]; CWR_RTS set [6,objNull]; CWR_RTS set [7,0];
    if ((count _selected)>0) then {CWR_RTS set [6,_selected select 0]; CWR_RTS set [9,format ["Selected %1. Right-click terrain to move.",count _selected]]} else {CWR_RTS set [9,"No owned units selected"]};
    (count _selected)>0
};
CWR_SelectableUnits={private ["_list"]; _list=[]; {if (alive _x) then {_list set [count _list,_x]}} forEach (call CWR_OwnedUnits); _list};
CWR_Click={
    private ["_p","_mode","_best","_ok"];
    _p=_this; _mode=CWR_RTS select 7; _ok=false;
    if (_mode==1) then {_ok=_p call CWR_Place};
    if (_mode==2) then {
        _best=_p call CWR_UnitAt;
        if (isNull _best) then {_ok=[] call CWR_SetSelection} else {_ok=[_best] call CWR_SetSelection};
    };
    if (_mode==3) then {
        (CWR_RTS select 16) call CWR_SetSelection;
        _best=CWR_RTS select 6;
        if ((isNull _best) || (!(alive _best))) then {"Select a live soldier first" call CWR_Status} else {
            private ["_i","_target"]; _i=0; CWR_RTS set [15,+_p];
            {if (alive _x) then {_x call CWR_StopHarvest; _target=[(_p select 0)+3*_i,_p select 1,0]; _x doMove _target; _i=_i+1}} forEach (CWR_RTS select 16);
            CWR_RTS set [21,[+_p,time]]; CWR_RTS set [7,0]; CWR_RTS set [9,"Move order issued"]; _ok=true
        };
    }; _ok
};
CWR_WorldClick={
    if ((CWR_RTS select 7)==1) then {
        if (_button==1) then {call CWR_Cancel} else {
            if (_sea) then {"Cannot build in water" call CWR_Status} else {_pos call CWR_Place};
        }
    } else {
        if (_button==0) then {
            if (isNull _unit) then {[] call CWR_SetSelection} else {[_unit] call CWR_SetSelection};
        } else {
            private ["_node","_gathered"]; _node=_pos call CWR_NodeAt; _gathered=false;
            if (_node>=0) then {_gathered=_node call CWR_GatherSelected};
            if (!_gathered) then {if (!(isNull (CWR_RTS select 6))) then {call CWR_Move; _pos call CWR_Click} else {[] call CWR_SetSelection}};
        }
    }
};
CWR_CameraInput={
    private ["_f","_alt","_max"];
    _f=+(CWR_RTS select 12); _alt=CWR_RTS select 13; _max=worldSize;
    if (_home) then {_f=getPos (CWR_RTS select 1); _alt=CWR_CameraConfig select 0; CWR_RTS set [19,(CWR_RTS select 19)+1]};
    _f set [0,(_f select 0)+_panX*_alt*(CWR_CameraConfig select 4)]; _f set [1,(_f select 1)+_panY*_alt*(CWR_CameraConfig select 4)];
    if ((_f select 0)<0) then {_f set [0,0]}; if ((_f select 0)>_max) then {_f set [0,_max]};
    if ((_f select 1)<0) then {_f set [1,0]}; if ((_f select 1)>_max) then {_f set [1,_max]};
    _alt=_alt*(0.90^_zoom); if (_alt<(CWR_CameraConfig select 2)) then {_alt=CWR_CameraConfig select 2}; if (_alt>(CWR_CameraConfig select 3)) then {_alt=CWR_CameraConfig select 3};
    CWR_RTS set [12,_f]; CWR_RTS set [13,_alt]; call CWR_UpdateCamera
};
CWR_Home={CWR_RTS set [19,(CWR_RTS select 19)+1]; CWR_RTS set [12,getPos (CWR_RTS select 1)]; CWR_RTS set [13,CWR_CameraConfig select 0]; call CWR_UpdateCamera};
CWR_TabBuild={CWR_RTS set [14,0]; true};
CWR_TabInfantry={CWR_RTS set [14,1]; true};
CWR_SelectionPosition={private ["_positions"]; _positions=[]; {if (alive _x) then {_positions set [count _positions,getPos _x]}} forEach (CWR_RTS select 16); _positions};
// UI reads elapsed gameplay time; pause does not consume feedback lifetime.
CWR_MoveFeedback={
    private ["_feedback","_elapsed"]; _feedback=CWR_RTS select 21;
    if ((count _feedback)==2) then {
        _elapsed=time-(_feedback select 1);
        if ((_elapsed>=0) && (_elapsed<0.8)) then {[_feedback select 0,_elapsed]} else {[]}
    } else {[]}
};
CWR_HealthUnits={
    private ["_list"]; _list=[];
    {if ((alive _x) && (!(isObjectHidden _x))) then {
        if ((_x in (CWR_RTS select 5)) || ((getDamage _x)>0) || (_x in (CWR_RTS select 16))) then {_list set [count _list,[_x,1-(getDamage _x)]]};
    }} forEach (call CWR_OwnedUnits); _list
};
CWR_TrainCardState={
    private ["_p","_q","_ready"]; _p=1; _q=CWR_RTS select 4;
    _ready=(!(isNull (CWR_RTS select 2))) && ((CWR_RTS select 3)<0);
    if ((count _q)>0) then {_p=1-((_q select 0)-time)/(CWR_Config select 3)};
    [_p,count _q,_ready]
};
CWR_Tick={
    private ["_b","_q","_p","_g","_u","_rest","_i","_hover"];
    call CWR_PruneGroups; call CWR_EconomyTick; call CWR_ConstructionTick;
    _b=CWR_RTS select 2; _q=CWR_RTS select 4;
    if (((CWR_RTS select 3)>=0) && (time>=(CWR_RTS select 3))) then {
        CWR_RTS set [3,-1]; CWR_RTS set [18,true]; CWR_RTS set [9,format ["%1 READY. Click its card to place.",(CWR_Catalog select (CWR_RTS select 23)) select 0]];
    };
    if ((isNull _b) && ((count _q)>0)) then {
        CWR_RTS set [0,(CWR_RTS select 0)+(count _q)*(CWR_Config select 2)]; CWR_RTS set [4,[]]; _q=[];
        CWR_RTS set [9,"Barracks unavailable. Training refunded."];
    };
    if (!(isNull _b)) then {
        if (!(alive _b)) then {
            CWR_RTS set [0,(CWR_RTS select 0)+(count _q)*(CWR_Config select 2)]; CWR_RTS set [4,[]]; CWR_RTS set [2,objNull];
            deleteVehicle _b; deleteMarker "CWR_Barracks"; CWR_RTS set [9,"Barracks lost. Training refunded."];
        } else {
            if ((count _q)>0) then {
                if (time>=(_q select 0)) then {
                    _p=getPos _b; _p set [0,(_p select 0)+25];
                    _p set [1,(_p select 1)+3*(count (CWR_RTS select 5))];
                    _g=createGroup west; "SoldierWB" createUnit [_p,_g,"",0.6,"PRIVATE"];
                    if ((count units _g)==0) then {deleteGroup _g; CWR_RTS set [0,(CWR_RTS select 0)+(CWR_Config select 2)]; CWR_RTS set [9,"Infantry creation failed. Order refunded."]} else {
                        _u=(units _g) select 0; _g setBehaviour "SAFE"; _g setSpeedMode "FULL"; CWR_RTS set [5,(CWR_RTS select 5)+[_u]];
                        CWR_RTS set [9,"Infantry deployed. Left-click to select."];
                    };
                    _rest=[]; _i=0; {if (_i>0) then {_rest set [count _rest,_x]}; _i=_i+1} forEach _q;
                    CWR_RTS set [4,_rest];
                };
            };
        };
    };
    if (dialog) then {
        call CWR_SyncMap;
        _hover=false;
        if ((CWR_RTS select 14)==0) then {_hover=ctrlIsHovered 7310} else {_hover=ctrlIsHovered 7311};
        {ctrlShow [_x,_hover]; ctrlEnable [_x,false]} forEach [7362,7363,7367,7368];
        ctrlSetText [7302,format ["%1",CWR_RTS select 0]];
        ctrlSetText [7330,0 call CWR_BuildLabel];
        ctrlSetText [7331,format ["RIFLEMAN / %1",CWR_Config select 2]];
        ctrlSetText [7303,CWR_RTS select 9];
        ctrlSetText [7365,"LMB / select     RMB / move     Ctrl+0-9 / assign     0-9 / groups     WASD / pan     Wheel / zoom     Home / base"];
        if ((CWR_RTS select 7)==1) then {ctrlSetText [7365,"Place / left click     Keep ready / right click     Pan / WASD     Zoom / wheel"]};
        ctrlShow [7360,(CWR_RTS select 14)==0]; ctrlShow [7361,(CWR_RTS select 14)==1];
        if ((CWR_RTS select 14)==0) then {
            ctrlSetText [7362,"BARRACKS"];
            ctrlSetText [7363,format ["%1 credits\n%2 seconds\n\nInfantry facility",CWR_Config select 0,CWR_Config select 1]];
            if ((CWR_RTS select 3)>=0) then {ctrlSetText [7363,"Production underway.\n\nPlace when READY."]};
            if (CWR_RTS select 18) then {ctrlSetText [7363,"Ready to deploy.\n\nClick the portrait to choose a site."]};
            if (!(isNull (CWR_RTS select 2))) then {ctrlSetText [7363,"Facility deployed.\n\nRecruit from the infantry tab."]};
        } else {
            ctrlSetText [7362,"RIFLEMAN"];
            ctrlSetText [7363,format ["%1 credits\n%2 seconds\n\nGround infantry",CWR_Config select 2,CWR_Config select 3]];
            if (isNull (CWR_RTS select 2)) then {ctrlSetText [7363,"Requires deployed barracks.\n\nBuild your first facility."]};
        };
        ctrlShow [7366,((CWR_RTS select 14)==1) && (isNull (CWR_RTS select 2))];
        ctrlSetText [7305,format ["FORCES %1  /  QUEUE %2",count (CWR_RTS select 5),count (CWR_RTS select 4)]];
        ctrlShow [7310,(CWR_RTS select 14)==0]; ctrlShow [7311,(CWR_RTS select 14)==1];
        ctrlShow [7350,(CWR_RTS select 14)==0]; ctrlShow [7351,(CWR_RTS select 14)==1];
        ctrlShow [7340,(CWR_RTS select 14)==0]; ctrlShow [7341,(CWR_RTS select 14)==1];
        ctrlShow [7330,(CWR_RTS select 14)==0]; ctrlShow [7331,(CWR_RTS select 14)==1];
        ctrlEnable [7310,0 call CWR_CanOrder];
        call CWR_EconomyUI;
        ctrlEnable [7311,(!(isNull (CWR_RTS select 2))) && ((CWR_RTS select 3)<0) && ((CWR_RTS select 0)>=(CWR_Config select 2)) && ((count (CWR_RTS select 4))<(CWR_Config select 5))];
    }; true
};
CWR_Stop={call CWR_Clear; endMission "END1"; forceEnd; true};
true
