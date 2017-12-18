//
//  RFD8500Connect.h
//  rfd8500_rfid
//
//  Created by Max Schaufler on 18.12.17.
//

#import <Cordova/CDV.h>
#import "RfidSdkFactory.h"

@interface RFD8500Connect : CDVPlugin

    
    // This will return the SDK Version in a JSON object
    - (void) cordovaGetSdkVersion:(CDVInvokedUrlCommand *)command;

    
@end
