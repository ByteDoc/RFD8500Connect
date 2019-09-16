//
//  RFD8500ConnectInventory.h
//  BioTest
//
//  Created by CASTANA Solutions on 12.09.19.
//

#import <Foundation/Foundation.h>

#import "RfidSdkFactory.h"
#import "RFD8500RfidEventReceiver.h"


@interface RFD8500ConnectInventory : NSObject

+ (NSString*) startInventory : (srfidReaderInfo*) activeReader;

@end

