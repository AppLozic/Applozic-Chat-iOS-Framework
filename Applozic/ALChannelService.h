//
//  ALChannelService.h
//  Applozic
//
//  Created by devashish on 04/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#define AL_CREATE_GROUP_MESSAGE @"CREATE_GROUP_MESSAGE"
#define AL_REMOVE_MEMBER_MESSAGE @"REMOVE_MEMBER_MESSAGE"
#define AL_ADD_MEMBER_MESSAGE @"ADD_MEMBER_MESSAGE"
#define AL_JOIN_MEMBER_MESSAGE @"JOIN_MEMBER_MESSAGE"
#define AL_GROUP_NAME_CHANGE_MESSAGE @"GROUP_NAME_CHANGE_MESSAGE"
#define AL_GROUP_ICON_CHANGE_MESSAGE @"GROUP_ICON_CHANGE_MESSAGE"
#define AL_GROUP_LEFT_MESSAGE @"GROUP_LEFT_MESSAGE"
#define AL_DELETED_GROUP_MESSAGE @"DELETED_GROUP_MESSAGE"

#import <Foundation/Foundation.h>
#import "ALChannelFeed.h"
#import "ALChannelDBService.h"
#import "ALChannelClientService.h"
#import "ALUserDefaultsHandler.h"
#import "ALChannelSyncResponse.h"
#import "AlChannelFeedResponse.h"


@interface ALChannelService : NSObject

-(void)callForChannelServiceForDBInsertion:(id)theJson;

-(void)getChannelInformation:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withCompletion:(void (^)(ALChannel *alChannel3)) completion;

-(ALChannel *)getChannelByKey:(NSNumber *)channelKey;

-(NSMutableArray *)getListOfAllUsersInChannel:(NSNumber *)channelKey;

-(NSString *)stringFromChannelUserList:(NSNumber *)key;

-(void)getChannelInformationByResponse:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withCompletion:(void (^)(NSError *error,ALChannel *alChannel3,AlChannelFeedResponse *channelResponse)) completion;


-(void)createChannel:(NSString *)channelName orClientChannelKey:(NSString *)clientChannelKey
      andMembersList:(NSMutableArray *)memberArray andImageLink:(NSString *)imageLink
      withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion;

-(void)createChannel:(NSString *)channelName orClientChannelKey:(NSString *)clientChannelKey andMembersList:(NSMutableArray *)memberArray
        andImageLink:(NSString *)imageLink channelType:(short)type andMetaData:(NSMutableDictionary *)metaData
      withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion;

-(void)createChannel:(NSString *)channelName andParentChannelKey:(NSNumber *)parentChannelKey orClientChannelKey:(NSString *)clientChannelKey
      andMembersList:(NSMutableArray *)memberArray andImageLink:(NSString *)imageLink channelType:(short)type
         andMetaData:(NSMutableDictionary *)metaData withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion;

-(void)createChannel:(NSString *)channelName orClientChannelKey:(NSString *)clientChannelKey
      andMembersList:(NSMutableArray *)memberArray andImageLink:(NSString *)imageLink channelType:(short)type
         andMetaData:(NSMutableDictionary *)metaData adminUser:(NSString *)adminUserId withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion;

-(void)createChannel:(NSString *)channelName andParentChannelKey:(NSNumber *)parentChannelKey orClientChannelKey:(NSString *)clientChannelKey
      andMembersList:(NSMutableArray *)memberArray andImageLink:(NSString *)imageLink channelType:(short)type
         andMetaData:(NSMutableDictionary *)metaData  adminUser:(NSString *)adminUserId withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion;


-(void)addMemberToChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey
           withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

-(void)removeMemberFromChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey
                withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

-(void)deleteChannel:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey
      withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

-(BOOL)checkAdmin:(NSNumber *)channelKey;

-(void)leaveChannel:(NSNumber *)channelKey andUserId:(NSString *)userId orClientChannelKey:(NSString *)clientChannelKey
     withCompletion:(void(^)(NSError *error))completion;

-(void)addMultipleUsersToChannel:(NSMutableArray* )channelKeys channelUsers:(NSMutableArray *)channelUsers andCompletion:(void(^)(NSError * error))completion;

-(void)syncCallForChannel;

-(void)updateChannel:(NSNumber *)channelKey andNewName:(NSString *)newName andImageURL:(NSString *)imageURL orClientChannelKey:(NSString *)clientChannelKey
  isUpdatingMetaData:(BOOL)flag metadata:(NSMutableDictionary *)metaData orChildKeys:(NSMutableArray *)childKeysList orChannelUsers:(NSMutableArray *)channelUsers withCompletion:(void(^)(NSError *error))completion;

