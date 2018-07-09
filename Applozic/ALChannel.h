//
//  ALChannel.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//  this clss will decide wether go client or groupdb service

#import <Foundation/Foundation.h>
#import <CoreData/NSManagedObject.h>
#import "ALJson.h"
#import "ALConversationProxy.h"

#define CHANNEL_SPECIAL_CASE 7
#define CHANNEL_DEFAULT_MUTE @"MUTE"
#define CHANNEL_CONVERSATION_STATUS @"CONVERSATION_STATUS"


/*********************
 type = 7 SPECIAL CASE
*********************/

typedef enum
{
    VIRTUAL = 0,
    PRIVATE = 1,
    PUBLIC = 2,
    SELLER = 3,
    SELF = 4,
    BROADCAST = 5,
    OPEN = 6,
    GROUP_OF_TWO = 7,
    CONTACT_GROUP = 9,
    BROADCAST_ONE_BY_ONE = 106
} CHANNEL_TYPE;


@interface ALChannel : ALJson

@property (nonatomic, strong) NSNumber *key;
@property (nonatomic, strong) NSString *clientChannelKey;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *channelImageURL;
@property (nonatomic, strong) NSString *adminKey;
@property (nonatomic) short type;
@property (nonatomic, strong) NSNumber *userCount;
@property (nonatomic, strong) NSNumber *unreadCount;
@property (nonatomic, copy) NSManagedObjectID *channelDBObjectId;
@property (nonatomic, strong) NSMutableArray *membersName;
@property (nonatomic, strong) NSMutableArray *membersId;
@property (nonatomic, strong) NSMutableArray *removeMembers;
@property (nonatomic, strong) ALConversationProxy *conversationProxy;
@property (nonatomic, strong) NSNumber *parentKey;
@property (nonatomic, strong) NSString *parentClientKey;
@property (nonatomic, strong) NSMutableArray * groupUsers;
@property (nonatomic, strong) NSMutableArray * childKeys;
@property (nonatomic, strong) NSNumber * notificationAfterTime;
@property (nonatomic, strong) NSNumber * deletedAtTime;
@property (nonatomic, strong) NSMutableDictionary * metadata;

-(id)initWithDictonary:(NSDictionary *)messageDictonary;
-(void)parseMessage:(id) messageJson;
-(NSNumber *)getChannelMemberParentKey:(NSString *)userId;
-(BOOL) isNotificationMuted;
-(BOOL) isConversationClosed;

-(NSString*)getReceiverIdInGroupOfTwo;

-(NSMutableDictionary *)getMetaDataDictionary:(NSString *)string;

@end
