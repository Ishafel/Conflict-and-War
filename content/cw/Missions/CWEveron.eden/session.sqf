// FR-003..025. Mission-owned state. init.sqf starts exactly one tick.sqs worker.
// Indices: 0 credits,1 HQ,2 barracks,3 production deadline (-1 inactive),4 FIFO deadlines,
// 5 soldiers,6 selection,7 mode(0 select/1 place/2 select/3 move),8 camera,
// 9 status,10 running,11 action ID,12 focus,13 altitude,14 tab,15 move target,
// 16 selected group,17 placement feedback [position,valid],18 paid building READY.
// Use ordinary conditional expressions: legacy exitWith leaks EvalBreak through
// call boundaries in this engine; command functions must return a regular bool.
CWR_RTS=[];
CWR_Config=[1000,15,100,5,150,5];
CWR_Distance={private ["_a","_b"]; _a=_this select 0; _b=_this select 1; sqrt (((_a select 0)-(_b select 0))^2+((_a select 1)-(_b select 1))^2)};
CWR_Status={CWR_RTS set [9,_this]; false};
CWR_Clear={
    if ((count CWR_RTS)>0) then {
        CWR_RTS set [10,false]; onMapSingleClick ""; player hideObject false;
        player removeAction (CWR_RTS select 11);
        if (dialog) then {closeDialog 0};
        (CWR_RTS select 8) cameraEffect ["terminate","back"];
        camDestroy (CWR_RTS select 8);
        {private ["_g"]; _g=group _x; deleteVehicle _x; deleteGroup _g} forEach (CWR_RTS select 5);
        deleteVehicle (CWR_RTS select 1); deleteVehicle (CWR_RTS select 2);
        deleteMarker "CWR_HQ"; deleteMarker "CWR_Barracks";
    }; true
};
CWR_UpdateCamera={
    private ["_f","_alt","_cam"];
    _f=CWR_RTS select 12; _alt=CWR_RTS select 13; _cam=CWR_RTS select 8;
    _cam camSetTarget [(_f select 0)+12,(_f select 1)+12,0];
    _cam camSetPos [_f select 0,(_f select 1)-_alt*0.85,_alt]; _cam camCommit 0; true
};
CWR_Command={CWR_RTS set [7,0]; if (!dialog) then {createDialog "CWR_Command"}; true};
CWR_Start={
    private ["_hq","_cam","_p"];
    call CWR_Clear; _p=[6519.04,6473.68,0]; _hq="MASH" createVehicle _p;
    if (isNull _hq) then {hint "C&W: HQ class MASH unavailable"; false} else {
        player allowDamage false; removeAllWeapons player; player hideObject true;
        _cam="camera" camCreate [6519.04,6390,70]; _cam cameraEffect ["internal","back"];
        _cam camSetFov 0.8; showCinemaBorder false;
        CWR_RTS=[3000,_hq,objNull,-1,[],[],objNull,0,_cam,"Order barracks. Place when READY.",true,-1,+_p,70,0,[],[],[],false];
        createMarker ["CWR_HQ",_p]; "CWR_HQ" setMarkerType "Flag"; "CWR_HQ" setMarkerText "C&W HQ";
        CWR_RTS set [11,player addAction ["C&W: Command base","command.sqs"]];
        call CWR_UpdateCamera; call CWR_Command; true
    }
};
CWR_Build={
    if (!(isNull (CWR_RTS select 2))) then {"One barracks per base" call CWR_Status} else {
        if ((CWR_RTS select 3)>=0) then {"Barracks production in progress" call CWR_Status} else {
            if (CWR_RTS select 18) then {
                CWR_RTS set [7,1]; CWR_RTS set [9,"Choose an open site 22-150m from HQ. Right-click keeps READY."]; true
            } else {
                if ((CWR_RTS select 0)<(CWR_Config select 0)) then {"Insufficient credits" call CWR_Status} else {
                    CWR_RTS set [0,(CWR_RTS select 0)-(CWR_Config select 0)];
                    CWR_RTS set [3,time+(CWR_Config select 1)]; CWR_RTS set [7,0];
                    CWR_RTS set [9,"Barracks ordered. Wait for READY, then choose a site."]; true
                }
            }
        }
    }
};
CWR_SiteErrorWithProbe={
    private ["_p","_probe","_d","_reason","_asl"];
    _p=_this select 0; _probe=_this select 1; _reason=""; _d=[_p,getPos (CWR_RTS select 1)] call CWR_Distance;
    if (!(isNull (CWR_RTS select 2))) then {_reason="Barracks already ordered"};
    if (!(CWR_RTS select 18)) then {_reason="Order barracks and wait for READY"};
    if ((_d>(CWR_Config select 4)) || (_d<22)) then {_reason="Site must be 22-150m from HQ"};
    if (_reason=="") then {
        if (isNull _probe) then {_reason="Barracks model unavailable: READY order retained"} else {
            _asl=getPosASL _probe;
            if ((_asl select 2)<1) then {_reason="Cannot build in water or at shoreline"} else {
                if (!(objectPlacementClear _probe)) then {_reason="Site obstructed or geometry unavailable: choose an open clearing"};
            };
        };
    }; _reason
};
CWR_SiteError={
    private ["_p","_probe","_reason"]; _p=_this; _probe="Barracks" camCreate _p;
    if (!(isNull _probe)) then {_probe setPos [_p select 0,_p select 1,0]};
    _reason=[_p,_probe] call CWR_SiteErrorWithProbe; deleteVehicle _probe; _reason
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
CWR_Place={
    private ["_p","_reason","_b"];
    _p=_this; _reason=_p call CWR_SiteError;
    if (_reason!="") then {_reason call CWR_Status} else {
        _b="Barracks" createVehicle [_p select 0,_p select 1,0];
        if (isNull _b) then {"Barracks model unavailable: READY order retained" call CWR_Status} else {
            _b setDir 0; _b setPos [_p select 0,_p select 1,0];
            CWR_RTS set [2,_b]; CWR_RTS set [18,false];
            CWR_RTS set [3,-1]; CWR_RTS set [17,[]]; CWR_RTS set [7,0];
            createMarker ["CWR_Barracks",_p]; "CWR_Barracks" setMarkerType "Flag"; "CWR_Barracks" setMarkerText "C&W BARRACKS";
            CWR_RTS set [9,"Barracks deployed. Recruit infantry."]; true
        }
    }
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
CWR_Select={CWR_RTS set [7,2]; CWR_RTS set [9,"Click an owned soldier"]; true};
CWR_Move={CWR_RTS set [7,3]; CWR_RTS set [9,"Click a destination"]; true};
CWR_Cancel={CWR_RTS set [17,[]]; CWR_RTS set [7,0]; CWR_RTS set [9,"Command cancelled"]; true};
CWR_UnitAt={
    private ["_p","_best","_distance","_d"]; _p=_this; _best=objNull; _distance=4;
    {if (alive _x) then {_d=[getPos _x,_p] call CWR_Distance; if (_d<_distance) then {_best=_x; _distance=_d}}} forEach (CWR_RTS select 5);
    _best
};
CWR_SetSelection={
    private ["_selected"]; _selected=[];
    {if ((alive _x) && (_x in (CWR_RTS select 5))) then {_selected set [count _selected,_x]}} forEach _this;
    CWR_RTS set [16,_selected]; CWR_RTS set [6,objNull]; CWR_RTS set [7,0];
    if ((count _selected)>0) then {CWR_RTS set [6,_selected select 0]; CWR_RTS set [9,format ["Selected %1. Click terrain to move.",count _selected]]} else {CWR_RTS set [9,"No owned units selected"]};
    (count _selected)>0
};
CWR_SelectableUnits={private ["_list"]; _list=[]; {if (alive _x) then {_list set [count _list,_x]}} forEach (CWR_RTS select 5); _list};
CWR_Click={
    private ["_p","_mode","_best","_ok"];
    _p=_this; _mode=CWR_RTS select 7; _ok=false;
    if (_mode==1) then {_ok=_p call CWR_Place};
    if (_mode==2) then {
        _best=_p call CWR_UnitAt;
        if (isNull _best) then {_ok=[] call CWR_SetSelection} else {_ok=[_best] call CWR_SetSelection};
    };
    if (_mode==3) then {
        _best=CWR_RTS select 6;
        if ((isNull _best) || (!(alive _best))) then {"Select a live soldier first" call CWR_Status} else {
            private ["_i","_target"]; _i=0; CWR_RTS set [15,+_p];
            {if (alive _x) then {_target=[(_p select 0)+3*_i,_p select 1,0]; _x doMove _target; _i=_i+1}} forEach (CWR_RTS select 16);
            CWR_RTS set [7,0]; CWR_RTS set [9,"Move order issued"]; _ok=true
        };
    }; _ok
};
CWR_WorldClick={
    if ((CWR_RTS select 7)==1) then {
        if (_button==1) then {call CWR_Cancel} else {
            if (_sea) then {"Cannot build in water" call CWR_Status} else {_pos call CWR_Place};
        }
    } else {
        if ((_button==0) && (!(isNull _unit))) then {[_unit] call CWR_SetSelection} else {
            if (!(isNull (CWR_RTS select 6))) then {call CWR_Move; _pos call CWR_Click} else {[] call CWR_SetSelection};
        }
    }
};
CWR_CameraInput={
    private ["_f","_alt","_max"];
    _f=+(CWR_RTS select 12); _alt=CWR_RTS select 13; _max=worldSize;
    if (_home) then {_f=getPos (CWR_RTS select 1); _alt=70};
    _f set [0,(_f select 0)+_panX*100]; _f set [1,(_f select 1)+_panY*100];
    if ((_f select 0)<0) then {_f set [0,0]}; if ((_f select 0)>_max) then {_f set [0,_max]};
    if ((_f select 1)<0) then {_f set [1,0]}; if ((_f select 1)>_max) then {_f set [1,_max]};
    _alt=_alt-_zoom*10; if (_alt<30) then {_alt=30}; if (_alt>200) then {_alt=200};
    CWR_RTS set [12,_f]; CWR_RTS set [13,_alt]; call CWR_UpdateCamera
};
CWR_Home={CWR_RTS set [12,getPos (CWR_RTS select 1)]; CWR_RTS set [13,70]; call CWR_UpdateCamera};
CWR_TabBuild={CWR_RTS set [14,0]; true};
CWR_TabInfantry={CWR_RTS set [14,1]; true};
CWR_Progress={
    private ["_fraction","_label"];
    _fraction=1-(_this select 0)/(_this select 1); _label="[.....]";
    if (_fraction>=0.2) then {_label="[|....]"};
    if (_fraction>=0.4) then {_label="[||...]"};
    if (_fraction>=0.6) then {_label="[|||..]"};
    if (_fraction>=0.8) then {_label="[||||.]"};
    if (_fraction>=1) then {_label="[|||||]"}; _label
};
CWR_SelectionPosition={private ["_positions"]; _positions=[]; {if (alive _x) then {_positions set [count _positions,getPos _x]}} forEach (CWR_RTS select 16); _positions};
CWR_BuildCardState={
    private ["_p","_n"]; _p=1; _n=0;
    if ((CWR_RTS select 3)>=0) then {_n=1; _p=1-((CWR_RTS select 3)-time)/(CWR_Config select 1)};
    [_p,_n,CWR_RTS select 18]
};
CWR_TrainCardState={
    private ["_p","_q","_ready"]; _p=1; _q=CWR_RTS select 4;
    _ready=(!(isNull (CWR_RTS select 2))) && ((CWR_RTS select 3)<0);
    if ((count _q)>0) then {_p=1-((_q select 0)-time)/(CWR_Config select 3)};
    [_p,count _q,_ready]
};
CWR_Tick={
    private ["_b","_q","_p","_g","_u","_rest","_remaining","_i","_training","_buildView","_trainView"];
    _b=CWR_RTS select 2; _q=CWR_RTS select 4;
    if (((CWR_RTS select 3)>=0) && (time>=(CWR_RTS select 3))) then {
        CWR_RTS set [3,-1]; CWR_RTS set [18,true]; CWR_RTS set [9,"Barracks READY. Click its card to place."];
    };
    if ((isNull _b) && ((count _q)>0)) then {
        CWR_RTS set [0,(CWR_RTS select 0)+(count _q)*(CWR_Config select 2)]; CWR_RTS set [4,[]]; CWR_RTS set [3,-1]; _q=[];
        CWR_RTS set [9,"Barracks unavailable. Training refunded."];
    };
    if (!(isNull _b)) then {
        if (!(alive _b)) then {
            CWR_RTS set [0,(CWR_RTS select 0)+(count _q)*(CWR_Config select 2)]; CWR_RTS set [4,[]]; CWR_RTS set [2,objNull]; CWR_RTS set [3,-1];
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
        ctrlSetText [7302,format ["CREDITS %1",CWR_RTS select 0]];
        _remaining=0; if ((CWR_RTS select 3)>=0) then {_remaining=(CWR_RTS select 3)-time};
        _training=0; _q=CWR_RTS select 4; if ((count _q)>0) then {_training=(_q select 0)-time};
        _buildView="--"; _trainView="--";
        if (CWR_RTS select 18) then {_buildView="READY - PLACE"};
        if (!(isNull (CWR_RTS select 2))) then {_buildView="DEPLOYED"};
        if ((CWR_RTS select 3)>=0) then {_buildView=[_remaining,CWR_Config select 1] call CWR_Progress};
        ctrlSetText [7330,"BARRACKS / 1000"];
        if ((CWR_RTS select 3)>=0) then {ctrlSetText [7330,"BARRACKS / BUILDING"]};
        if (CWR_RTS select 18) then {ctrlSetText [7330,"BARRACKS / READY"]};
        if (!(isNull (CWR_RTS select 2))) then {ctrlSetText [7330,"BARRACKS / DEPLOYED"]};
        if ((count _q)>0) then {_trainView=[_training,CWR_Config select 3] call CWR_Progress};
        ctrlSetText [7303,format ["%1\nBUILD %2 | TRAIN %3 | UNITS %4",CWR_RTS select 9,_buildView,_trainView,count (CWR_RTS select 5)]];
        ctrlSetText [7305,format ["PRODUCTION  %1 / 5",count (CWR_RTS select 4)]];
        ctrlShow [7310,(CWR_RTS select 14)==0]; ctrlShow [7311,(CWR_RTS select 14)==1];
        ctrlShow [7350,(CWR_RTS select 14)==0]; ctrlShow [7351,(CWR_RTS select 14)==1];
        ctrlShow [7340,(CWR_RTS select 14)==0]; ctrlShow [7341,(CWR_RTS select 14)==1];
        ctrlShow [7330,(CWR_RTS select 14)==0]; ctrlShow [7331,(CWR_RTS select 14)==1];
        ctrlEnable [7310,(isNull (CWR_RTS select 2)) && ((CWR_RTS select 3)<0) && ((CWR_RTS select 18) || ((CWR_RTS select 0)>=(CWR_Config select 0)))];
        ctrlEnable [7311,(!(isNull (CWR_RTS select 2))) && ((CWR_RTS select 3)<0) && ((CWR_RTS select 0)>=(CWR_Config select 2)) && ((count (CWR_RTS select 4))<(CWR_Config select 5))];
    }; true
};
CWR_Stop={call CWR_Clear; endMission "END1"; true};
true
