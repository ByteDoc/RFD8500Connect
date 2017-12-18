//
//  RFD8500Connect.m
//  rfd8500_rfid
//
//  Created by Max Schaufler on 18.12.17.
//

#import "RFD8500Connect.h"

@implementation RFD8500Connect

    - (void) cordovaGetSdkVersion:(CDVInvokedUrlCommand *)command {
        
        /* variable to store single shared instance of API object */
        id <srfidISdkApi> apiInstance;
        /* receiving single shared instance of API object */
        apiInstance = [srfidSdkFactory createRfidSdkApiInstance];
        /* getting SDK version string */
        NSString *sdk_version = [apiInstance srfidGetSdkVersion]; NSLog(@"Zebra SDK version: %@\n", sdk_version);
        
        
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
        
    }
    
@end
