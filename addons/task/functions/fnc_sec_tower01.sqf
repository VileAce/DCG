/*
Author:
Nicholas Clark (SENSEI)

Description:
secondary task - destroy tower

Arguments:
0: forced task position <ARRAY>

Return:
none
__________________________________________________________________*/
#define TASK_SECONDARY
#define TASK_NAME 'Destroy Communications Tower'
#define TOWER "Land_TTowerBig_2_F"
#include "script_component.hpp"

params [["_pos",[]]];

// CREATE TASK
_taskID = str diag_tickTime;
_strength = TASK_STRENGTH;

if (!(EGVAR(main,hills) isEqualTo []) && {_pos isEqualTo []}) then {
	_temp = TOWER createVehicleLocal [0,0,0];
	_hillPos = (selectRandom EGVAR(main,hills)) select 0;
	_pos = [_hillPos,0,100,_temp,0,1] call EFUNC(main,findPosSafe);

	deleteVehicle _temp;

	if (_pos isEqualTo _hillPos) then {
		_pos = [];
	};
};

if (_pos isEqualTo []) exitWith {
	[TASK_TYPE,0] call FUNC(select);
};

_tower = TOWER createVehicle _pos;
_tower setPosATL [(getposATL _tower) select 0,(getposATL _tower) select 1,-1];
_tower setVectorUp [0,0,1];
[_tower] call FUNC(handleDamage);

_grp = [_pos,0,_strength] call EFUNC(main,spawnGroup);

[
	{count units (_this select 0) >= (_this select 1)},
	{
		_this params ["_grp"];

		[_grp] call EFUNC(main,setPatrol);
	},
	[_grp,_strength]
] call CBA_fnc_waitUntilAndExecute;

// SET TASK
_taskDescription = "";
[true,_taskID,[_taskDescription,TASK_TITLE,""],_pos,false,true,"destroy"] call EFUNC(main,setTask);

// PUBLISH TASK
TASK_PUBLISH(_pos);

// TASK HANDLER
[{
	params ["_args","_idPFH"];
	_args params ["_taskID","_pos","_tower","_grp"];

	if (GVAR(secondary) isEqualTo []) exitWith {
		[_idPFH] call CBA_fnc_removePerFrameHandler;
		[_taskID, "CANCELED"] call EFUNC(main,setTaskState);
		((units _grp) + [_tower]) call EFUNC(main,cleanup);
		[TASK_TYPE,30] call FUNC(select);
	};

	if !(alive _tower) exitWith {
		[_idPFH] call CBA_fnc_removePerFrameHandler;
		[_taskID, "SUCCEEDED"] call EFUNC(main,setTaskState);
		TASK_APPROVAL(_pos,TASK_AV);
		((units _grp) + [_tower]) call EFUNC(main,cleanup);
		TASK_EXIT;
	};
}, TASK_SLEEP, [_taskID,_pos,_tower,_grp]] call CBA_fnc_addPerFrameHandler;
