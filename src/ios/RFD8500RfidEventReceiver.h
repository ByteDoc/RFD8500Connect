//
//  RFD8500EventReceiver.h
//  rfd8500_rfid
//
//  Created by Max Schaufler on 19.12.17.
//

#import "RfidSdkFactory.h"

@class RFD8500Connect;

@interface RFD8500RfidEventReceiver : NSObject <srfidISdkApiDelegate>

{
    id <srfidISdkApi> apiInstance;
}
- (RFD8500RfidEventReceiver*)init;

    @property RFD8500Connect* pluginConnect;

@end

