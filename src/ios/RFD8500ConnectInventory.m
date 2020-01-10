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

    // START set region configuration
        SRFID_RESULT r_result;
        NSString *r_error_response = nil;
        NSString *region_code = @"DEU";
        NSMutableArray *enabled_channels = [[NSMutableArray alloc] init];
        SRFID_HOPPINGCONFIG hopping_on = SRFID_HOPPINGCONFIG_DISABLED;
        srfidRegulatoryConfig *regulatory_cfg = [[srfidRegulatoryConfig alloc] init];

    /* allocate object for storage of supported channels information */
     NSMutableArray *supported_channels = [[NSMutableArray alloc] init];
     BOOL hopping_configurable = NO;

     /* retrieve detailed information about region specified by region code */
    r_result = [apiInstance srfidGetRegionInfo:activeReaderId aRegionCode:region_code
       aSupportedChannels:&supported_channels aHoppingConfigurable:&hopping_configurable
       aStatusMessage:&r_error_response];

       if (SRFID_RESULT_SUCCESS == r_result) {
     /* region information received */

     if (YES == hopping_configurable) {
     /* region supports hopping */
     /* enable first and last channels from the set of supported channels */
     [enabled_channels addObject:[supported_channels firstObject]];
     [enabled_channels addObject:[supported_channels lastObject]];
     /* enable hopping */
     hopping_on = SRFID_HOPPINGCONFIG_ENABLED;
       }
     else {
     /* region does not support hopping */
     /* request to not configure hopping */
     hopping_on = SRFID_HOPPINGCONFIG_DEFAULT;
       }
       }

       //[supported_channels release];
       r_error_response = nil;

       /* configure regulatory parameters to be set */
       regulatory_cfg = [[srfidRegulatoryConfig alloc] init];
       [regulatory_cfg setRegionCode:region_code];
       [regulatory_cfg setEnabledChannelsList:enabled_channels];
       [regulatory_cfg setHoppingConfig:hopping_on];

       /* set regulatory parameters */
       r_result = [apiInstance srfidSetRegulatoryConfig:activeReaderId
       aRegulatoryConfig:regulatory_cfg aStatusMessage:&r_error_response];
       if (SRFID_RESULT_SUCCESS == r_result) {
     /* regulatory configuration applied */
     NSLog(@"Tag report configuration has been set\n");
       }
       else if (SRFID_RESULT_RESPONSE_ERROR == r_result) {
     NSLog(@"Error response from RFID reader: %@\n", r_error_response);
       }
       else {
     NSLog(@"Failed to set regulatory parameters\n");
       }
       //[enabled_channels release];
       //[regulatory_cfg release];
        // END set region configuration

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