+(void)markConversationAsRead:(NSNumber *)channelKey withCompletion:(void (^)(NSString *, NSError *))completion;

-(BOOL)isChannelLeft:(NSNumber*)groupID;

+(BOOL)isChannelDeleted:(NSNumber *)groupId;

+(BOOL)isConversationClosed:(NSNumber *)groupId;

+(void)closeGroupConverstion :(NSNumber *) groupId  withCompletion:(void(^)(NSError *error))completion ;

+(BOOL)isChannelMuted:(NSNumber *)groupId;

+(void)setUnreadCountZeroForGroupID:(NSNumber*)channelKey;

-(NSNumber *)getOverallUnreadCountForChannel;

-(ALChannel *)fetchChannelWithClientChannelKey:(NSString *)clientChannelKey;

-(BOOL)isLoginUserInChannel:(NSNumber *)channelKey;

-(NSMutableArray *)getAllChannelList;

-(NSMutableArray *)fetchChildChannelsWithParentKey:(NSNumber *)parentGroupKey;

-(void)processChildGroups:(ALChannel *)alChannel;

-(void)addChildKeyList:(NSMutableArray *)childKeyList andParentKey:(NSNumber *)parentKey
        withCompletion:(void(^)(id json, NSError *error))completion;

-(void)removeChildKeyList:(NSMutableArray *)childKeyList andParentKey:(NSNumber *)parentKey
           withCompletion:(void(^)(id json, NSError *error))completion;

-(void)addClientChildKeyList:(NSMutableArray *)clientChildKeyList andParentKey:(NSString *)clientParentKey
              withCompletion:(void(^)(id json, NSError *error))completion;

-(void)removeClientChildKeyList:(NSMutableArray *)clientChildKeyList andParentKey:(NSString *)clientParentKey
                 withCompletion:(void(^)(id json, NSError *error))completion;

-(void)muteChannel:(ALMuteRequest *)muteRequest withCompletion:(void(^)(ALAPIResponse * response, NSError *error))completion;

-(void)createBroadcastChannelWithMembersList:(NSMutableArray *)memberArray
                                 andMetaData:(NSMutableDictionary *)metaData
                              withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion;

-(ALChannelUserX *)loadChannelUserX:(NSNumber *)channelKey;

-(void)getChannelInfoByIdsOrClientIds:(NSMutableArray*)channelIds
                   orClinetChannelIds:(NSMutableArray*) clientChannelIds
                       withCompletion:(void(^)(NSMutableArray* channelInfoList, NSError *error))completion;

-(void)getChannelListForCategory:(NSString*)category
                  withCompletion:(void(^)(NSMutableArray * channelInfoList, NSError * error))completion;


-(void)getAllChannelsForApplications:(NSNumber*)endTime withCompletion:(void(^)(NSMutableArray * channelInfoList, NSError * error))completion;


+(void) addMemberToContactGroupOfType:(NSString*) contactsGroupId withMembers: (NSMutableArray *)membersArray withGroupType :(short) groupType withCompletion:(void(^)(ALAPIResponse * response, NSError * error))completion;

+(void) addMemberToContactGroup:(NSString*) contactsGroupId withMembers:(NSMutableArray *)membersArray  withCompletion:(void(^)(ALAPIResponse * response, NSError * error))completion;

+(void) getMembersFromContactGroupOfType:(NSString *)contactGroupId  withGroupType :(short) groupType withCompletion:(void(^)(NSError *error, ALChannel *channel)) completion;

-(NSMutableArray *)getListOfAllUsersInChannelByNameForContactsGroup:(NSString *)channelName;

+(void) removeMemberFromContactGroup:(NSString*) contactsGroupId withUserId :(NSString*) userId  withCompletion:(void(^)(ALAPIResponse * response, NSError * error))completion;

+(void) removeMemberFromContactGroupOfType:(NSString*) contactsGroupId  withGroupType:(short) groupType withUserId :(NSString*) userId  withCompletion:(void(^)(ALAPIResponse * response, NSError * error))completion;

+(void)getMembersIdsForContactGroups:(NSArray*)contactGroupIds withCompletion:(void(^)(NSError *error, NSArray *membersArray)) completion;

-(void)createChannel:(NSString *)channelName orClientChannelKey:(NSString *)clientChannelKey
      andMembersList:(NSMutableArray *)memberArray andImageLink:(NSString *)imageLink channelType:(short)type
         andMetaData:(NSMutableDictionary *)metaData adminUser:(NSString *)adminUserId withGroupUsers : (NSMutableArray*) groupRoleUsers withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion;
@end
