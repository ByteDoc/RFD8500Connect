var RFD8500Connect = (function() {

    var CORDOVA_PLUGIN_NAME = "RFD8500Connect";

    // =================

    var CORDOVA_ACTION_GET_SDK_VERSION = "cordovaGetSdkVersion";
    var CORDOVA_ACTION_SET_GENERAL_CALLBACK_COMMAND = "cordovaGSetGeneralCallbackCommand";

    var CORDOVA_ACTION_INIT_EVENT_RECEIVER = "cordovaInitEventReceiver";
    var CORDOVA_ACTION_READER_INFO = "cordovaReaderInfo";
    var CORDOVA_ACTION_LIST_READERS = "cordovaListReaders";
    var CORDOVA_ACTION_ESTABLISH_COMM_SESSION = "cordovaEstablishCommSession";
    var CORDOVA_ACTION_TERMINATE_COMM_SESSION = "cordovaTerminateCommSession";

    var CORDOVA_ACTION_START_INVENTORY = "cordovaStartInventory";
    var CORDOVA_ACTION_STOP_INVENTORY = "cordovaStopInventory";


    var CORDOVA_ACTION_REGISTER_READER_CONNECT = "cordovaRegisterReaderConnect";

    // =================

    var CORDOVA_ACTION_INIT_EVENT_RECEIVER_BT = "cordovaInitEventReceiverBt";
    var CORDOVA_ACTION_REGISTER_READER_CONNECT_BT = "cordovaRegisterReaderConnectBt";
    var CORDOVA_ACTION_TERMINATE_COMM_SESSION_BT = "cordovaTerminateCommSessionBt";

    // =================

    var oParScanner = {
        callbackLog: function() {},
        callbackError: function() {},
        callbackOnScan: function() {},
        callbackOnConnect: function() {}
    };

    function initScanner(oPar) {
        if(typeof(oPar) != "object") return;
        if (typeof(oPar.callbackLog) == "function") oParScanner.callbackLog = oPar.callbackLog;
        if (typeof(oPar.callbackError) == "function") oParScanner.callbackError = oPar.callbackError;
        if (typeof(oPar.callbackOnScan) == "function") oParScanner.callbackOnScan = oPar.callbackOnScan;
        if (typeof(oPar.callbackOnConnect) == "function") oParScanner.callbackOnConnect = oPar.callbackOnConnect;
        var argsArray = getArgsArray();
        cordova.exec(
            function(result) {
                oParScanner.callbackLog(result);
                setTimeout(function() {
                    cordova.exec(
                        oParScanner.callbackOnConnect,
                        oParScanner.callbackError,
                        CORDOVA_PLUGIN_NAME,
                        "cordovaSetCallbackOnConnectBt",
                        argsArray
                    );
                }, 100);
                setTimeout(function() {
                    cordova.exec(
                        oParScanner.callbackOnScan,
                        oParScanner.callbackError,
                        CORDOVA_PLUGIN_NAME,
                        "cordovaRegisterReaderConnectBt",
                        argsArray
                    );
                }, 100);
            },
            oParScanner.callbackError,
            CORDOVA_PLUGIN_NAME,
            "cordovaInitEventReceiverBt",
            argsArray
        );
    }

    function setModeBarcode(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, "cordovaSetModeBarcode", argsArray);
    }

    // =================               

    function initEventReceiverBt(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_INIT_EVENT_RECEIVER_BT, argsArray);
    }

    function registerReaderConnectBt(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_REGISTER_READER_CONNECT_BT, argsArray);
    }

    function terminateCommSessionBt(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_TERMINATE_COMM_SESSION_BT, argsArray);
    }

    // =================


    function getSdkVersion(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_GET_SDK_VERSION, argsArray);

    }

    function initEventReceiver(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_INIT_EVENT_RECEIVER, argsArray);

    }

    function readerInfo(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_READER_INFO, argsArray);
    }

    function listReaders(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_LIST_READERS, argsArray);
    }

    function establishCommSession(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_ESTABLISH_COMM_SESSION, argsArray);
    }

    function terminateCommSession(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_TERMINATE_COMM_SESSION, argsArray);
    }

    function startInventory(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_START_INVENTORY, argsArray);
    }

    function stopInventory(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_STOP_INVENTORY, argsArray);
    }

    function setGeneralCallbackCommand(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_SET_GENERAL_CALLBACK_COMMAND, argsArray);
    }


    function registerReaderConnect(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, CORDOVA_ACTION_REGISTER_READER_CONNECT, argsArray);
    }


    function v2_startInventory(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, "cordova_v2_startInventory", argsArray);
    }

    function v2_registerCbOnRead(args, successCallback, errorCallback) {
        var argsArray = getArgsArray(args);
        cordova.exec(successCallback, errorCallback, CORDOVA_PLUGIN_NAME, "cordova_v2_registerCbOnRead", argsArray);
    }




    function getArgsArray(args) {
        if (typeof(args) != "object" || args == null || !Array.isArray(args)) {
            args = {};
        }
        return [args];
    }
    return {
        v2_startInventory: v2_startInventory,
        v2_registerCbOnRead: v2_registerCbOnRead,


        getSdkVersion: getSdkVersion,
        initEventReceiver: initEventReceiver,
        readerInfo: readerInfo,
        listReaders: listReaders,
        establishCommSession: establishCommSession,
        terminateCommSession: terminateCommSession,
        startInventory: startInventory,
        stopInventory: stopInventory,
        setGeneralCallbackCommand: setGeneralCallbackCommand,
        registerReaderConnect: registerReaderConnect,

        initEventReceiverBt: initEventReceiverBt,
        registerReaderConnectBt: registerReaderConnectBt,
        terminateCommSessionBt: terminateCommSessionBt,

        initScanner: initScanner,

        setModeBarcode: setModeBarcode
    };


}());

module.exports = {

    v2_startInventory: RFD8500Connect.v2_startInventory,
    v2_registerCbOnRead: RFD8500Connect.v2_registerCbOnRead,


    getSdkVersion: RFD8500Connect.getSdkVersion,
    initEventReceiver: RFD8500Connect.initEventReceiver,
    readerInfo: RFD8500Connect.readerInfo,
    listReaders: RFD8500Connect.listReaders,
    establishCommSession: RFD8500Connect.establishCommSession,
    terminateCommSession: RFD8500Connect.terminateCommSession,
    startInventory: RFD8500Connect.startInventory,
    stopInventory: RFD8500Connect.stopInventory,
    setGeneralCallbackCommand: RFD8500Connect.setGeneralCallbackCommand,
    registerReaderConnect: RFD8500Connect.registerReaderConnect,

    initEventReceiverBt: RFD8500Connect.initEventReceiverBt,
    registerReaderConnectBt: RFD8500Connect.registerReaderConnectBt,
    terminateCommSessionBt: RFD8500Connect.terminateCommSessionBt,

    initScanner: RFD8500Connect.initScanner,

    setModeBarcode: RFD8500Connect.setModeBarcode
};