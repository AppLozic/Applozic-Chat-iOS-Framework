//
//  ALGroupUser.m
//  Applozic
//
//  Created by Sunil on 14/02/18.
//  Copyright © 2018 applozic Inc. All rights reserved.
//

#import "ALGroupUser.h"

@implementation ALGroupUser
    
-(id)initWithDictonary:(NSDictionary *)messageDictonary
    {
        [self parseMessage:messageDictonary];
        return self;
    }
    
-(void)parseMessage:(id) messageJson
    {
        self.groupRole = [self getNSNumberFromJsonValue:messageJson[@"groupRole"]];
        self.userId = [self getStringFromJsonValue:messageJson[@"userId"]];
    }


@end
