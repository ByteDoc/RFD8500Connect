
//
//  RFD8500RfidEventReceiver.m
//  rfd8500_rfid
//
//  Created by Max Schaufler on 19.12.17.
//

#import "RFD8500BtEventReceiver.h"
#import "RFD8500Connect.h"

@implementation RFD8500BtEventReceiver
    
- (RFD8500BtEventReceiver*)init {
    

    return self;
}

    
- (void)sbtEventBarcode:(NSString *)barcodeData barcodeType:(int)barcodeType fromScanner:(int)scannerID {
    NSLog(@"sbtEventBarcode was triggered !");

    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             [NSString stringWithFormat:@"%d", scannerID], @"scannerID",
                             barcodeData, @"barcodeData",
                             [NSString stringWithFormat:@"%d", barcodeType], @"barcodeType",
                             nil
                             ];
    [self.pluginConnectBt cpr_onScan:jsonObj];
}

- (void)sbtEventBarcodeData:(NSData *)barcodeData barcodeType:(int)barcodeType fromScanner:(int)scannerID {
    //NSLog(@"sbtEventBarcodeData was triggered !");
}


// ***************
- (void)sbtEventCommunicationSessionEstablished:(SbtScannerInfo *)activeScanner {
    NSLog(@"==> sbtEventCommunicationSessionEstablished !");
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             [NSString stringWithFormat:@"%d", [activeScanner getScannerID]], @"scannerID",
                             [activeScanner getScannerName], @"scannerName",
                             @YES, @"connected",
                             nil
                             ];
    [self.pluginConnectBt cpr_onScannerConnect:jsonObj];
    /* print the information about RFID reader represented by srfidReaderInfo object */
    NSLog(@"RFID reader has connected: ID = %d name = %@\n", [activeScanner getScannerID], [activeScanner getScannerName]);
}

- (void)sbtEventCommunicationSessionTerminated:(int)scannerID {
    NSLog(@"==> sbtEventCommunicationSessionTerminated!");
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             [NSString stringWithFormat:@"%d", scannerID], @"scannerID",
                             @NO, @"connected",
                             nil
                             ];
    [self.pluginConnectBt cpr_onScannerConnect:jsonObj];
}
// *****************



- (void)sbtEventFirmwareUpdate:(FirmwareUpdateEvent *)fwUpdateEventObj {
    
}

- (void)sbtEventImage:(NSData *)imageData fromScanner:(int)scannerID {
    
}

- (void)sbtEventScannerAppeared:(SbtScannerInfo *)availableScanner {
    
}

- (void)sbtEventScannerDisappeared:(int)scannerID {
    
}

- (void)sbtEventVideo:(NSData *)videoFrame fromScanner:(int)scannerID {
    
}

@end
