
//
//  RFD8500RfidEventReceiver.m
//  rfd8500_rfid
//
//  Created by Max Schaufler on 19.12.17.
//

#import "RFD8500RfidEventReceiver.h"
#import "RFD8500Connect.h"

@implementation RFD8500RfidEventReceiver
    
- (RFD8500RfidEventReceiver*)init {
    

    return self;
}

- (void)srfidEventBatteryNotity:(int)readerID aBatteryEvent:(srfidBatteryEvent *)batteryEvent {
    NSLog(@"==> srfidEventBatteryNotify");
    
    NSString *eventString = [batteryEvent debugDescription];
        eventString = [@"BatteryNotify" stringByAppendingString:eventString];
        [self.pluginConnect generalEventCallback:eventString];
}




/**
 ***********************************
 * Events for commandOnReaderConnect
 */
- (void)srfidEventCommunicationSessionEstablished:(srfidReaderInfo *)activeReader {
    NSLog(@"==> CommunicationSessionEstablished");
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             [NSString stringWithFormat:@"%d", [activeReader getReaderID]], @"readerID",
                             [activeReader getReaderName], @"readerName",
                             @YES, @"connected",
                             nil
                             ];
    
    /* print the information about RFID reader represented by srfidReaderInfo object */
    NSLog(@"RFID reader has connected: ID = %d name = %@\n", [activeReader getReaderID], [activeReader getReaderName]);
    
    
    // call ASCII connection establishing
    [self.pluginConnect establishAsciiConnection:jsonObj];
//    [self.pluginConnect cpr_onReaderConnect:jsonObj];
    

}
- (void)srfidEventCommunicationSessionTerminated:(int)readerID {
    NSLog(@"==> CommSessionTerminated");
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             [NSString stringWithFormat:@"%d", readerID], @"readerID",
                             @NO, @"connected",
                             nil
                             ];
    [self.pluginConnect cpr_onReaderConnect:jsonObj];
}
// ****************************************



- (void)srfidEventProximityNotify:(int)readerID aProximityPercent:(int)proximityPercent {
    NSLog(@"==> srfidEventProximityNotify");
    
    NSString *eventString = [NSString stringWithFormat:@"%d", proximityPercent];
    eventString = [@"ProximityNotify" stringByAppendingString:eventString];
    [self.pluginConnect generalEventCallback:eventString];
}




- (void)srfidEventReadNotify:(int)readerID aTagData:(srfidTagData *)tagData {
    NSLog(@"==> srfidEventReadNotify");
    
    /* print the received tag data */
    NSLog(@"Tag data received from RFID reader with ID = %d\n", readerID);
    NSLog(@"Tag id: %@\n", [tagData getTagId]);
    SRFID_MEMORYBANK bank = [tagData getMemoryBank];
    NSString *str_bank = @"";
    if (SRFID_MEMORYBANK_NONE != bank) {
        
        switch (bank) {
            case SRFID_MEMORYBANK_EPC:
                str_bank = @"EPC";
                break;
            case SRFID_MEMORYBANK_TID:
                str_bank = @"TID";
                break;
            case SRFID_MEMORYBANK_USER:
                str_bank = @"USER";
                break;
            case SRFID_MEMORYBANK_RESV:
                str_bank = @"RESV";
                break;
            case SRFID_MEMORYBANK_NONE:
                str_bank = @"NONE";
                break;
            case SRFID_MEMORYBANK_ACCESS:
                str_bank = @"ACCESS";
                break;
            case SRFID_MEMORYBANK_KILL:
                str_bank = @"KILL";
                break;
        }
        NSLog(@"%@ memory bank data: %@\n", str_bank, [tagData getMemoryBankData]);
    }
    
    NSDictionary *jsonObjTagData = [ [NSDictionary alloc]
                                    initWithObjectsAndKeys :
                                    [tagData getTagId], @"tagId",
                                    str_bank, @"memoryBank",
                                    [tagData getMemoryBankData], @"memoryBankData",
                                    //[NSString stringWithFormat:@"%d", [tagData getTagSeenCount]], @"tagSeenCount",
                                    nil
                                    ];
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             [NSString stringWithFormat:@"%d", readerID], @"readerID",
                             jsonObjTagData, @"tagData",
                             nil
                             ];
    [self.pluginConnect cpr_onReadNotify:jsonObj];

//    NSString *eventString = [NSString stringWithFormat:@"ReadNotify, TagId: %@, Memory bank: %@, Data: %@", [tagData getTagId], str_bank, [tagData getMemoryBankData]];
    
    
//    [self.pluginConnect generalEventCallback:eventString];
}



    
- (void)srfidEventReaderAppeared:(srfidReaderInfo *)availableReader {
    NSLog(@"==> RFID reader has appeared: ID = %d name = %@\n", [availableReader getReaderID], [availableReader getReaderName]);
    
    NSString *eventString = [availableReader getReaderName];
    eventString = [@"ReaderAppeared" stringByAppendingString:eventString];
    [self.pluginConnect generalEventCallback:eventString];
}
    
- (void)srfidEventReaderDisappeared:(int)readerID {
    NSLog(@"==> RFID reader has disappeared: ID = %d\n", readerID);
    
    NSString *eventString = [NSString stringWithFormat:@"%d", readerID];
    eventString = [@"ReaderDisappeared" stringByAppendingString:eventString];
    [self.pluginConnect generalEventCallback:eventString];
}



- (void)srfidEventStatusNotify:(int)readerID aEvent:(SRFID_EVENT_STATUS)event aNotification:(id)notificationData {
    NSLog(@"==> srfidEventStatusNotify");
    NSLog(@"Radio operation has %@\n", ((SRFID_EVENT_STATUS_OPERATION_START == event) ? @"started" : @"stopped"));
    
    NSString *eventString = [NSString stringWithFormat:@"%d", readerID];
    eventString = [@"StatusNotify" stringByAppendingString:eventString];
    [self.pluginConnect generalEventCallback:eventString];
}



- (void)srfidEventTriggerNotify:(int)readerID aTriggerEvent:(SRFID_TRIGGEREVENT)triggerEvent {
    NSLog(@"==> srfidEventTriggerNotify");
    
    /* kein Plugin-Log für TriggerNotify
        NSString *eventString = [NSString stringWithFormat:@"%d", readerID];
        eventString = [@"TriggerNotify" stringByAppendingString:eventString];
        [self.pluginConnect generalEventCallback:eventString];
     */
}
    


    @end
