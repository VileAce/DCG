/*
Author:
Nicholas Clark (SENSEI)

Description:
handle vanilla ieds

Arguments:

Return:
none
__________________________________________________________________*/
#include "script_component.hpp"

if (GVAR(list) isEqualTo []) exitWith {
    [_this select 1] call CBA_fnc_removePerFrameHandler;
};

{
    _near = _x nearEntities [["Man", "LandVehicle"], 4];
    _near = _near select {isPlayer _x};

    if !(_near isEqualTo []) then {
        GVAR(list) deleteAt (GVAR(list) find _x);
        (selectRandom TYPE_EXP) createVehicle (getPosATL _x);
        deleteVehicle _x;
    };

    false
} count GVAR(list);
