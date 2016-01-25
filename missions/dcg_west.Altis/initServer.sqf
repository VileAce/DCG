/*
Author:
Nicholas Clark (SENSEI)

Description:
init order not guaranteed
__________________________________________________________________*/
#include "script_component.hpp"

if !(CHECK_ADDON_1("dcg_main")) exitWith {};

waitUntil {DOUBLES(PREFIX,main)}; // wait until main addon completes postInit

// misc
["Initialize"] call BIS_fnc_dynamicGroups; // BIS group management
createCenter EGVAR(main,enemySide); // required if an enemy side unit is not placed in editor

// headless client check
LOG_DEBUG_1("Headless client is %1.",CHECK_HC);

// debug
if (CHECK_DEBUG) then {
	[{
		_allEnemy = {alive _x && {side _x isEqualTo EGVAR(main,enemySide)}} count allUnits;
		_allCiv = {alive _x && {side _x isEqualTo CIVILIAN}} count allUnits;
		_allGrp = str (count allGroups);
		LOG_DEBUG_5("Enemy Count: %1, Civilian Count: %2, Group Count: %3, Server FPS: %4, Mission Uptime: %5",_allEnemy,_allCiv,_allGrp,round diag_fps,time);
	}, 60, []] call CBA_fnc_addPerFrameHandler;
};

// safezone
if !(EGVAR(main,mobLocation) isEqualTo locationNull) then {
	[{
		{
			if (side _x isEqualTo EGVAR(main,enemySide) && {!isPlayer _x}) then {
				deleteVehicle (vehicle _x);
				deleteVehicle _x;
			};
		} forEach (locationPosition EGVAR(main,mobLocation) nearEntities [["Man","LandVehicle","Ship","Air"], EGVAR(main,mobRadius)]);
	}, 60, []] call CBA_fnc_addPerFrameHandler;
};

// arsenal
waitUntil {!isNil "bis_fnc_arsenal_data"};

_data = missionnamespace getVariable "bis_fnc_arsenal_data"; // remove items from communications tab
_data set [12,[]];
missionnamespace setVariable ["bis_fnc_arsenal_data",_data,true];