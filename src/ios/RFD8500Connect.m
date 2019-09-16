//
//  RFD8500Connect.m
//  rfd8500_rfid
//
//  Created by Max Schaufler on 18.12.17.
//

#import "RFD8500Connect.h"
#import "RFD8500ConnectInventory.h"

@implementation RFD8500Connect
#define NSStringFromBOOL(aBOOL)    ((aBOOL) ? @"true" : @"false")

- (void) cordova_v2_startInventory:(CDVInvokedUrlCommand *) command {
    [self.commandDelegate runInBackground:^{
        
        NSLog(@">>> starting Inventory ..........");
        
        [self initEventReceiver];
        [self createManager];

        activeReader = [managerInstance getFirstActiveReader];
        
        if (activeReader == nil) {
            [self sendErrorMessageToCallback:command : [managerInstance getLastErrorMessage] ];
            return;
        }
        
        NSString *result = [RFD8500ConnectInventory startInventory:activeReader];
        
        if (result == SRFID_RESULT_SUCCESS) {
            // Inventory STARTED
            // pass the active reader to the callback
            [self sendReaderInfoToCallback:command :activeReader];
        } else {
            [self sendErrorMessageToCallback:command : result ];
            return;
        }
        
    }];
}

- (void) cordova_v2_registerCbOnRead:(CDVInvokedUrlCommand *)command {
    if (commandOnReadNotify == nil) {
        commandOnReadNotify = command;
        NSLog(@"commandOnReadNotify was set");
    }
}

- (void) sendErrorMessageToCallback:(CDVInvokedUrlCommand *)command :(NSString *)errorMessage {
    if (command == nil) {
        NSLog(@"cordova callback command NOT SET, no result will be sent");
        return;
    }
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_ERROR
                                     messageAsString: errorMessage
                                     ];
    [pluginResult setKeepCallbackAsBool:NO];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) sendReaderInfoToCallback:(CDVInvokedUrlCommand *)command :(srfidReaderInfo *)reader {
    NSDictionary *dictReader = [ [NSDictionary alloc]
                                      initWithObjectsAndKeys :
                                      @([reader getReaderID]).stringValue , @"readerId",
                                      NSStringFromBOOL([reader isActive]), @"active",
                                      [reader getReaderName], @"readerName",
                                      nil
                                      ];
    
    // https://stackoverflow.com/questions/6368867/generate-json-string-from-nsdictionary-in-ios/9020923#9020923
    NSError *error;
    NSData *jsonDataReader = [NSJSONSerialization dataWithJSONObject:dictReader
                                                                   options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                                     error:&error];
    NSString *jsonStringReader;
    if (! jsonDataReader) {
        NSLog(@"JSON error: %@", error);
    } else {
        jsonStringReader = [[NSString alloc] initWithData:jsonDataReader encoding:NSUTF8StringEncoding];
    }
    
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             jsonStringReader, @"reader",
                             nil
                             ];
    
    if (command == nil) {
        NSLog(@"cordova callback command NOT SET, no result will be sent");
        return;
    }
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    // [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Arg was null"];
    
    [pluginResult setKeepCallbackAsBool:NO];    // not needed here, startInventory should always be triggered by user manually
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) createManager {
    
    if (managerInstance == nil) {
        managerInstance = [[RFD8500ConnectManager alloc] initWithPlugin:self pluginEventReceiver:eventListener];
    }
}


- (void) cordovaSetGeneralCallbackCommand:(CDVInvokedUrlCommand *)command {
    [self setCommandForGeneralCallback:command];
    //[self generalEventCallback:@"initEventReceiver finished"];
}

- (void) setCommandForGeneralCallback:(CDVInvokedUrlCommand *)command {
    if (commandForGeneralCallback == nil) {
        commandForGeneralCallback = command;
        NSLog(@"commandForGeneralCallback was set");
    }
}

- (void) cordovaInitEventReceiver:(CDVInvokedUrlCommand *)command {
    [self setCommandForGeneralCallback:command];
    //NSLog(@"===== initEventReceiver STARTED ... =====");

    
    [self.commandDelegate runInBackground:^{
        [self initEventReceiver];
        
        [self generalEventCallback:@"initEventReceiver finished"];
    }];
    
}




