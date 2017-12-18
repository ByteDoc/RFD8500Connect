/*global cordova, module*/

var RFD8500Connect = (function () {
    

    function endRfidListener(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_STOP_RFID_LISTENER, argsArray);
    }
    return {
        endRfidListener: endRfidListener
    };


}());

module.exports = {
    endRfidListener: RfidReaderPlugin.endRfidListener
};

