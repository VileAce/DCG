/*
Author:
Nicholas Clark (SENSEI)

Description:
init order not guaranteed
__________________________________________________________________*/
waitUntil {!isNil "dcg_main" && {dcg_main}}; // wait until main addon completes postInit

startLoadingScreen ["Loading Mission"];

// misc
["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;
player addRating 9999999;
player addEventHandler ["HandleRating",{
	if (rating (_this select 0) < 0) then {
		abs (rating (_this select 0));
	};
}];

// debug
if (dcg_main_debug isEqualTo 1) then {
	player setVariable ["ace_medical_allowDamage",false];
	player addEventHandler ["handleDamage",{false}];
};

// ACE3
if (!(dcg_main_debug isEqualTo 1) && {isClass (configfile >> "CfgPatches" >> "ace_safemode")}) then {
	player addEventHandler ["respawn",{
		[(_this select 0), currentWeapon (_this select 0), currentMuzzle (_this select 0)] call ace_safemode_fnc_lockSafety;
		(_this select 0) setVariable ["dcg_safeWeapon",false];
	}];

	[{
	    if ((locationPosition dcg_main_baseLocation) distance2D (getPosATL player) <= dcg_main_baseRadius) then {
	        if !(player getVariable ["dcg_safeWeapon",false]) then {
	        	player setVariable ["dcg_safeWeapon",true];
	        	player setVariable ["ace_medical_allowDamage",false];
	            player allowDamage false;
	            if !(currentWeapon player in (player getVariable ["ace_safemode_safedweapons",[]])) then {
	            	[player, currentWeapon player, currentMuzzle player] call ace_safemode_fnc_lockSafety;
	            };
	        };
	    } else {
	        if (player getVariable ["dcg_safeWeapon",false]) then {
	        	player setVariable ["dcg_safeWeapon",false];
	        	player setVariable ["ace_medical_allowDamage",true];
	            player allowDamage true;
	            if (currentWeapon player in (player getVariable ["ace_safemode_safedweapons",[]])) then {
	            	[player, currentWeapon player, currentMuzzle player] call ace_safemode_fnc_lockSafety;
	            };
	        };
	    };
	}, 5, []] call CBA_fnc_addPerFrameHandler;
};

// vehicle hud
call compile preprocessFileLineNumbers "scripts\hud\hud_teamlist.sqf";

// disable 3rd person cam
if (dcg_mission_disableCam) then {
	[{
		if (dcg_mission_disableCam && {cameraOn isEqualTo player} && {cameraView isEqualTo "EXTERNAL"}) then {
			["Third person camera is disabled.",true] call dcg_main_fnc_displayText;
			player switchCamera "INTERNAL";
		};
	}, 1, []] call CBA_fnc_addPerFrameHandler;
};

// briefing
[] spawn {
	player createDiaryRecord ["Diary", ["External Content", "<br/>
			VVS by Tonic<br/>
			Vehicle HUD script by Tier1ops<br/>"]
	];
	player createDiaryRecord ["Diary", ["Mission Info", format ["<br/>
		Author: Nicholas Clark (SENSEI)<br/><br/>
		Known Issues:<br/>
		ACE interaction menu may not initialize at mission start, ACE3 Github issue #1171<br/><br/>
		"]]
	];
};

endLoadingScreen;