- (void) initEventReceiver {
    
    NSLog(@"===== initEventReceiver STARTED ... =====");
    
    // ######################
    /* receiving single shared instance of API object */
    apiInstance = [srfidSdkFactory createRfidSdkApiInstance];
    NSString *sdk_version = [apiInstance srfidGetSdkVersion]; NSLog(@"Zebra SDK version: %@\n", sdk_version);
    
    
    if (eventListener == nil) {
        /* registration of callback interface with SDK */
        eventListener = [[RFD8500RfidEventReceiver alloc] init];
        [apiInstance srfidSetDelegate:eventListener];
        
        /* subscribe for tag data and operation status related events */
        [apiInstance srfidSubsribeForEvents:(
                                             SRFID_EVENT_MASK_READ | SRFID_EVENT_MASK_STATUS |
                                             SRFID_EVENT_MASK_BATTERY | SRFID_EVENT_MASK_TRIGGER |
                                             SRFID_EVENT_READER_APPEARANCE | SRFID_EVENT_READER_DISAPPEARANCE |
                                             SRFID_EVENT_SESSION_ESTABLISHMENT | SRFID_EVENT_SESSION_TERMINATION)];
        
        
        /* subscribe for battery and handheld trigger related events */
        //[apiInstance srfidSubsribeForEvents:(SRFID_EVENT_MASK_BATTERY | SRFID_EVENT_MASK_TRIGGER)];
        /* subscribe for connectivity related events */
        //[apiInstance srfidSubsribeForEvents:(SRFID_EVENT_READER_APPEARANCE | SRFID_EVENT_READER_DISAPPEARANCE)];
        
        
        
        /* configuring SDK to communicate with RFID readers in BT MFi mode */
        [apiInstance srfidSetOperationalMode:SRFID_OPMODE_MFI];
        /* configuring SDK to detect appearance and disappearance of available RFID readers */
        [apiInstance srfidEnableAvailableReadersDetection:YES];
        
        
        eventListener.pluginConnect = self;
        
        NSLog(@"eventListener was created !");
        
    } else {
        NSLog(@"eventListener already starting, omitting another start ...");
    }
    
}



//- (void)myPluginMethod:(CDVInvokedUrlCommand*)command
//{
//    // Check command.arguments here.
//    [self.commandDelegate runInBackground:^{
//        NSString* payload = nil;
//        // Some blocking logic...
//        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
//        // The sendPluginResult method is thread-safe.
//        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//    }];
//}

// use the supplied arguments
// NSString* myarg = [command.arguments objectAtIndex:0];




- (void) cordovaRegisterReaderConnect:(CDVInvokedUrlCommand *)command {
    commandOnReaderConnect = command;   // set the command for callback usage in registered events
    
    [self.commandDelegate runInBackground:^{
        [self establishCommunicationSession];
        
        [self pluginCallback:@"cordovaEstablishCommSession finished":command];
    }];
}



- (void) cordovaTerminateCommSession:(CDVInvokedUrlCommand *) command {
    [self setCommandForGeneralCallback:command];
    
    NSLog(@"================= trying to terminate connection ===============");
    [self.commandDelegate runInBackground:^{
        [self terminateCommunicationSession];
    
        /* allocate an array for storage of list of active RFID readers */
        NSMutableArray *active_readers = [[NSMutableArray alloc] init];
        /* retrieve a list of active readers */
        [apiInstance srfidGetActiveReadersList:&active_readers];
        if (0 < [active_readers count]) {
            /* at least one active RFID reader exists */
            srfidReaderInfo *reader = (srfidReaderInfo*)[active_readers objectAtIndex:0];
            /* terminate logical communication session */
            [apiInstance srfidTerminateCommunicationSession:[reader getReaderID]];
            NSLog(@">>>>> Communication Session terminated");
        } else {
            NSLog(@">>>>> NO READER ACTIVE");
        }
        [active_readers removeAllObjects];
        
        [self pluginCallback:@"cordovaTerminateCommSession finished":command];
    }];
}

- (void) cordovaEstablishCommSession:(CDVInvokedUrlCommand *) command {
    [self setCommandForGeneralCallback:command];
    
    [self.commandDelegate runInBackground:^{
        [self establishCommunicationSession];
        
        [self pluginCallback:@"cordovaEstablishCommSession finished":command];
    }];
}

- (void) cordovaStartInventory:(CDVInvokedUrlCommand *) command {
    commandOnReadNotify = command;      // set the command for callback usage in registered events
    
    [self.commandDelegate runInBackground:^{
        //[self initEventReceiver];
        
        [self startInventory];
        
        [self generalEventCallback:@"cordovaStartInventory finished"];
    }];
}

- (void) cordovaStopInventory:(CDVInvokedUrlCommand *) command {
    [self setCommandForGeneralCallback:command];
    
    [self.commandDelegate runInBackground:^{
        //[self initEventReceiver];
        
        [self stopInventory];
        
        [self generalEventCallback:@"cordovaStopInventory finished"];
    }];
}



- (void) terminateCommunicationSession {
    /* allocate an array for storage of list of active RFID readers */
    NSMutableArray *active_readers = [[NSMutableArray alloc] init];
    /* retrieve a list of active readers */
    [apiInstance srfidGetActiveReadersList:&active_readers];
    if (0 < [active_readers count]) {
        /* at least one active RFID reader exists */
        srfidReaderInfo *reader = (srfidReaderInfo*)[active_readers objectAtIndex:0];
        /* terminate logical communication session */
        [apiInstance srfidTerminateCommunicationSession:[reader getReaderID]];
        NSLog(@">>>>> Communication Session terminated");
    } else {
        NSLog(@">>>>> NO READER ACTIVE");
    }
    [active_readers removeAllObjects];
}



