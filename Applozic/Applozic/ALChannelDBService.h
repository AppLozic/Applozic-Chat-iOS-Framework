//
//  ALChannelDBService.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//  class for databse actios for group

#import <Foundation/Foundation.h>
#import "ALChannel.h"
#import "DB_CHANNEL.h"
#import "DB_CHANNEL_USER_X.h"
#import "ALDBHandler.h"
#import "ALChannelUserX.h"
#import "ALConversationProxy.h"
#import "DB_ConversationProxy.h"
#import "ALApplozicSettings.h"

@interface ALChannelDBService : NSObject

-(void)createChannel:(ALChannel *)channel;

-(void)addMemberToChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey;

-(void)insertChannel:(NSMutableArray *)channelList;

-(DB_CHANNEL *) createChannelEntity:(ALChannel *)channel;

-(void)insertChannelUserX:(NSMutableArray *)channelUserX;

-(DB_CHANNEL_USER_X *)createChannelUserXEntity:(ALChannelUserX *)channelUserXList;

-(NSMutableArray *)getChannelMembersList:(NSNumber *)channelKey;

-(ALChannel *)loadChannelByKey:(NSNumber *)key;

-(DB_CHANNEL *)getChannelByKey:(NSNumber *)key;

-(NSString *)stringFromChannelUserList:(NSNumber *)key;

-(ALChannel *)checkChannelEntity:(NSNumber *)channelKey;

-(void)removeMemberFromChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey;

-(void)deleteChannel:(NSNumber *)channelKey;

-(NSMutableArray*)getAllChannelKeyAndName;

-(void)updateChannel:(NSNumber *)channelKey andNewName:(NSString *)newName orImageURL:(NSString *)imageURL orChildKeys:(NSMutableArray *)childKeysList isUpdatingMetaData:(BOOL)flag  orChannelUsers:(NSMutableArray *)channelUsers;

-(void)processArrayAfterSyncCall:(NSMutableArray *)channelArray;

-(NSMutableArray *)getListOfAllUsersInChannel:(NSNumber *)key;
//New Added...
-(NSUInteger)markConversationAsRead:(NSNumber*)channelKey;

-(NSArray *)getUnreadMessagesForGroup:(NSNumber*)groupId;

-(void)updateUnreadCountChannel:(NSNumber *)channelKey unreadCount:(NSNumber *)unreadCount;

-(void)setLeaveFlag:(BOOL)flag forChannel:(NSNumber *)groupId;

-(BOOL)isChannelLeft:(NSNumber *)groupId;

-(BOOL)isChannelDeleted:(NSNumber *)groupId;
-(BOOL)isConversaionClosed:(NSNumber *)groupId;

-(void) updateChannelParentKey:(NSNumber *)channelKey
              andWithParentKey:(NSNumber *)channelParentKey isAdding:(BOOL)flag;

-(void)updateClientChannelParentKey:(NSString *)clientChildKey
                   andWithClientParentKey:(NSString *)clientParentKey isAdding:(BOOL)flag;

-(NSNumber *)getOverallUnreadCountForChannelFromDB;

-(ALChannel *)loadChannelByClientChannelKey:(NSString *)clientChannelKey;

-(void)removedMembersArray:(NSMutableArray *)memberArray andChannelKey:(NSNumber *)channelKey;

-(void)addedMembersArray:(NSMutableArray *)memberArray andChannelKey:(NSNumber *)channelKey;

-(NSMutableArray *)fetchChildChannels:(NSNumber *)parentGroupKey;

-(void)updateMuteAfterTime:(NSNumber*)notificationAfterTime andChnnelKey:(NSNumber*)channelKey;


-(DB_CHANNEL_USER_X *)getChannelUserX:(NSNumber *)channelKey;

-(ALChannelUserX *)loadChannelUserX:(NSNumber *)channelKey;

-(ALChannelUserX *)loadChannelUserXByUserId:(NSNumber *)channelKey andUserId:(NSString *)userId;


-(void)updateParentKeyInChannelUserX:(NSNumber *)channelKey andWithParentKey:(NSNumber *)parentKey addUserId :(NSString *) userId;


-(void)updateRoleInChannelUserX:(NSNumber *)channelKey andUserId:(NSString *)userId withRoleType:(NSNumber*)role;

-(NSMutableArray *)getListOfAllUsersInChannelByNameForContactsGroup:(NSString *)channelName;

-(DB_CHANNEL *)getContactsGroupChannelByName:(NSString *)channelName;

@end
