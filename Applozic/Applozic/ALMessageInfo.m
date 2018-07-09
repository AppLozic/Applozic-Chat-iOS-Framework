//
//  ALMessageInfo.m
//  Applozic
//
//  Created by devashish on 17/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALMessageInfo.h"

@implementation ALMessageInfo

-(id)initWithDictonary:(NSDictionary *)messageDictonary
{
    [self parseMessage:messageDictonary];
    return self;
}

-(void)parseMessage:(id) messageJson
{
    self.userId = [self getStringFromJsonValue:messageJson[@"userId"]];
    self.messageStatus = [self getShortFromJsonValue:messageJson[@"status"]];
    self.deliveredAtTime = [self getNSNumberFromJsonValue:messageJson[@"deliveredAtTime"]];
    self.readAtTime = [self getNSNumberFromJsonValue:messageJson[@"readAtTime"]];
}


@end
