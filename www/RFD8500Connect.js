/*global cordova, module*/

var RFD8500Connect = (function () {
    
    var CORDOVA_PLUGIN_NAME = "RFD8500Connect";
    var CORDOVA_ACTION_GET_SDK_VERSION = "cordovaGetSdkVersion";

    function getSdkVersion(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_GET_SDK_VERSION, argsArray);

    }
    return {
        getSdkVersion: getSdkVersion
    };


}());

module.exports = {
    getSdkVersion: RFD8500Connect.getSdkVersion
};

