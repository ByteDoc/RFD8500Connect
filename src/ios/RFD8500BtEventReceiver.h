//
//  RFD8500BtEventReceiver.h
//  rfd8500_bt
//
//  Created by Max Schaufler on 19.12.17.
//

#import "SbtSdkFactory.h"

@class RFD8500Connect;

@interface RFD8500BtEventReceiver : NSObject <ISbtSdkApiDelegate> // <srfidISdkApiDelegate>

{
    id <ISbtSdkApi> apiInstanceBt;
}
- (RFD8500BtEventReceiver*)init;

    @property RFD8500Connect* pluginConnectBt;

@end



