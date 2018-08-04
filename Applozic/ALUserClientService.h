//
//  ALUserClientService.h
//  Applozic
//
//  Created by Devashish on 21/12/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALLastSeenSyncFeed.h"
#import "ALContact.h"
#import "ALContactsResponse.h"
#import "ALUserDetailListFeed.h"
#import "AlApplicationInfoFeed.h"
#import "ALAPIResponse.h"

@interface ALUserClientService : NSObject

+(void)userLastSeenDetail:(NSNumber *)lastSeenAt withCompletion:(void(^)(ALLastSeenSyncFeed *))completionMark;

-(void)userDetailServerCall:(NSString *)contactId withCompletion:(void(^)(ALUserDetail *))completionMark;

-(void)updateUserDisplayName:(ALContact *)alContact withCompletion:(void(^)(id theJson, NSError *theError))completion;

-(void)markConversationAsReadforContact:(NSString *)contactId withCompletion:(void (^)(NSString *, NSError *))completion;

+(void)userBlockServerCall:(NSString *)userId withCompletion:(void (^)(NSString *json, NSError *error))completion;

+(void)userBlockSyncServerCall:(NSNumber *)lastSyncTime withCompletion:(void (^)(NSString *json, NSError *error))completion;

+(void)userUnblockServerCall:(NSString *)userId withCompletion:(void (^)(NSString *json, NSError *error))completion;

-(void)markMessageAsReadforPairedMessageKey:(NSString *)pairedMessageKey withCompletion:(void (^)(NSString *, NSError *))completion;

+(void)multiUserSendMessage:(NSDictionary *)messageDictionary
                 toContacts:(NSMutableArray*)contactIdsArray
                   toGroups:(NSMutableArray*)channelKeysArray
             withCompletion:(void (^)(NSString *json, NSError *error))completion;

-(void)getListOfRegisteredUsers:(NSNumber *)startTime
                    andPageSize:(NSUInteger)pageSize withCompletion:(void(^)(ALContactsResponse * response, NSError * error))completion;

-(void)fetchOnlineContactFromServer:(NSUInteger)limit withCompletion:(void (^)(id json, NSError * error))completion;

-(void)subProcessUserDetailServerCall:(NSString *)paramString withCompletion:(void(^)(NSMutableArray * userDetailArray, NSError * error))completionMark;

+(void)readCallResettingUnreadCountWithCompletion:(void (^)(NSString *json, NSError *error))completion;

-(void)updateUserDisplayName:(NSString *)displayName andUserImageLink:(NSString *)imageLink userStatus:(NSString *)status
              withCompletion:(void (^)(id theJson, NSError * error))completionHandler;

-(void)subProcessUserDetailServerCallPOST:(ALUserDetailListFeed *)ob withCompletion:(void(^)(NSMutableArray * userDetailArray, NSError * theError))completionMark;

-(void) updateApplicationInfoDeatils:(AlApplicationInfoFeed *)applicationInfoDeatils withCompletion:(void (^)(NSString *json, NSError *error))completion;


-(void)updatePassword:(NSString*)oldPassword withNewPassword :(NSString *) newPassword  withCompletion:(void (^)(ALAPIResponse *apiResponse, NSError *error))completion;

@end
