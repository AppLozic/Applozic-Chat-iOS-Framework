//
//  ALMessageList.m
//  ChatApp
//
//  Created by Devashish on 22/09/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALMessageList.h"
#import "ALMessage.h"
#import "ALUserDetail.h"
#import "ALChannel.h"
#import "ALUserDefaultsHandler.h"

@implementation ALMessageList


- (id)initWithJSONString:(NSString *)syncMessageResponse {
    
    [self parseMessagseArray:syncMessageResponse];
   // NSLog(@"message response from server....###%@" , syncMessageResponse );
    return self;
}

- (id)initWithJSONString:(NSString *)syncMessageResponse andWithUserId:(NSString*)userId andWithGroup:(NSNumber*)groupId{
    
    self.groupId =groupId;
    self.userId=userId;
    [self parseMessagseArray:syncMessageResponse];
    return self;
}

-(void)parseMessagseArray:(id) messagejson
{
    NSMutableArray * theMessagesArray = [NSMutableArray new];
    NSMutableArray * theUserDetailArray = [NSMutableArray new];
    NSMutableArray * conversationProxyList = [NSMutableArray new];

    NSDictionary * theMessageDict = [messagejson valueForKey:@"message"];
    NSLog(@"MESSAGES_DICT_COUNT :: %lu",(unsigned long)theMessageDict.count);
    if(theMessageDict.count ==0)
    {
        NSLog(@"NO_MORE_MESSAGES");
        [ALUserDefaultsHandler setFlagForAllConversationFetched: YES];
    }
    
    for (NSDictionary * theDictionary in theMessageDict)
    {
        ALMessage *message = [[ALMessage alloc] initWithDictonary:theDictionary];
        [theMessagesArray addObject:message];
    }
    self.messageList = theMessagesArray;
    
    NSDictionary * theUserDetailsDict = [messagejson valueForKey:@"userDetails"];

    for (NSDictionary * theDictionary in theUserDetailsDict)
    {
        ALUserDetail * alUserDetail = [[ALUserDetail alloc] initWithDictonary:theDictionary];
        [theUserDetailArray addObject:alUserDetail];
    }
    
    NSDictionary * theConversationProxyDict = [messagejson valueForKey:@"conversationPxys"];
    
    for (NSDictionary * theDictionary in theConversationProxyDict)
    {
        ALConversationProxy *conversationProxy = [[ALConversationProxy alloc] initWithDictonary:theDictionary];
        conversationProxy.userId = self.userId;
        conversationProxy.groupId = self.groupId;
        [conversationProxyList addObject:conversationProxy];
    }
    
    self.conversationPxyList = conversationProxyList;
    self.userDetailsList = theUserDetailArray;
    
    ALMessage * lastMessage = (ALMessage *)[theMessagesArray lastObject];
    [ALUserDefaultsHandler setLastMessageListTime:lastMessage.createdAtTime];
    
}



@end