- (void) establishCommunicationSession {
    NSLog(@"================= trying to establish connection ===============");
    /* enable automatic communication session reestablishment */
    [apiInstance srfidEnableAutomaticSessionReestablishment:NO];
    
    /* allocate an array for storage of list of available RFID readers */
    NSMutableArray *available_readers = [[NSMutableArray alloc] init];
    /* retrieve a list of available readers */
    //[apiInstance srfidGetAvailableReadersList:&available_readers];  // calling this only once (first time) will NOT list the reader!
    [apiInstance srfidGetAvailableReadersList:&available_readers];  // call twice, doesn't hurt, finds the reader reliably
    if (0 < [available_readers count]) {
        /* at least one available RFID reader exists */
        activeReader = (srfidReaderInfo*)[available_readers objectAtIndex:0];
        /* establish logical communication session */
        [apiInstance srfidEstablishCommunicationSession:[activeReader getReaderID]];
        NSLog(@">>>>> Communication Session established");
    } else {
        NSLog(@">>>>> NO READER AVAILABLE");
    }
    
    [available_readers removeAllObjects];
    
}

- (void) establishAsciiConnection: (NSDictionary *) jsonObj {
    //establish an ASCII protocol level connection
    NSString *password = @""; //@"ascii password";
    SRFID_RESULT result = [apiInstance srfidEstablishAsciiConnection:[activeReader getReaderID] aPassword:password];
    if (SRFID_RESULT_SUCCESS == result) {
        NSLog(@"ASCII connection has been established\n");
        [self cpr_onReaderConnect:jsonObj];
    }
    else if (SRFID_RESULT_WRONG_ASCII_PASSWORD == result) {
        NSLog(@"Incorrect ASCII connection password\n");
    }
    else {
        NSLog(@"Failed to establish ASCII connection\n");
    }
    
    
}




//- (SRFID_RESULT) srfidStartInventory:(int)readerID aMemoryBank: (SRFID_MEMORYBANK)memoryBankId aReportConfig:(srfidReportConfig*)reportConfig aAccessConfig:(srfidAccessConfig*)accessConfig aStatusMessage: (NSString**)statusMessage;
//- (SRFID_RESULT) srfidStopInventory:(int)readerID aStatusMessage: (NSString**)statusMessage;


