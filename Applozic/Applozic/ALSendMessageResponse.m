//
//  ALSendMessageResponse.m
//  Applozic
//
//  Created by Devashish on 06/11/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALSendMessageResponse.h"

@implementation ALSendMessageResponse


-(id)initWithJSONString:(NSString *)JSONString
{
    [self parseMessage:JSONString];
    return self;
}

-(void)parseMessage:(id) json;
{
    self.messageKey = [self getStringFromJsonValue:json[@"messageKey"]];
    self.createdAt = [self getNSNumberFromJsonValue:json[@"createdAt"]];
    self.conversationId =  [self getNSNumberFromJsonValue:json[@"conversationId"]];
    
}


-(BOOL)isSuccess{
    
    return (self.messageKey && self.createdAt);
}

@end
