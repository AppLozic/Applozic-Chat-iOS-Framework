//
//  ALTopicDetail.m
//  Applozic
//
//  Created by Devashish on 27/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALTopicDetail.h"

@implementation ALTopicDetail

-(id)initWithDictonary:(NSDictionary *)messageDictonary
{
    [self parseMessage:messageDictonary];
    return self;
}

-(void)parseMessage:(id) messageJson
{
    self.title = [self getStringFromJsonValue:messageJson[@"title"]];
    self.subtitle = [self getStringFromJsonValue:messageJson[@"subtitle"]];
    self.pId = [self getStringFromJsonValue:messageJson[@"PID"]];
    self.link = [self getStringFromJsonValue:messageJson[@"link"]];
    self.key1 =  [self getStringFromJsonValue:messageJson[@"key1"]];
    self.value1 = [self getStringFromJsonValue:messageJson[@"value1"]];
    self.key2 = [self getStringFromJsonValue:messageJson[@"key2"]];
    self.value2 = [self getStringFromJsonValue:messageJson[@"value2"]];

}


@end
