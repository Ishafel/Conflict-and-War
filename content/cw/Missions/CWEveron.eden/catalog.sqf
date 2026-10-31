// 006 FR-009. Definitions owned by init.sqf; one paid construction slot.
CWR_Catalog=[["Barracks","Barracks",CWR_Config select 0,CWR_Config select 1],["Supply depot","Camp",600,8]];
CWR_BuildPresent={
    private ["_present"]; _present=false;
    if (_this==0) then {_present=!(isNull (CWR_RTS select 2))} else {{if (alive _x) then {_present=true}} forEach (CWR_RTS select 22)};
    _present
};
CWR_CanOrder={
    private ["_id","_def","_slot"]; _id=_this; _def=CWR_Catalog select _id;
    _slot=((CWR_RTS select 3)>=0) || (CWR_RTS select 18);
    (alive (CWR_RTS select 1)) && (!(_id call CWR_BuildPresent)) && ((CWR_RTS select 3)<0) && ((!_slot) || ((CWR_RTS select 23)==_id)) && ((CWR_RTS select 18) || ((CWR_RTS select 0)>=(_def select 2)))
};
CWR_OrderBuilding={
    private ["_id","_def","_slot"]; _id=_this; _def=CWR_Catalog select _id;
    _slot=((CWR_RTS select 3)>=0) || (CWR_RTS select 18);
    if (!(alive (CWR_RTS select 1))) then {"HQ unavailable" call CWR_Status} else {
        if (_id call CWR_BuildPresent) then {"This facility is already deployed" call CWR_Status} else {
            if (_slot && ((CWR_RTS select 23)!=_id)) then {"Finish the current structure order first" call CWR_Status} else {
                if ((CWR_RTS select 3)>=0) then {"Structure production in progress" call CWR_Status} else {
                    if (CWR_RTS select 18) then {
                        CWR_RTS set [7,1]; CWR_RTS set [9,"Choose an open site 22-150m from HQ. Right-click keeps READY."]; true
                    } else {
                        if ((CWR_RTS select 0)<(_def select 2)) then {"Insufficient credits" call CWR_Status} else {
                            CWR_RTS set [23,_id]; CWR_RTS set [0,(CWR_RTS select 0)-(_def select 2)];
                            CWR_RTS set [3,time+(_def select 3)]; CWR_RTS set [7,0];
                            CWR_RTS set [9,format ["%1 ordered. Wait for READY.",_def select 0]]; true
                        }
                    }
                }
            }
        }
    }
};
CWR_Build={0 call CWR_OrderBuilding};
CWR_PlacementClass={(CWR_Catalog select (CWR_RTS select 23)) select 1};
CWR_SiteErrorWithProbe={
    private ["_p","_probe","_d","_reason","_asl"];
    _p=_this select 0; _probe=_this select 1; _reason=""; _d=[_p,getPos (CWR_RTS select 1)] call CWR_Distance;
    if ((CWR_RTS select 23) call CWR_BuildPresent) then {_reason="Facility already deployed"};
    if (!(CWR_RTS select 18)) then {_reason="Order a structure and wait for READY"};
    if ((_d>(CWR_Config select 4)) || (_d<22)) then {_reason="Site must be 22-150m from HQ"};
    if (_reason=="") then {
        if (isNull _probe) then {_reason="Structure model unavailable: READY order retained"} else {
            _asl=getPosASL _probe;
            if ((_asl select 2)<1) then {_reason="Cannot build in water or at shoreline"} else {
                if (!(objectPlacementClear _probe)) then {_reason="Site obstructed or geometry unavailable: choose an open clearing"};
            }
        }
    }; _reason
};
CWR_SiteError={
    private ["_p","_probe","_reason"]; _p=_this; _probe=(call CWR_PlacementClass) camCreate _p;
    if (!(isNull _probe)) then {_probe setPos [_p select 0,_p select 1,0]};
    _reason=[_p,_probe] call CWR_SiteErrorWithProbe; deleteVehicle _probe; _reason
};
CWR_Place={
    private ["_p","_reason","_b","_id"]; _p=_this; _id=CWR_RTS select 23; _reason=_p call CWR_SiteError;
    if (_reason!="") then {_reason call CWR_Status} else {
        _b=(call CWR_PlacementClass) createVehicle [_p select 0,_p select 1,0];
        if (isNull _b) then {"Structure model unavailable: READY order retained" call CWR_Status} else {
            _b setDir 0; _b setPos [_p select 0,_p select 1,0];
            if (_id==0) then {
                CWR_RTS set [2,_b]; createMarker ["CWR_Barracks",_p]; "CWR_Barracks" setMarkerType "Flag"; "CWR_Barracks" setMarkerText "C&W BARRACKS";
                CWR_RTS set [9,"Barracks deployed. Recruit infantry."];
            } else {
                CWR_RTS set [22,(CWR_RTS select 22)+[_b]];
                createMarker ["CWR_Depot",_p]; "CWR_Depot" setMarkerType "Flag"; "CWR_Depot" setMarkerText "SUPPLY DEPOT";
                CWR_RTS set [9,"Supply depot deployed. Select the harvester and collect supplies."];
            };
            CWR_RTS set [18,false]; CWR_RTS set [3,-1]; CWR_RTS set [17,[]]; CWR_RTS set [7,0]; true
        }
    }
};
CWR_CatalogCardState={
    private ["_p","_n","_ready","_def"]; _p=1; _n=0; _ready=false; _def=CWR_Catalog select _this;
    if ((CWR_RTS select 23)==_this) then {
        if ((CWR_RTS select 3)>=0) then {_n=1; _p=1-((CWR_RTS select 3)-time)/(_def select 3)};
        _ready=CWR_RTS select 18;
    }; [_p,_n,_ready]
};
CWR_ConstructionTick={
    if (((CWR_RTS select 3)>=0) && (!(alive (CWR_RTS select 1)))) then {
        CWR_RTS set [0,(CWR_RTS select 0)+((CWR_Catalog select (CWR_RTS select 23)) select 2)];
        CWR_RTS set [3,-1]; CWR_RTS set [9,"HQ lost. Unfinished structure refunded."];
    }; true
};
CWR_BuildCardState={0 call CWR_CatalogCardState};
CWR_BuildLabel={
    private ["_def","_label"]; _def=CWR_Catalog select _this; _label=format ["%1 / %2",_def select 0,_def select 2];
    if (_this call CWR_BuildPresent) then {_label=_def select 0} else {
        if ((CWR_RTS select 23)==_this) then {
            if ((CWR_RTS select 3)>=0) then {_label="BUILDING"}; if (CWR_RTS select 18) then {_label="READY / PLACE"};
        }
    }; _label
};
true