- (void) startInventory {
    
    NSLog(@"- - - - - starting Inventory Scan - - - - -");
    
    //[self initEventReceiver];
    //[self establishCommunicationSession];
    
    
    int activeReaderId = [activeReader getReaderID];
    
    [apiInstance srfidStopInventory:activeReaderId aStatusMessage:nil];
    
    /*
    //establish an ASCII protocol level connection
    NSString *password = @""; //@"ascii password";
    SRFID_RESULT result = [apiInstance srfidEstablishAsciiConnection:[activeReader getReaderID] aPassword:password];
    if (SRFID_RESULT_SUCCESS == result) {
        NSLog(@"ASCII connection has been established\n"); }
    else if (SRFID_RESULT_WRONG_ASCII_PASSWORD == result) { NSLog(@"Incorrect ASCII connection password\n");
    }
    else {
        NSLog(@"Failed to establish ASCII connection\n");
    }
    */
    
    [apiInstance srfidEnableAutomaticSessionReestablishment:NO];
    
    
    /* subscribe for tag data related events */
//    [apiInstance srfidSubsribeForEvents:SRFID_EVENT_MASK_READ];
    /* subscribe for operation start/stop related events */
//    [apiInstance srfidSubsribeForEvents:SRFID_EVENT_MASK_STATUS];
    
    /* identifier of one of active RFID readers is supposed to be stored in activeReaderId variable */
    /* allocate object for start trigger settings */
    srfidStartTriggerConfig *start_trigger_cfg = [[srfidStartTriggerConfig alloc] init];
    /* allocate object for stop trigger settings */
    srfidStopTriggerConfig *stop_trigger_cfg = [[srfidStopTriggerConfig alloc] init];
    /* allocate object for report parameters of inventory operation */
    srfidReportConfig *report_cfg = [[srfidReportConfig alloc] init];
    /* allocate object for access parameters of inventory operation */
    srfidAccessConfig *access_cfg = [[srfidAccessConfig alloc] init];
    
    srfidDynamicPowerConfig *dynamic_power_cfg = [[srfidDynamicPowerConfig alloc] init];
    
    /* an object for storage of error response received from RFID reader */
    NSString *error_response = nil;
    do {
        /* configure start triggers parameters to start on physical trigger press */
        [start_trigger_cfg setStartOnHandheldTrigger:YES];
        [start_trigger_cfg setTriggerType:SRFID_TRIGGERTYPE_PRESS];
        [start_trigger_cfg setStartDelay:0];
        [start_trigger_cfg setRepeatMonitoring:YES];
        /* configure stop triggers parameters to stop on physical trigger release or on 25 sec timeout*/
        [stop_trigger_cfg setStopOnHandheldTrigger:YES];
        [stop_trigger_cfg setTriggerType:SRFID_TRIGGERTYPE_RELEASE];
        [stop_trigger_cfg setStopOnTimeout:YES];
        [stop_trigger_cfg setStopTimout:(25*1000)];
        [stop_trigger_cfg setStopOnTagCount:NO];
        [stop_trigger_cfg setStopOnInventoryCount:NO];
        [stop_trigger_cfg setStopOnAccessCount:NO];
        /* configure dynamic power config, to avoid "Command Not Allowed if Dynamic Power is Enabled" */
        [dynamic_power_cfg setDynamicPowerOptimizationEnabled:FALSE];
        
        /* set start trigger parameters */
        SRFID_RESULT result = [apiInstance
                               srfidSetStartTriggerConfiguration:activeReaderId
                               aStartTriggeConfig:start_trigger_cfg
                               aStatusMessage:&error_response];
        if (SRFID_RESULT_SUCCESS == result) {
            /* start trigger configuration applied */
            NSLog(@"Start trigger configuration has been set\n");
        } else {
            NSLog(@"Failed to set start trigger parameters\n");
            break;
        }
        /* set stop trigger parameters */
        result = [apiInstance srfidSetStopTriggerConfiguration:activeReaderId
                              aStopTriggeConfig:stop_trigger_cfg
                              aStatusMessage:&error_response];
        if (SRFID_RESULT_SUCCESS == result) {
            /* stop trigger configuration applied */
            NSLog(@"Stop trigger configuration has been set\n");
        } else {
            NSLog(@"Failed to set stop trigger parameters\n");
            break;
        }
        /* set dynamic power config parameter */
        result = [apiInstance srfidSetDpoConfiguration:activeReaderId
                              aDpoConfiguration:dynamic_power_cfg
                              aStatusMessage:&error_response];
        if (SRFID_RESULT_SUCCESS == result) {
            /* dynamic power configuration applied */
            NSLog(@"Dynamic power configuration has been set\n");
        } else {
            NSLog(@"Failed to set dynamic power configuration\n");
            break;
        }
        
        /* start and stop triggers have been configured */
        error_response = nil;
        /* configure report parameters to report RSSI and Channel Index fields */
        [report_cfg setIncPC:NO];
        [report_cfg setIncPhase:NO];
        [report_cfg setIncChannelIndex:YES];
        [report_cfg setIncRSSI:YES]; [report_cfg setIncTagSeenCount:NO];
        [report_cfg setIncFirstSeenTime:NO];
        [report_cfg setIncLastSeenTime:NO];
        /* configure access parameters to perform the operation with 27.0 dbm antenna power
         level without application of pre-filters */
        [access_cfg setPower:270];
        [access_cfg setDoSelect:NO];
        /* request performing of inventory operation with reading from EPC memory bank */
        result = [apiInstance srfidStartInventory:activeReaderId
                              aMemoryBank:SRFID_MEMORYBANK_EPC
                              aReportConfig:report_cfg
                              aAccessConfig:access_cfg
                              aStatusMessage:&error_response];
        if (SRFID_RESULT_SUCCESS == result) {
            NSLog(@"Request succeed\n");
//            /* request abort of an operation after 1 minute */
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                //[apiInstance srfidStopInventory:activeReaderId aStatusMessage:nil];
//                [self stopInventory];
//            });
        }
        else if (SRFID_RESULT_RESPONSE_ERROR == result) {
            NSLog(@"Error response from RFID reader: %@\n", error_response);
        }
        else {
            NSLog(@"Request failed\n");
        }
    } while (0);
    //[start_trigger_cfg release];
    //[stop_trigger_cfg release];
    //[access_cfg release];
    //[report_cfg release];

    
}

- (void) stopInventory {
    
    NSLog(@"- - - - - stopping Inventory Scan - - - - -");
    
    //[self initEventReceiver];
    //[self establishCommunicationSession];
    
    
    int activeReaderId = [activeReader getReaderID];
    
    [apiInstance srfidStopInventory:activeReaderId aStatusMessage:nil];
    
    NSLog(@"stopInventory executed\n");
    
}



