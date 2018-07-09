//
//  ALConversationDBService.h
//  Applozic
//
//  Created by Devashish on 27/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DB_ConversationProxy.h"
#import "ALConversationProxy.h"

@interface ALConversationDBService : NSObject


-(void)insertConversationProxy:(NSMutableArray *)proxyArray;

-(DB_ConversationProxy *)createConversationProxy:(ALConversationProxy *)conversationProxy;

-(DB_ConversationProxy *)getConversationProxyByKey:(NSNumber *)Id;

-(NSArray*)getConversationProxyListFromDBForUserID:(NSString*)userId;
-(NSArray*)getConversationProxyListFromDBWithChannelKey:(NSNumber *)channelKey;

-(void)insertConversationProxyTopicDetails:(NSMutableArray*)proxyArray;

-(NSArray*)getConversationProxyListFromDBForUserID:(NSString*)userId andTopicId:(NSString*)topicId;

@end