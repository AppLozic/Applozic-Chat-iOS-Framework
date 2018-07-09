//
//  ALRegistrationResponse.m
//  ChatApp
//
//  Created by devashish on 18/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALRegistrationResponse.h"

@implementation ALRegistrationResponse


- (id)initWithJSONString:(NSString *)registrationResponse
{
    //TODO: Right now error is coming super initWithJSONString, so overriding it...once fixed remove this
    self.message = [registrationResponse valueForKey:@"message"];
    self.deviceKey = [registrationResponse valueForKey:@"deviceKey"];
    self.userKey = [registrationResponse valueForKey:@"userKey"];
    self.displayName = [registrationResponse valueForKey:@"displayName"];
    self.contactNumber = [registrationResponse valueForKey:@"contactNumber"];
    self.lastSyncTime = [registrationResponse valueForKey:@"lastSyncTime"];
    self.currentTimeStamp = [registrationResponse valueForKey:@"currentTimeStamp"];
    self.brokerURL = [registrationResponse valueForKey:@"brokerUrl"];
    self.statusMessage = [registrationResponse valueForKey:@"statusMessage"];
    self.imageLink = [registrationResponse valueForKey:@"imageLink"];
    self.encryptionKey = [registrationResponse valueForKey:@"encryptionKey"];
    self.pricingPackage = [[registrationResponse valueForKey:@"pricingPackage"] shortValue];
    self.notificationSoundFileName = [registrationResponse valueForKey:@"notificationSoundFileName"];
    self.metadata = [[NSMutableDictionary  alloc] initWithDictionary: [registrationResponse valueForKey:@"metadata"]];
    self.roleType = [[registrationResponse valueForKey:@"roleType"] shortValue];
    return self;
}

-(BOOL)isRegisteredSuccessfully
{
    if ([self.message isEqualToString:@"REGISTERED"]
        || [self.message isEqualToString:@"REGISTERED.WITHOUTREGISTRATIONID"]
        ||  [self.message isEqualToString:@"UPDATED"]) {
        
        return YES;
    }
    return NO;
}

@end
