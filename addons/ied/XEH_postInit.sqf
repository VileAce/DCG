/*
Author:
Nicholas Clark (SENSEI)
__________________________________________________________________*/
#include "script_component.hpp"
#define DEBUG_IED \
	if (CHECK_DEBUG) then { \
		_mrk = createMarker [format["%1_%2",QUOTE(ADDON),getPosATL _ied],getPosATL _ied]; \
		_mrk setMarkerType "mil_triangle"; \
		_mrk setMarkerSize [0.5,0.5]; \
		_mrk setMarkerColor "ColorRed"; \
	};

if (!isServer || !isMultiplayer) exitWith {};

if (GVAR(enable) isEqualTo 0) exitWith {
	LOG_DEBUG("Addon is disabled.");
};

[{
	if (DOUBLES(PREFIX,main)) exitWith {
		[_this select 1] call CBA_fnc_removePerFrameHandler;

		_type = [];

		if (CHECK_ADDON_1("ace_explosives")) then {
			_type = ["ACE_IEDLandBig_Range_Ammo","ACE_IEDLandSmall_Range_Ammo","ACE_IEDUrbanBig_Range_Ammo","ACE_IEDUrbanSmall_Range_Ammo"];
		} else {
			_type = ["IEDUrbanBig_F","IEDLandBig_F"];
		};

		_data = QUOTE(ADDON) call EFUNC(main,loadDataAddon);
		if (_data isEqualTo []) then {
			{
				_roads = (ASLToAGL _x) nearRoads 500;
				if !(_roads isEqualTo []) then {
					_road = selectRandom _roads;
					_pos = _road modelToWorld [-3 + (ceil random 6),0,0];
					if (!(CHECK_DIST2D(_pos,locationPosition EGVAR(main,baseLocation),EGVAR(main,baseRadius))) && {(nearestLocations [_pos, ["NameCityCapital","NameCity","NameVillage"], 500]) isEqualTo []}) then {
						_pos set [2,0];
						_ied = (selectRandom _type) createVehicle _pos;
						GVAR(array) pushBack _ied;
						DEBUG_IED
					};
				};
			} forEach ([EGVAR(main,center),(worldSize*0.051) max 900,worldSize,0,0,false,false] call EFUNC(main,findPosGrid));
		} else {
			for "_index" from 0 to count _data - 1 do {
				_ied = (selectRandom _type) createVehicle (_data select _index);
				GVAR(array) pushBack _ied;
				DEBUG_IED
			};
		};

		if !(CHECK_ADDON_1("ace_explosives")) then {
			[{
				if (GVAR(array) isEqualTo []) exitWith {
					[_this select 1] call CBA_fnc_removePerFrameHandler;
				};

				{
					_ied = _x;
					if ({CHECK_DIST2D(_x,_ied,4)} count allPlayers > 0) then {
						_explosions = ["R_TBG32V_F","HelicopterExploSmall"];
						(selectRandom _explosions) createVehicle (getPosATL _ied);
						deleteVehicle _ied;
						GVAR(array) deleteAt _forEachIndex;
					};
				} forEach GVAR(array);
			}, 1, []] call CBA_fnc_addPerFrameHandler;
		};
	};
}, 0, []] call CBA_fnc_addPerFrameHandler;

ADDON = true;