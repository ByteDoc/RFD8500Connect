//
//  RFD8500ConnectManager.h
//  BioTest
//
//  Created by CASTANA Solutions on 12.09.19.
//


#import <Foundation/Foundation.h>

#import "RfidSdkFactory.h"
#import "RFD8500RfidEventReceiver.h"


@interface RFD8500ConnectManager : NSObject

{
//    @property
id <srfidISdkApi> apiInstance;
//    @property
    RFD8500RfidEventReceiver *eventReceiver;
//    @property
    RFD8500Connect *plugin;
    
    NSString *lastErrorMessage;
}

- (NSString *) getLastErrorMessage;

- (srfidReaderInfo *) getFirstActiveReader;

- (instancetype) initWithPlugin:(RFD8500Connect*)plugin pluginEventReceiver:(RFD8500RfidEventReceiver*) eventReceiver;

@end