- (void) pluginInitialize {
    // create CoreBluetoothManager
    self.bluetoothManager = [[CBCentralManager alloc]
                             initWithDelegate: self
                             queue: dispatch_get_main_queue()
                             options: @{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
}


- (void) cordovaReaderInfo:(CDVInvokedUrlCommand *)command {
    
    [self.commandDelegate runInBackground:^{
        /* identifier of one of active RFID readers is supposed to be stored in
         m_ReaderId variable */
        int m_ReaderId = 1;
        
        /* allocate object for storage of version related information */
        srfidReaderVersionInfo *version_info = [[srfidReaderVersionInfo alloc] init];
        
        /* an object for storage of error response received from RFID reader */
        NSString *error_response = nil;
        
        /* retrieve version related information */
        SRFID_RESULT result = [apiInstance srfidGetReaderVersionInfo:m_ReaderId
                                                  aReaderVersionInfo:&version_info aStatusMessage:&error_response];
        
        if (SRFID_RESULT_SUCCESS == result) {
            /* print the received version related information */
            NSLog(@"Device version: %@\n", [version_info getDeviceVersion]);
            NSLog(@"NGE version: %@\n", [version_info getNGEVersion]);
            NSLog(@"Bluetooth version: %@\n", [version_info getBluetoothVersion]);
        }
        else if (SRFID_RESULT_RESPONSE_ERROR == result) {
            NSLog(@"Error response from RFID reader: %@\n", error_response);
        }
        else if (SRFID_RESULT_RESPONSE_TIMEOUT == result) {
            NSLog(@"Timeout occurs during communication with RFID reader\n");
        }
        else if (SRFID_RESULT_READER_NOT_AVAILABLE == result) {
            NSLog(@"RFID reader with id = %d is not available\n", m_ReaderId);
        }
        else {
            NSLog(@"Request failed\n");
        }
        
        NSDictionary *jsonObj = [ [NSDictionary alloc]
                                 initWithObjectsAndKeys :
                                 @"cordovaReaderInfo finished", @"message",
                                 @"true", @"success",
                                 nil
                                 ];
        CDVPluginResult *pluginResult = [ CDVPluginResult
                                         resultWithStatus    : CDVCommandStatus_OK
                                         messageAsDictionary : jsonObj
                                         ];
        [pluginResult setKeepCallbackAsBool:FALSE];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:commandForGeneralCallback.callbackId];
    }];
}

- (void) cordovaListReaders:(CDVInvokedUrlCommand *)command {
    
    [self.commandDelegate runInBackground:^{
        /* allocate an array for storage of list of available RFID readers */
        NSMutableArray *available_readers = [[NSMutableArray alloc] init];
        /* allocate an array for storage of list of active RFID readers */
        NSMutableArray *active_readers = [[NSMutableArray alloc] init];
        
        /* retrieve a list of available readers */
        [apiInstance srfidGetAvailableReadersList:&available_readers];
        /* retrieve a list of active readers */
        [apiInstance srfidGetActiveReadersList:&active_readers];
        
        /* merge active and available readers to a single list */
        NSMutableArray *readers = [[NSMutableArray alloc] init];
        [readers addObjectsFromArray:active_readers];
        [readers addObjectsFromArray:available_readers];
        [active_readers removeAllObjects ];
        [available_readers removeAllObjects];
        for (srfidReaderInfo *info in readers) {
            /* print the information about RFID reader represented by srfidReaderInfo object */
            NSLog(@"RFID reader is %@: ID = %d name = %@\n", (([info isActive] == YES) ? @"active" : @"available"), [info getReaderID], [info getReaderName]);
        }
        [readers removeAllObjects];
        
        
        //NSString *message = @"generalEventCallback";
        NSDictionary *jsonObj = [ [NSDictionary alloc]
                                 initWithObjectsAndKeys :
                                 @"cordovaListReaders finished", @"message",
                                 @"true", @"success",
                                 nil
                                 ];
        CDVPluginResult *pluginResult = [ CDVPluginResult
                                         resultWithStatus    : CDVCommandStatus_OK
                                         messageAsDictionary : jsonObj
                                         ];
        [pluginResult setKeepCallbackAsBool:TRUE];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:commandForGeneralCallback.callbackId];
    }];
    
}



- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"Bluetooth was enabled");
        [[self commandDelegate] evalJs:[NSString stringWithFormat:@"cordova.plugins.BluetoothStatus.BTenabled = true;"]];
        [[self commandDelegate] evalJs:[NSString stringWithFormat:@"cordova.fireWindowEvent('BluetoothStatus.enabled');"]];
    } else if([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"Bluetooth was disabled");
        [[self commandDelegate] evalJs:[NSString stringWithFormat:@"cordova.plugins.BluetoothStatus.BTenabled = false;"]];
        [[self commandDelegate] evalJs:[NSString stringWithFormat:@"cordova.fireWindowEvent('BluetoothStatus.disabled');"]];
    } else if([central state] == CBCentralManagerStateUnsupported) {
        NSLog(@"Bluetooth LE is not supported");
        [[self commandDelegate] evalJs:[NSString stringWithFormat:@"cordova.plugins.BluetoothStatus.hasBTLE = false;"]];
    } else if([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"use of Bluetooth is not authorized");
        [[self commandDelegate] evalJs:[NSString stringWithFormat:@"cordova.plugins.BluetoothStatus.iosAuthorized = false;"]];
    }
}


    
- (void) cordovaGetSdkVersion:(CDVInvokedUrlCommand *)command {
    
    //[self.commandDelegate runInBackground:^{
        /* variable to store single shared instance of API object */
        //id <srfidISdkApi> apiInstance;
        /* receiving single shared instance of API object */
    
        apiInstance = [srfidSdkFactory createRfidSdkApiInstance];
        /* getting SDK version string */
        NSString *sdk_version = [apiInstance srfidGetSdkVersion]; NSLog(@"Zebra SDK version: %@\n", sdk_version);
    
        NSString *first_version = @"first version string";
        NSDictionary *jsonObj2 = [ [NSDictionary alloc]
                                 initWithObjectsAndKeys :
                                 sdk_version, @"sdk_version",
                                 @"true", @"success",
                                 nil
                                 ];
        CDVPluginResult *pluginResult2 = [ CDVPluginResult
                                         resultWithStatus    : CDVCommandStatus_OK
                                         messageAsDictionary : jsonObj2
                                         ];
        [pluginResult2 setKeepCallbackAsBool:TRUE];
        [self.commandDelegate sendPluginResult:pluginResult2 callbackId:command.callbackId];
    
    
    
        // Create an object that will be serialized into a JSON object.
        // This object contains the date String contents and a success property.
        NSDictionary *jsonObj = [ [NSDictionary alloc]
                                 initWithObjectsAndKeys :
                                 sdk_version, @"sdk_version",
                                 @"true", @"success",
                                 nil
                                 ];
    
        // Create an instance of CDVPluginResult, with an OK status code.
        // Set the return message as the Dictionary object (jsonObj)...
        // ... to be serialized as JSON in the browser
        CDVPluginResult *pluginResult = [ CDVPluginResult
                                         resultWithStatus    : CDVCommandStatus_OK
                                         messageAsDictionary : jsonObj
                                         ];
    
        // Execute sendPluginResult on this plugin's commandDelegate, passing in the ...
        // ... instance of CDVPluginResult
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    //}];
    
}


