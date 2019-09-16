//
//  RFD8500ConnectInventory.m
//  BioTest
//
//  Created by CASTANA Solutions on 12.09.19.
//

#import <Foundation/Foundation.h>
#import "RFD8500ConnectInventory.h"

@implementation RFD8500ConnectInventory

// https://stackoverflow.com/a/17597483
#define srfidResultString(enum) [@[@"Success",@"Failure",@"Reader not available",@"Invalid parameters",@"Response timeout",@"Not supported",@"Response error",@"Wrong ASCII password",@"ASCII connection required"] objectAtIndex:enum]

+ (NSString *) startInventory:(srfidReaderInfo *)activeReader
{
    id <srfidISdkApi> apiInstance;
    apiInstance = [srfidSdkFactory createRfidSdkApiInstance];
    
    NSString *errorMessage ;
    
    
    int activeReaderId = [activeReader getReaderID];
    
    [apiInstance srfidStopInventory:activeReaderId aStatusMessage:nil];
    
    [apiInstance srfidEnableAutomaticSessionReestablishment:NO];
    
    /* allocate object for start trigger settings */
    srfidStartTriggerConfig *start_trigger_cfg = [[srfidStartTriggerConfig alloc] init];
    /* allocate object for stop trigger settings */
    srfidStopTriggerConfig *stop_trigger_cfg = [[srfidStopTriggerConfig alloc] init];
    /* allocate object for report parameters of inventory operation */
    srfidReportConfig *report_cfg = [[srfidReportConfig alloc] init];
    /* allocate object for access parameters of inventory operation */
    srfidAccessConfig *access_cfg = [[srfidAccessConfig alloc] init];
    
    srfidDynamicPowerConfig *dynamic_power_cfg = [[srfidDynamicPowerConfig alloc] init];
    
    /* an object for storage of error response received from RFID reader */
    NSString *error_response = nil;
    do {
        /* configure start triggers parameters to start on physical trigger press */
        [start_trigger_cfg setStartOnHandheldTrigger:YES];
        [start_trigger_cfg setTriggerType:SRFID_TRIGGERTYPE_PRESS];
        [start_trigger_cfg setStartDelay:0];
        [start_trigger_cfg setRepeatMonitoring:YES];
        /* configure stop triggers parameters to stop on physical trigger release or on 25 sec timeout*/
        [stop_trigger_cfg setStopOnHandheldTrigger:YES];
        [stop_trigger_cfg setTriggerType:SRFID_TRIGGERTYPE_RELEASE];
        [stop_trigger_cfg setStopOnTimeout:YES];
        [stop_trigger_cfg setStopTimout:(25*1000)];
        [stop_trigger_cfg setStopOnTagCount:NO];
        [stop_trigger_cfg setStopOnInventoryCount:NO];
        [stop_trigger_cfg setStopOnAccessCount:NO];
        /* configure dynamic power config, to avoid "Command Not Allowed if Dynamic Power is Enabled" */
        [dynamic_power_cfg setDynamicPowerOptimizationEnabled:FALSE];
        
        /* set start trigger parameters */
        SRFID_RESULT result = [apiInstance
                               srfidSetStartTriggerConfiguration:activeReaderId
                               aStartTriggeConfig:start_trigger_cfg
                               aStatusMessage:&error_response];
        if (SRFID_RESULT_SUCCESS == result) {
            /* start trigger configuration applied */
            NSLog(@"Start trigger configuration has been set\n");
        } else {
            errorMessage = [NSString stringWithFormat:@"Failed to set start trigger parameters: %@", srfidResultString(result)];
            break;
        }
        /* set stop trigger parameters */
        result = [apiInstance srfidSetStopTriggerConfiguration:activeReaderId
                                             aStopTriggeConfig:stop_trigger_cfg
                                                aStatusMessage:&error_response];
        if (SRFID_RESULT_SUCCESS == result) {
            /* stop trigger configuration applied */
            NSLog(@"Stop trigger configuration has been set\n");
        } else {
            errorMessage = [NSString stringWithFormat:@"Failed to set stop trigger parameters: %@", srfidResultString(result)];
            break;
        }
        /* set dynamic power config parameter */
        result = [apiInstance srfidSetDpoConfiguration:activeReaderId
                                     aDpoConfiguration:dynamic_power_cfg
                                        aStatusMessage:&error_response];
        if (SRFID_RESULT_SUCCESS == result) {
            /* dynamic power configuration applied */
            NSLog(@"Dynamic power configuration has been set\n");
        } else {
            errorMessage = [NSString stringWithFormat:@"Failed to set dynamic power configuration: %@", srfidResultString(result)];
            break;
        }
        
        /* start and stop triggers have been configured */
        error_response = nil;
        /* configure report parameters to report RSSI and Channel Index fields */
        [report_cfg setIncPC:NO];
        [report_cfg setIncPhase:NO];
        [report_cfg setIncChannelIndex:YES];
        [report_cfg setIncRSSI:YES]; [report_cfg setIncTagSeenCount:NO];
        [report_cfg setIncFirstSeenTime:NO];
        [report_cfg setIncLastSeenTime:NO];
        /* configure access parameters to perform the operation with 27.0 dbm antenna power
         level without application of pre-filters */
        [access_cfg setPower:270];
        [access_cfg setDoSelect:NO];
        /* request performing of inventory operation with reading from EPC memory bank */
        result = [apiInstance srfidStartInventory:activeReaderId
                                      aMemoryBank:SRFID_MEMORYBANK_EPC
                                    aReportConfig:report_cfg
                                    aAccessConfig:access_cfg
                                   aStatusMessage:&error_response];
        if (SRFID_RESULT_SUCCESS == result) {
            NSLog(@"Request succeed\n");
            //            /* request abort of an operation after 1 minute */
            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                //[apiInstance srfidStopInventory:activeReaderId aStatusMessage:nil];
            //                [self stopInventory];
            //            });
        }
        else if (SRFID_RESULT_RESPONSE_ERROR == result) {
            errorMessage = [NSString stringWithFormat:@"Failed to start inventory: %@", srfidResultString(result)];
        }
        else {
            errorMessage = @"Request failed";
        }
    } while (0);
    //[start_trigger_cfg release];
    //[stop_trigger_cfg release];
    //[access_cfg release];
    //[report_cfg release];
    
    if( errorMessage != nil ) {
        NSLog(@"%@\n", errorMessage);
        return errorMessage;
    } else {
        return SRFID_RESULT_SUCCESS;
    }
    
}

@end
