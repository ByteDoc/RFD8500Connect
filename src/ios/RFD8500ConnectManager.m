//
//  RFD8500ConnectManager.m
//  BioTest
//
//  Created by CASTANA Solutions on 12.09.19.
//

#import <Foundation/Foundation.h>

#import "RFD8500ConnectManager.h"

@implementation RFD8500ConnectManager

#define LogString(msg) NSLog(@"%@\n", msg)


- (id) initWithPlugin:(RFD8500Connect *)plugin pluginEventReceiver:(RFD8500RfidEventReceiver *)eventReceiver {
    
    RFD8500ConnectManager *mgr = [[RFD8500ConnectManager alloc] init];
    
    plugin = plugin;
    eventReceiver = eventReceiver;
    
    return mgr;
    
}

- (srfidReaderInfo *) getFirstActiveReader {
    
    apiInstance = [srfidSdkFactory createRfidSdkApiInstance];
    
    lastErrorMessage = @"";
    srfidReaderInfo *reader;
    
    // return the first active reader, if one is already active
    NSMutableArray *active_readers = [[NSMutableArray alloc] init];
    [apiInstance srfidGetActiveReadersList:&active_readers];
    if (0 < [active_readers count]) {
        reader = (srfidReaderInfo*)[active_readers objectAtIndex:0];
        return reader;
    }
    [active_readers removeAllObjects];
    
    
    // look for an available reader
    NSMutableArray *available_readers = [[NSMutableArray alloc] init];
    [apiInstance srfidGetAvailableReadersList:&available_readers];  // call twice, doesn't hurt, finds the reader reliably
    if (0 < [available_readers count]) {
        /* at least one available RFID reader exists */
        reader = (srfidReaderInfo*)[available_readers objectAtIndex:0];
        /* establish logical communication session */
        SRFID_RESULT result = [apiInstance srfidEstablishCommunicationSession:[reader getReaderID]];
        if (result == SRFID_RESULT_SUCCESS) {
             //establish an ASCII protocol level connection
             NSString *password = @""; //@"ascii password";
             result = [apiInstance srfidEstablishAsciiConnection:[reader getReaderID] aPassword:password];
             if (SRFID_RESULT_SUCCESS == result) {
                 return reader;
             }
             else if (SRFID_RESULT_WRONG_ASCII_PASSWORD == result) {
                 lastErrorMessage = @"Incorrect ASCII connection password";
             }
             else {
                 lastErrorMessage = @"Failed to establish ASCII connection";
             }
        } else {
            lastErrorMessage = @"Connection could not be established";
        }
    } else {
        lastErrorMessage = @"No readers available";
    }
    [available_readers removeAllObjects];
    
    if ([lastErrorMessage length] == 0) {
        LogString(lastErrorMessage);
    }
    

    return reader;
}

- (NSString *) getLastErrorMessage {
    return lastErrorMessage;
}

@end
