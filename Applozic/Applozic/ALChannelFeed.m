//
//  ALChannelFeed.m
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALChannelFeed.h"
#import "ALConversationProxy.h"

@implementation ALChannelFeed

-(id)initWithJSONString:(NSString *)JSONString
{
    [self parseMessage:JSONString];
    return self;
}

-(void)parseMessage:(id) json;
{
    NSMutableArray * theChannelFeedArray = [NSMutableArray new];
    
    NSDictionary * theChannelFeedDict = [json valueForKey:@"groupFeeds"];
    for (NSDictionary * theDictionary in theChannelFeedDict) {
        ALChannel *alChannel = [[ALChannel alloc] initWithDictonary:theDictionary];
        [theChannelFeedArray addObject:alChannel];
    }
    self.channelFeedsList = theChannelFeedArray;
    
    
    NSMutableArray * theConversationProxyArray = [NSMutableArray new];
    
    NSDictionary * theConversationProxyDict = [json valueForKey:@"conversationPxys"];
    for (NSDictionary * theDictionary in theConversationProxyDict) {
        ALConversationProxy *conversationProxy = [[ALConversationProxy alloc] initWithDictonary:theDictionary];
        [theConversationProxyArray addObject:conversationProxy];
    }
    self.conversationProxyList = theConversationProxyArray;
}

@end
