//
//  ALMQTTConversationService.h
//  Applozic
//
//  Created by Applozic Inc on 11/27/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTClient.h"
#import "ALMessage.h"
#import "ALUserDetail.h"
#import "ALSyncCallService.h"

@protocol ALMQTTConversationDelegate <NSObject>

-(void) syncCall:(ALMessage *) alMessage andMessageList:(NSMutableArray *)messageArray;
-(void) delivered:(NSString *) messageKey contactId:(NSString *)contactId withStatus:(int)status;
-(void) updateStatusForContact:(NSString *)contactId  withStatus:(int)status;
-(void) updateTypingStatus: (NSString *) applicationKey userId: (NSString *) userId status: (BOOL) status;
-(void) updateLastSeenAtStatus: (ALUserDetail *) alUserDetail;
-(void) mqttConnectionClosed;

@optional

-(void) mqttDidConnected;
-(void) reloadDataForUserBlockNotification:(NSString *)userId andBlockFlag:(BOOL)flag;
-(void)updateUserDetail:(NSString *)userId;

@end

@interface ALMQTTConversationService : NSObject <MQTTSessionDelegate>

+(ALMQTTConversationService *)sharedInstance;

@property (nonatomic, strong) ALSyncCallService *alSyncCallService;

@property (nonatomic, strong) id<ALMQTTConversationDelegate>mqttConversationDelegate;

@property (nonatomic, readwrite) MQTTSession *session;

-(void) subscribeToConversation;

-(void) unsubscribeToConversation;

-(void) unsubscribeToConversation: (NSString *)userKey;

-(void) sendTypingStatus:(NSString *) applicationKey userID:(NSString *) userId andChannelKey:(NSNumber *)channelKey typing: (BOOL) typing;

-(void)unSubscribeToChannelConversation:(NSNumber *)channelKey;
-(void)subscribeToChannelConversation:(NSNumber *)channelKey;

-(void)subscribeToOpenChannel:(NSNumber *)channelKey;
-(void)unSubscribeToOpenChannel:(NSNumber *)channelKey;
-(void) syncReceivedMessage :(ALMessage *)alMessage withNSMutableDictionary:(NSMutableDictionary*)nsMutableDictionary;

@end
