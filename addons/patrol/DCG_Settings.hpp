/*
    Types (SCALAR, BOOL, STRING, ARRAY)
*/

class DOUBLES(PREFIX,settings) {
    class GVAR(enable) {
        typeName = "SCALAR";
        typeDetail = "";
        value = 1;
    };
    class GVAR(cooldown) {
        typeName = "SCALAR";
        typeDetail = "";
        value = 1200;
    };
    class GVAR(groupsMaxCount) {
        typeName = "SCALAR";
        typeDetail = "";
        value = 20;
    };
    class GVAR(vehChance) {
        typeName = "SCALAR";
        typeDetail = "";
        value = 0.15;
    };
};