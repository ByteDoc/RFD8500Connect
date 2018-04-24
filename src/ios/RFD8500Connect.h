//
//  RFD8500Connect.h
//  rfd8500_rfid
//
//  Created by Max Schaufler on 18.12.17.
//

#import <Cordova/CDV.h>
#import "RfidSdkFactory.h"
#import "SbtSdkFactory.h"
#import "RFD8500RfidEventReceiver.h"
#import "RFD8500BtEventReceiver.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface RFD8500Connect : CDVPlugin <CBCentralManagerDelegate>
    {
        // RFID
        id <srfidISdkApi> apiInstance;
        
        CDVInvokedUrlCommand *commandForGeneralCallback;
        
        RFD8500RfidEventReceiver *eventListener;
        
        srfidReaderInfo *activeReader;

        CDVInvokedUrlCommand *commandOnReaderConnect;
        CDVInvokedUrlCommand *commandOnReadNotify;
        
        
        // SCANNER
        id <ISbtSdkApi> apiInstanceBt;
        
        CDVInvokedUrlCommand *commandForGeneralCallbackBt;
        
        RFD8500BtEventReceiver *eventListenerBt;
        
        SbtScannerInfo *activeScanner;
        
        CDVInvokedUrlCommand *commandOnScannerConnect;
        CDVInvokedUrlCommand *commandOnScanNotify;

    }



    - (void) cordovaSetGeneralCallbackCommand:(CDVInvokedUrlCommand *)command;
    - (void) cordovaGetSdkVersion:(CDVInvokedUrlCommand *)command;
    - (void) cordovaInitEventReceiver:(CDVInvokedUrlCommand *)command;
    - (void) cordovaReaderInfo:(CDVInvokedUrlCommand *)command;
    - (void) cordovaListReaders:(CDVInvokedUrlCommand *)command;
    - (void) cordovaEstablishCommSession:(CDVInvokedUrlCommand *)command;
    - (void) cordovaTerminateCommSession:(CDVInvokedUrlCommand *)command;

    - (void) cordovaStartInventory:(CDVInvokedUrlCommand *)command;
    - (void) cordovaStopInventory:(CDVInvokedUrlCommand *)command;
    - (void) cpr_onReadNotify:(NSDictionary *) jsonObj;

    - (void) cordovaRegisterReaderConnect:(CDVInvokedUrlCommand *)command;
    - (void) cpr_onReaderConnect:(NSDictionary *) jsonObj;


    - (void) setCommandForGeneralCallback: (CDVInvokedUrlCommand *) command;
    - (void) generalEventCallback:(NSString *) messageString;
    - (void) pluginCallback:(NSString *) messageString : (CDVInvokedUrlCommand *) command;

    - (void) initEventReceiver;
    - (void) establishCommunicationSession;
    - (void) terminateCommunicationSession;
    - (void) startInventory;


@property CBCentralManager* bluetoothManager;

// ===================
- (void)cordovaSetModeBarcode:(CDVInvokedUrlCommand *)command;
- (SBT_RESULT)executeCommand:(int)opCode aInXML:(NSString*)inXML aOutXML:(NSMutableString**)outXML forScanner:(int)scannerID;
// ===================

- (void) cordovaSetGeneralCallbackCommandBt:(CDVInvokedUrlCommand *)command;
- (void) setCommandForGeneralCallbackBt: (CDVInvokedUrlCommand *) command;
- (void) generalEventCallbackBt:(NSString *) messageString;

- (void) cordovaSetCallbackOnConnectBt:(CDVInvokedUrlCommand *) command;

- (void) cordovaInitEventReceiverBt:(CDVInvokedUrlCommand *)command;

- (void) cordovaEstablishCommSessionBt:(CDVInvokedUrlCommand *)command;
- (void) cordovaTerminateCommSessionBt:(CDVInvokedUrlCommand *)command;

- (void) cordovaRegisterReaderConnectBt:(CDVInvokedUrlCommand *)command;
- (void) initEventReceiverBt;

- (void) establishCommunicationSessionBt;
- (void) terminateCommunicationSessionBt;

    - (void) cpr_onScan:(NSDictionary *) jsonObj;
- (void) cpr_onScannerConnect:(NSDictionary *) jsonObj;


@property CBCentralManager* bluetoothManagerBt;

// ===================
    
    @end