- (void) generalEventCallback:  (NSString *) messageString {
    // general callback command must be set for this to be used
    if (commandForGeneralCallback == nil) {
        NSLog(@"!!!!! >>>>> commandForGeneralCallback not set for message: %@", messageString);
        return;
    }
    [self pluginCallback:messageString:commandForGeneralCallback];
    
}


- (void) cpr_onReaderConnect: (NSDictionary *) jsonObj {
    if (commandOnReaderConnect == nil) {
        NSLog(@"!!!!! >>>>> commandOnReaderConnect not set");
        return;
    }

    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    [pluginResult setKeepCallbackAsBool:YES];   // use callback multiple times, KEEP IT
    [self.commandDelegate sendPluginResult:pluginResult callbackId:commandOnReaderConnect.callbackId];
}

- (void) cpr_onReadNotify: (NSDictionary *) jsonObj {
    if (commandOnReadNotify == nil) {
        NSLog(@"!!!!! >>>>> commandOnReadNotify not set");
        return;
    }
    //    NSDictionary *jsonObj = [ [NSDictionary alloc]
    //                             initWithObjectsAndKeys :
    //                             messageString, @"message",
    //                             @"true", @"success",
    //                             nil
    //                             ];
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    [pluginResult setKeepCallbackAsBool:YES];   // use callback multiple times, KEEP IT
    [self.commandDelegate sendPluginResult:pluginResult callbackId:commandOnReadNotify.callbackId];
}

- (void) pluginCallback:  (NSString *) messageString
                       :  (CDVInvokedUrlCommand *) command {
    if (command == nil) {
        NSLog(@"cordova callback command NOT SET, no result will be sent");
        return;
    }
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             messageString, @"message",
                             @"true", @"success",
                             nil
                             ];
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    // alternative: error message
    // [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Arg was null"];
    [pluginResult setKeepCallbackAsBool:YES];   // use callback multiple times, KEEP IT
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/****************************************************
 *
 *
 *
 *
 *****************************************************/



- (void)cordovaSetModeBarcode:(CDVInvokedUrlCommand *)command {
//    NSMutableString *_xmlOut;
//    SBT_RESULT r1 = [self executeCommand:SBT_RSM_ATTR_GETALL aInXML:[NSMutableString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><scannerID>1</scannerID></inArgs>", [activeScanner getScannerID]] aOutXML:_xmlOut forScanner:[activeScanner getScannerID]];
    
    NSString *in_xml_ModeBarcode = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list><attribute><id>1664</id><datatype>B</datatype><value>1</value></attribute></attrib_list></arg-xml></cmdArgs></inArgs>", [activeScanner getScannerID]];
    SBT_RESULT result = [self executeCommand:SBT_RSM_ATTR_SET aInXML:in_xml_ModeBarcode aOutXML:nil forScanner:[activeScanner getScannerID]];
}

- (SBT_RESULT)executeCommand:(int)opCode aInXML:(NSString*)inXML aOutXML:(NSMutableString**)outXML forScanner:(int)scannerID
{
    if (apiInstanceBt != nil)
    {
        return [apiInstanceBt sbtExecuteCommand:opCode aInXML:inXML aOutXML:outXML forScanner:scannerID];
    }
    return SBT_RESULT_FAILURE;
}




/****************************************************
 *
 *
 *
 *
 *****************************************************/


- (void) cordovaSetGeneralCallbackCommandBt:(CDVInvokedUrlCommand *)command {
    [self setCommandForGeneralCallbackBt:command];
}

