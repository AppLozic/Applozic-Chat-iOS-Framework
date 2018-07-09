//
//  ALDataNetworkConnection.m
//  Applozic
//
//  Created by devashish on 02/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALDataNetworkConnection.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "TSMessage.h"

@interface ALDataNetworkConnection ()

@end

@implementation ALDataNetworkConnection

+(BOOL)checkDataNetworkAvailable
{
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef address;
    address = SCNetworkReachabilityCreateWithName(NULL, "www.google.com" );
    Boolean success = SCNetworkReachabilityGetFlags(address, &flags);
    CFRelease(address);
    
    bool canReach = success
    && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)
    && (flags & kSCNetworkReachabilityFlagsReachable);
    
    if(canReach)
    {
        NSLog(@"NETWORK AVAILABLE");
    }
    else
    {
        NSLog(@"NETWORK ISN'T AVAILABLE");
    }
    
    return canReach;
}

+(BOOL)noInternetConnectionNotification
{
    if(![ALDataNetworkConnection checkDataNetworkAvailable])
    {
        [TSMessage showNotificationWithTitle:@"Unable to connect to Internet" type:TSMessageNotificationTypeError];
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
