/*
Author:
Nicholas Clark (SENSEI)

Description:
primary task - defend supplies

Arguments:
0: forced task position <ARRAY>

Return:
none
__________________________________________________________________*/
#define TASK_PRIMARY
#define TASK_NAME 'Defend Supplies'
#define COUNTDOWN 600
#define FRIENDLY_COUNT 4
#define ENEMY_COUNT 6
#include "script_component.hpp"

params [["_position",[]]];

// CREATE TASK
_taskID = str diag_tickTime;
_type = "";
GVAR(defend_enemies) = [];
_vehPos = [];

if (_position isEqualTo []) then {
	_position = [EGVAR(main,center),EGVAR(main,range),"house",0,true] call EFUNC(main,findPosTerrain);
	if !(_position isEqualTo []) then {
		_position = _position select 1;
	};
};

if (_position isEqualTo []) exitWith {
	[TASK_TYPE,0] call FUNC(select);
};

for "_i" from 1 to 100 do {
	_vehPos = [_position,0,25,16,0,.35] call EFUNC(main,findPosSafe);

	if !(_vehPos isEqualTo _position) exitWith {};

	_vehPos = [];
};

if (_vehPos isEqualTo []) exitWith {
	[TASK_TYPE,0] call FUNC(select);
};

call {
	if (EGVAR(main,playerSide) isEqualTo EAST) exitWith {
		_type = "O_Truck_03_ammo_F";
	};
	if (EGVAR(main,playerSide) isEqualTo RESISTANCE) exitWith {
		_type = "I_Truck_02_ammo_F";
	};
	_type = "B_Truck_01_ammo_F";
};

_truck = _type createVehicle [0,0,0];
_truck lock 3;
[_truck,_vehPos] call EFUNC(main,setPosSafe);
_truck allowDamage false;
_driver = (createGroup CIVILIAN) createUnit ["C_man_w_worker_F", [0,0,0], [], 0, "NONE"];
_driver moveInDriver _truck;
_driver setBehaviour "CARELESS";
_driver setCombatMode "BLUE";
_driver disableAI "TARGET";
_driver disableAI "AUTOTARGET";
_driver disableAI "AUTOCOMBAT";
_driver disableAI "FSM";

_grp = [_position,0,FRIENDLY_COUNT,EGVAR(main,playerSide)] call EFUNC(main,spawnGroup);

[
	{count units (_this select 0) >= FRIENDLY_COUNT},
	{
		[_this select 0] call EFUNC(main,setPatrol);
	},
	[_grp]
] call CBA_fnc_waitUntilAndExecute;

// SET TASK
_taskDescription = format ["A friendly unit is resupplying at %1. Move to the area and provide security while the transport is idle.", mapGridPosition _position];

[true,_taskID,[_taskDescription,TASK_TITLE,""],_position,false,true,"defend"] call EFUNC(main,setTask);

// PUBLISH TASK
TASK_PUBLISH(_position);

// TASK HANDLER
[{
	params ["_args","_idPFH"];
	_args params ["_taskID","_truck","_grp"];

	if (TASK_GVAR isEqualTo []) exitWith {
		[_idPFH] call CBA_fnc_removePerFrameHandler;
		[_taskID, "CANCELED"] call EFUNC(main,setTaskState);
		((units _grp) + [_truck]) call EFUNC(main,cleanup);
		[TASK_TYPE,30] call FUNC(select);
	};

	if ({CHECK_VECTORDIST(getPosASL _x,getPosASL _truck,TASK_DIST_START)} count allPlayers > 0) exitWith {
		[_idPFH] call CBA_fnc_removePerFrameHandler;
		_timerID = [COUNTDOWN,60,TASK_NAME] call EFUNC(main,setTimer);

		[{
			params ["_args","_idPFH"];
			_args params ["_taskID","_truck","_grp","_enemyCount","_timerID"];

			if (TASK_GVAR isEqualTo []) exitWith {
				[_idPFH] call CBA_fnc_removePerFrameHandler;
				[_timerID] call CBA_fnc_removePerFrameHandler;
				[_taskID, "CANCELED"] call EFUNC(main,setTaskState);
				((units _grp) + GVAR(defend_enemies) + [_truck]) call EFUNC(main,cleanup);
				[TASK_TYPE,30] call FUNC(select);
			};

			if ({CHECK_VECTORDIST(getPosASL _x,getPosASL _truck,TASK_DIST_FAIL)} count allPlayers isEqualTo 0) exitWith {
				[_idPFH] call CBA_fnc_removePerFrameHandler;
				[_timerID] call CBA_fnc_removePerFrameHandler;
				[_taskID, "FAILED"] call EFUNC(main,setTaskState);
				((units _grp) + GVAR(defend_enemies) + [_truck]) call EFUNC(main,cleanup);
				TASK_APPROVAL(getPos _truck,TASK_AV * -1);
				TASK_EXIT;
			};

			if (EGVAR(main,timer) < 1) exitWith {
				[_idPFH] call CBA_fnc_removePerFrameHandler;
				[_taskID, "SUCCEEDED"] call EFUNC(main,setTaskState);
				((units _grp) + GVAR(defend_enemies) + [_truck]) call EFUNC(main,cleanup);
				TASK_APPROVAL(getPos _truck,TASK_AV);
				TASK_EXIT;

                _pos = [getPos _truck,3000,4000] call EFUNC(main,findPosSafe);
                _wp = (group driver _truck) addWaypoint [_pos, 0];
                _wp setWaypointSpeed "NORMAL";
                _wp setWaypointBehaviour "CARELESS";
			};

			GVAR(defend_enemies) = GVAR(defend_enemies) select {!(isNull _x)};

			if (random 1 < 0.2 && {count GVAR(defend_enemies) < _enemyCount}) then {
				_grp = [[getpos _truck,200,400] call EFUNC(main,findPosSafe),0,ENEMY_COUNT,EGVAR(main,enemySide),false,1] call EFUNC(main,spawnGroup);
				[
					{count units (_this select 0) >= ENEMY_COUNT},
					{
						GVAR(defend_enemies) append (units (_this select 0));
						_wp = (_this select 0) addWaypoint [_this select 1,30];
                        _wp setWaypointType "SAD";
					},
					[_grp,_truck]
				] call CBA_fnc_waitUntilAndExecute;
			};
		}, TASK_SLEEP, [_taskID,_truck,_grp,TASK_STRENGTH,_timerID]] call CBA_fnc_addPerFrameHandler;
	};
}, TASK_SLEEP, [_taskID,_truck,_grp]] call CBA_fnc_addPerFrameHandler;