- (void) setCommandForGeneralCallbackBt:(CDVInvokedUrlCommand *)command {
    if (commandForGeneralCallbackBt == nil) {
        commandForGeneralCallbackBt = command;
        NSLog(@"commandForGeneralCallbackBt was set");
    }
}

- (void) cordovaInitEventReceiverBt:(CDVInvokedUrlCommand *)command {
    [self setCommandForGeneralCallbackBt:command];
    
    [self.commandDelegate runInBackground:^{
        [self initEventReceiverBt];
        
        [self generalEventCallbackBt:@"initEventReceiverBt finished"];
    }];
    
}


- (void) initEventReceiverBt {
    
    NSLog(@"===== initEventReceiverBt STARTED ... =====");
    
    // ######################
    /* receiving single shared instance of API object */
    apiInstanceBt = [SbtSdkFactory createSbtSdkApiInstance];
    NSString *sdk_version = [apiInstanceBt sbtGetVersion]; NSLog(@"Zebra Bt SDK version: %@\n", sdk_version);
    
    
    if (eventListenerBt == nil) {
        /* registration of callback interface with SDK */
        eventListenerBt = [[RFD8500BtEventReceiver alloc] init];
        [apiInstanceBt sbtSetDelegate:eventListenerBt];
        
        // Subscribe to scanner appearance/disappearance, session establishment/termination,
        // barcode, and image & video event notifications.
        [apiInstanceBt sbtSubsribeForEvents:SBT_EVENT_SCANNER_APPEARANCE |
         SBT_EVENT_SCANNER_DISAPPEARANCE | SBT_EVENT_SESSION_ESTABLISHMENT |
         SBT_EVENT_SESSION_TERMINATION | SBT_EVENT_BARCODE | SBT_EVENT_IMAGE |
         SBT_EVENT_VIDEO];
        
        // Set operational mode to all so that SDK can interface with scanners // operating in MFI or BTLE mode.
        [apiInstanceBt sbtSetOperationalMode:SBT_OPMODE_ALL];
        
        // Actively detect appearance/disappearance of scanners
        [apiInstanceBt sbtEnableAvailableScannersDetection:NO];
        
        eventListenerBt.pluginConnectBt = self;
        
        NSLog(@"eventListenerBt was created !");
    } else {
        NSLog(@"eventListenerBt already starting, omitting another start ...");
    }
    
}

- (void) cordovaEstablishCommSessionBt:(CDVInvokedUrlCommand *) command {
    [self setCommandForGeneralCallbackBt:command];
    
    [self.commandDelegate runInBackground:^{
        [self establishCommunicationSessionBt];
        
        [self pluginCallbackBt:@"cordovaEstablishCommSessionBt finished":command];
    }];
}

- (void) cordovaRegisterReaderConnectBt:(CDVInvokedUrlCommand *)command {
    commandOnScanNotify = command;   // set the command for callback usage in registered events
    
    [self.commandDelegate runInBackground:^{
        [self establishCommunicationSessionBt];
        
        [self pluginCallbackBt:@"establishCommunicationSessionBt finished":command];
    }];
}

- (void) establishCommunicationSessionBt {
    NSLog(@"================= trying to establish connection ===============");
    SBT_RESULT result;
    
    //activeScanner = nil;
    
    // Allocate an array for storage of a list of available scanners
    NSMutableArray *availableScanners = [[NSMutableArray alloc] init];
    // Allocate an array for storage of a list of active scanners
    NSMutableArray *activeScanners = [[NSMutableArray alloc] init];
    // Retrieve a list of available scanners
    result = [apiInstanceBt sbtGetAvailableScannersList:&availableScanners];
    if (result != SBT_RESULT_SUCCESS) {
        NSLog(@">>>>> ERROR in sbtGetAvailableScannersList");
    }
    // Retrieve a list of active scanners
    result = [apiInstanceBt sbtGetActiveScannersList:&activeScanners];
    if (result != SBT_RESULT_SUCCESS) {
        NSLog(@">>>>> ERROR in sbtGetActiveScannersList");
    }
    // Merge the available and active scanners into a single list
    NSMutableArray *allScanners = [[NSMutableArray alloc] init]; [allScanners addObjectsFromArray:availableScanners]; [allScanners addObjectsFromArray:activeScanners];
    // Print information for each available and active scanner for (SbtScannerInfo *info in allScanners)
    //    {
    //        NSLog(@"Scanner is %@: ID = %d name = %@", (([info isActive] == YES) ? @"active" : @"available"), [info getScannerId], [info getScannerName]);
    //    }
    if (0 < [activeScanners count]) {
        /* at least one active scanner exists */
        activeScanner = (SbtScannerInfo*)[activeScanners objectAtIndex:0];
        NSLog(@">>>>> Scanner already active");
    } else if (0 < [availableScanners count]) {
        /* at least one available scanner exists */
        activeScanner = (SbtScannerInfo*)[availableScanners objectAtIndex:0];
        /* establish logical communication session */
        [apiInstanceBt sbtEstablishCommunicationSession:[activeScanner getScannerID]];
        NSLog(@">>>>> Communication Session established");
    } else {
        NSLog(@">>>>> NO READER AVAILABLE");
    }
    
    if (activeScanner != nil) {
        // Subscribe to scanner appearance/disappearance, session establishment/termination,
        // barcode, and image & video event notifications.
        result = [apiInstanceBt sbtSubsribeForEvents:SBT_EVENT_SCANNER_APPEARANCE |
         SBT_EVENT_SCANNER_DISAPPEARANCE | SBT_EVENT_SESSION_ESTABLISHMENT |
         SBT_EVENT_SESSION_TERMINATION | SBT_EVENT_BARCODE | SBT_EVENT_IMAGE |
         SBT_EVENT_VIDEO];
        if (result != SBT_RESULT_SUCCESS) {
            NSLog(@">>>>> ERROR in sbtSubsribeForEvents");
        }
        
        
        // Set the automatic session reestablishment option for scanner
        result = [apiInstanceBt sbtEnableAutomaticSessionReestablishment:YES forScanner:[activeScanner getScannerID]];
        if (result == SBT_RESULT_SUCCESS)
        {
            // TODO: Option successfully set
            NSLog(@"Automatic Session Reestablishment for scanner ID %d has been set successfully",[activeScanner getScannerID]);
        } else {
            NSLog(@"Automatic Session Reestablishment for scanner ID %d could not be set",[activeScanner getScannerID]);
        }
    }
    
    [activeScanners removeAllObjects];
    [availableScanners removeAllObjects];
    
}


