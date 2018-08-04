//
//  ALUserService.h
//  Applozic
//
//  Created by Divjyot Singh on 05/11/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALConstant.h"
#import "ALSyncMessageFeed.h"
#import "ALMessageList.h"
#import "ALMessage.h"
#import "DB_FileMetaInfo.h"
#import "ALLastSeenSyncFeed.h"
#import "ALUserClientService.h"
#import "ALAPIResponse.h"
#import "ALUserBlockResponse.h"

@interface ALUserService : NSObject

+(void)processContactFromMessages:(NSArray *) messagesArr withCompletion:(void(^)())completionMark;

+(void)getLastSeenUpdateForUsers:(NSNumber *)lastSeenAt withCompletion:(void(^)(NSMutableArray *))completionMark;

+(void)userDetailServerCall:(NSString *)contactId withCompletion:(void(^)(ALUserDetail *))completionMark;

+(void)updateUserDisplayName:(ALContact *)alContact;

+(void)markConversationAsRead:(NSString *)contactId withCompletion:(void (^)(NSString *, NSError *))completion;

+(void)markMessageAsRead:(ALMessage *)alMessage withPairedkeyValue:(NSString *)pairedkeyValue withCompletion:(void (^)(NSString *, NSError *))completion;

-(void)blockUser:(NSString *)userId withCompletionHandler:(void(^)(NSError *error, BOOL userBlock))completion;

-(void)blockUserSync:(NSNumber *)lastSyncTime;

-(void)unblockUser:(NSString *)userId withCompletionHandler:(void(^)(NSError *error, BOOL userUnblock))completion;

-(void)updateBlockUserStatusToLocalDB:(ALUserBlockResponse *)userblock;

-(NSMutableArray *)getListOfBlockedUserByCurrentUser;

+(void)setUnreadCountZeroForContactId:(NSString*)contactId;

-(void)getListOfRegisteredUsersWithCompletion:(void(^)(NSError * error))completion;

-(void)fetchOnlineContactFromServer:(void(^)(NSMutableArray * array, NSError * error))completion;

-(NSNumber *)getTotalUnreadCount;

-(void)resettingUnreadCountWithCompletion:(void (^)(NSString *json, NSError *error))completion;

-(void)updateUserDisplayName:(NSString *)displayName andUserImage:(NSString *)imageLink userStatus:(NSString *)status
              withCompletion:(void (^)(id theJson, NSError * error))completion;

+(void)updateUserDetail:(NSString *)userId withCompletion:(void(^)(ALUserDetail *userDetail))completionMark;

-(void) fetchAndupdateUserDetails:(NSMutableArray *)userArray withCompletion:(void (^)(NSMutableArray * array, NSError *error))completion;

-(void)getUserDetail:(NSString*)userId withCompletion:(void(^)(ALContact *contact))completion;

-(void)updateUserApplicationInfo;

-(void)updatePassword:(NSString*)oldPassword withNewPassword :(NSString *) newPassword withCompletion:(void(^)( ALAPIResponse* alAPIResponse, NSError *theError))completion;

@end
