//
//  ALMessageClientService.h
//  ChatApp
//
//  Created by devashish on 02/10/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALMessage.h"
#import "ALMessageList.h"
#import "ALSyncMessageFeed.h"
#import "MessageListRequest.h"
#import "ALMessageInfoResponse.h"
#import "ALMessageService.h"

@interface ALMessageClientService : NSObject

-(void)updateDeliveryReports:(NSMutableArray *)messages;

-(void)updateDeliveryReport:(NSString *)key;

-(void)addWelcomeMessage:(NSNumber *)channelKey;

-(void)getLatestMessageGroupByContact:(NSUInteger)mainPageSize startTime:(NSNumber *)startTime
                        withCompletion:(void(^)(ALMessageList * alMessageList, NSError * error))completion;

-(void)getMessagesListGroupByContactswithCompletion:(void(^)(NSMutableArray * messages, NSError * error)) completion;

-(void)getMessageListForUser:(MessageListRequest *)messageListRequest withCompletion:(void (^)(NSMutableArray *, NSError *, NSMutableArray *))completion;

-(void)sendPhotoForUserInfo:(NSDictionary *)userInfo withCompletion:(void(^)(NSString * message, NSError *error)) completion;

-(void)getLatestMessageForUser:(NSString *)deviceKeyString withCompletion:(void (^)(ALSyncMessageFeed *, NSError *))completion;

-(void)deleteMessage:(NSString *)keyString andContactId:(NSString *)contactId withCompletion:(void (^)(NSString *, NSError *))completion;

-(void)deleteMessageThread:(NSString *)contactId orChannelKey:(NSNumber *)channelKey withCompletion:(void (^)(NSString *, NSError *))completion;

-(void)sendMessage:(NSDictionary *)userInfo WithCompletionHandler:(void(^)(id theJson, NSError *theError))completion;

-(void)getCurrentMessageInformation:(NSString *)messageKey withCompletionHandler:(void(^)(ALMessageInfoResponse *msgInfo, NSError *theError))completion;

-(void)getMessageListForUser:(MessageListRequest *)messageListRequest withOpenGroup:(BOOL)isOpenGroup withCompletion:(void (^)(NSMutableArray *, NSError *, NSMutableArray *))completion;

@end