- (void) terminateCommunicationSessionBt {
    // Attempt to disconnect from the scanner device that has an ID = 3. SBT_RESULT result = [apiInstance sbtTerminateCommunicationSession:3];
    
    int scannerId;
    
    if (activeScanner != nil) {
        scannerId = [activeScanner getScannerID];
        /* terminate logical communication session */
        SBT_RESULT result = [apiInstanceBt sbtTerminateCommunicationSession:[activeScanner getScannerID]];
        if (result == SBT_RESULT_SUCCESS)
        {
            // TODO: Process successful disconnection
            NSLog(@"Disconnect from scanner ID %d successful",scannerId);
        } else {
            NSLog(@"Failed to disconnect from scanner ID %d",scannerId);
        }
    } else {
        NSLog(@">>>>> NO SCANNER ACTIVE");
    }
    
}

- (void) cordovaTerminateCommSessionBt:(CDVInvokedUrlCommand *) command {
    [self setCommandForGeneralCallbackBt:command];
    
    NSLog(@"================= trying to terminate connection ===============");
    [self.commandDelegate runInBackground:^{
        [self terminateCommunicationSessionBt];

        [self pluginCallbackBt:@"cordovaTerminateCommSessionBt finished":command];
    }];
}

- (void) cpr_onScan: (NSDictionary *) jsonObj {
    if (commandOnScanNotify == nil) {
        NSLog(@"!!!!! >>>>> commandOnScanNotify not set");
        return;
    }

    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    [pluginResult setKeepCallbackAsBool:YES];   // use callback multiple times, KEEP IT
    [self.commandDelegate sendPluginResult:pluginResult callbackId:commandOnScanNotify.callbackId];
}

- (void) cpr_onScannerConnect: (NSDictionary *) jsonObj {
    if (commandOnScannerConnect == nil) {
        NSLog(@"!!!!! >>>>> commandOnScannerConnect not set");
        return;
    }
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    [pluginResult setKeepCallbackAsBool:YES];   // use callback multiple times, KEEP IT
    [self.commandDelegate sendPluginResult:pluginResult callbackId:commandOnScannerConnect.callbackId];
}




- (void) pluginInitializeBt {
    // create CoreBluetoothManager
    self.bluetoothManager = [[CBCentralManager alloc]
                             initWithDelegate: self
                             queue: dispatch_get_main_queue()
                             options: @{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
}


- (void) cordovaSetCallbackOnConnectBt:(CDVInvokedUrlCommand *)command {
    if (commandOnScannerConnect == nil) {
        commandOnScannerConnect = command;
        NSLog(@"commandOnScannerConnect was set");
    }
}


- (void) generalEventCallbackBt:  (NSString *) messageString {
    // general callback command must be set for this to be used
    if (commandForGeneralCallbackBt == nil) {
        NSLog(@"!!!!! >>>>> commandForGeneralCallback not set for message: %@", messageString);
        return;
    }
    [self pluginCallbackBt:messageString:commandForGeneralCallbackBt];
    
}


- (void) pluginCallbackBt:  (NSString *) messageString
                       :  (CDVInvokedUrlCommand *) command {
    if (command == nil) {
        NSLog(@"cordova callback command NOT SET, no result will be sent");
        return;
    }
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             messageString, @"message",
                             @"true", @"success",
                             nil
                             ];
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    // alternative: error message
    // [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Arg was null"];
    [pluginResult setKeepCallbackAsBool:YES];   // use callback multiple times, KEEP IT
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


@end

