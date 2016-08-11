#define COMPONENT fob
#include "\d\dcg\addons\main\script_mod.hpp"
#include "\d\dcg\addons\main\script_macros.hpp"

#define DISABLE_COMPILE_CACHE

#define PVEH_DEPLOY QUOTE(DOUBLES(ADDON,pveh_deploy))
#define PVEH_REQUEST QUOTE(DOUBLES(ADDON,pveh_request))
#define PVEH_REASSIGN QUOTE(DOUBLES(ADDON,pveh_reassign))
#define FOB_HQ ["Land_Cargo_HQ_V1_F", "Land_Cargo_HQ_V2_F", "Land_Cargo_HQ_V3_F","Land_Cargo_HQ_V4_F"]
#define FOB_MED ["Land_Medevac_house_V1_F", "Land_Medevac_HQ_V1_F","B_Slingload_01_Medevac_F"]
#define RECONVAR QUOTE(DOUBLES(ADDON,activeRecon))
#define KEY_ID format ["%1_build_key", QUOTE(ADDON)]
#define KEY_NAME "Build FOB"
