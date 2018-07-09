//
//  ALMQTTConversationService.m
//  Applozic
//
//  Created by Applozic Inc on 11/27/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALMQTTConversationService.h"
#import "ALUserDefaultsHandler.h"
#import "ALConstant.h"
#import "ALMessage.h"
#import "ALMessageDBService.h"
#import "ALUserDetail.h"
#import "ALPushAssist.h"
#import "ALChannelService.h"
#import "ALContactDBService.h"
#import "ALMessageService.h"
#import "ALUserService.h"

#define MQTT_TOPIC_STATUS @"status-v2"

@implementation ALMQTTConversationService

/*
 MESSAGE_RECEIVED("APPLOZIC_01"), MESSAGE_SENT("APPLOZIC_02"),
 MESSAGE_SENT_UPDATE("APPLOZIC_03"), MESSAGE_DELIVERED("APPLOZIC_04"),
 MESSAGE_DELETED("APPLOZIC_05"), CONVERSATION_DELETED("APPLOZIC_06"),
 MESSAGE_READ("APPLOZIC_07"), MESSAGE_DELIVERED_AND_READ("APPLOZIC_08"),
 CONVERSATION_READ("APPLOZIC_09"), CONVERSATION_DELIVERED_AND_READ("APPLOZIC_10"),
 USER_CONNECTED("APPLOZIC_11"), USER_DISCONNECTED("APPLOZIC_12"),
 GROUP_DELETED("APPLOZIC_13"), GROUP_LEFT("APPLOZIC_14");
 */

+(ALMQTTConversationService *)sharedInstance
{
    static ALMQTTConversationService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ALMQTTConversationService alloc] init];
        sharedInstance.alSyncCallService = [[ALSyncCallService alloc] init];
    });
    return sharedInstance;
}

-(void) subscribeToConversation {
    
    dispatch_async(dispatch_get_main_queue (),^{
        
        @try
        {
            if (![ALUserDefaultsHandler isLoggedIn]) {
                return;
            }
            if(self.session && (self.session.status == MQTTSessionEventConnected || self.session.status == MQTTSessionStatusConnecting)) {
                NSLog(@"MQTT : IGNORING REQUEST, ALREADY CONNECTED");
                return;
            }
            NSLog(@"MQTT : CONNECTING_MQTT_SERVER");
            
            self.session = [[MQTTSession alloc] initWithClientId:[NSString stringWithFormat:@"%@-%f",
                                                                  [ALUserDefaultsHandler getUserKeyString],fmod([[NSDate date] timeIntervalSince1970], 10.0)]];
            
            NSString * willMsg = [NSString stringWithFormat:@"%@,%@,%@",[ALUserDefaultsHandler getUserKeyString],[ALUserDefaultsHandler getDeviceKeyString],@"0"];
            
            self.session.willFlag = YES;
            self.session.willTopic = MQTT_TOPIC_STATUS;
            self.session.willMsg = [willMsg dataUsingEncoding:NSUTF8StringEncoding];
            self.session.willQoS = MQTTQosLevelAtMostOnce;
            [self.session setDelegate:self];
            NSLog(@"MQTT : WAITING_FOR_CONNECT...");
            
            [self.session connectToHost:MQTT_URL port:[MQTT_PORT intValue] withConnectionHandler:^(MQTTSessionEvent event) {
                
                if (event == MQTTSessionEventConnected)
                {
                    NSLog(@"MQTT : CONNECTED");
                    NSString * publishString = [NSString stringWithFormat:@"%@,%@,%@", [ALUserDefaultsHandler getUserKeyString], [ALUserDefaultsHandler getDeviceKeyString],@"1"];
                    [self.session publishAndWaitData:[publishString dataUsingEncoding:NSUTF8StringEncoding]
                                             onTopic:MQTT_TOPIC_STATUS
                                              retain:NO
                                                 qos:MQTTQosLevelAtMostOnce];
                    
                    NSLog(@"MQTT : SUBSCRIBING TO CONVERSATION TOPICS");
                    [self.session subscribeToTopic:[ALUserDefaultsHandler getUserKeyString] atLevel:MQTTQosLevelAtMostOnce];
                    [self.session subscribeToTopic:[NSString stringWithFormat:@"typing-%@-%@", [ALUserDefaultsHandler getApplicationKey], [ALUserDefaultsHandler getUserId]] atLevel:MQTTQosLevelAtMostOnce];
                    [ALUserDefaultsHandler setLoggedInUserSubscribedMQTT:YES];
                    [self.mqttConversationDelegate mqttDidConnected];
                }
            } messageHandler:^(NSData *data, NSString *topic) {
                
            }];
            
            /*if (session.status == MQTTSessionStatusConnected) {
             [session subscribeToTopic:[ALUserDefaultsHandler getUserKeyString] atLevel:MQTTQosLevelAtMostOnce];
             }*/
        }
        @catch (NSException * e) {
            NSLog(@"MQTT : EXCEPTION_IN_SUBSCRIBE :: %@", e.description);
        }
    });
}

- (void)session:(MQTTSession*)session newMessage:(NSData*)data onTopic:(NSString*)topic {
    NSLog(@"MQTT: GOT_NEW_MESSAGE");
}

- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    NSString *fullMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"MQTT_GOT_NEW_MESSAGE : %@", fullMessage);
    
    NSError *error = nil;
    NSDictionary *theMessageDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSString *type = [theMessageDict objectForKey:@"type"];
    NSLog(@"MQTT_NOTIFICATION_TYPE :: %@",type);
    NSString *notificationId = (NSString* )[theMessageDict valueForKey:@"id"];
    
    ALPushAssist *top = [[ALPushAssist alloc] init];
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground || !top.isOurViewOnTop)
    {
        NSLog(@"Returing coz Application State is Background OR Our View is NOT on Top");
        if ([topic hasPrefix:@"typing"])
        {
            [self subProcessTyping:fullMessage];
        }
        return;
    }
    
    if(notificationId && [ALUserDefaultsHandler isNotificationProcessd:notificationId])
    {
        NSLog(@"MQTT : NOTIFICATION-ID ALREADY PROCESSED :: %@",notificationId);
        return;
    }
    
    if ([topic hasPrefix:@"typing"])
    {
        [self subProcessTyping:fullMessage];
    }
    else
    {
        if ([type isEqualToString: @"MESSAGE_RECEIVED"] || [type isEqualToString:@"APPLOZIC_01"])
        {
            ALPushAssist* assistant = [[ALPushAssist alloc] init];
            ALMessage *alMessage = [[ALMessage alloc] initWithDictonary:[theMessageDict objectForKey:@"message"]];
            
            if([alMessage isHiddenMessage])
            {
                NSLog(@"< HIDDEN MESSAGE RECEIVED >");
                [ALMessageService getLatestMessageForUser:[ALUserDefaultsHandler getDeviceKeyString]
                                           withCompletion:^(NSMutableArray *message, NSError *error) { }];
            }
            else
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:[alMessage getNotificationText] forKey:@"alertValue"];
                [dict setObject:[NSNumber numberWithInt:APP_STATE_BACKGROUND] forKey:@"updateUI"];
                
                if(alMessage.groupId){
                    ALChannelService *channelService = [[ALChannelService alloc] init];
                    [channelService  getChannelInformation:alMessage.groupId orClientChannelKey:nil withCompletion:^(ALChannel *alChannel) {
                        
                        if(alChannel && alChannel.type == OPEN){
                            if(alMessage.deviceKey && [alMessage.deviceKey isEqualToString:[ALUserDefaultsHandler getDeviceKeyString]]) {
                                NSLog(@"MQTT : RETURNING,GOT MY message");
                                return;
                            }
                            
                            [ALMessageService addOpenGroupMessage:alMessage];
                            if(!assistant.isOurViewOnTop)
                            {
                                [assistant assist:alMessage.contactIds and:dict ofUser:alMessage.contactIds];
                                [dict setObject:@"mqtt" forKey:@"Calledfrom"];
                            }
                            else
                            {
                                [self.alSyncCallService syncCall:alMessage];
                                [self.mqttConversationDelegate syncCall:alMessage andMessageList:nil];
                            }
                        }else{
                            
                            [self syncReceivedMessage: alMessage withNSMutableDictionary:dict];
                            
                        }
                    }];
                } else{
                            [self syncReceivedMessage: alMessage withNSMutableDictionary:dict];
                            
                        }
                    }
        }
        else if ([type isEqualToString:@"MESSAGE_SENT"] || [type isEqualToString:@"APPLOZIC_02"])
        {
            NSDictionary * message = [theMessageDict objectForKey:@"message"];
            ALMessage *alMessage = [[ALMessage alloc] initWithDictonary:message];
            
            NSLog(@"ALMESSAGE's DeviceKey : %@ \n Current DeviceKey : %@", alMessage.deviceKey, [ALUserDefaultsHandler getDeviceKeyString]);
            if(alMessage.deviceKey && [alMessage.deviceKey isEqualToString:[ALUserDefaultsHandler getDeviceKeyString]]) {
                NSLog(@"MQTT : RETURNING, SENT_BY_SELF_DEVICE");
                return;
            }
            
            [ALMessageService getMessageSENT:alMessage withCompletion:^(NSMutableArray * messageArray, NSError *error) {
                
                if(messageArray.count > 0)
                {
                    [self.alSyncCallService syncCall:alMessage];
                    [self.mqttConversationDelegate syncCall:alMessage andMessageList:nil];
                }
            }];
            
            NSString * key = [message valueForKey:@"pairedMessageKey"];
            NSString * contactID = [message valueForKey:@"contactIds"];
            [self.alSyncCallService updateMessageDeliveryReport:key withStatus:SENT];
            [self.mqttConversationDelegate delivered:key contactId:contactID withStatus:SENT];
            
        }
        else if ([type isEqualToString:@"MESSAGE_DELIVERED"] || [type isEqualToString:@"APPLOZIC_04"]) {
            
            NSArray *deliveryParts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@","];
            NSString * pairedKey = deliveryParts[0];
            NSString * contactId = (deliveryParts.count > 1) ? deliveryParts[1] : nil;
            
            [self.alSyncCallService updateMessageDeliveryReport:pairedKey withStatus:DELIVERED];
            [self.mqttConversationDelegate delivered:pairedKey contactId:contactId withStatus:DELIVERED];
        }
        else if([type isEqualToString:@"MESSAGE_DELETED"] || [type isEqualToString:@"APPLOZIC_05"])
        {
            NSString * messageKey = [[theMessageDict valueForKey:@"message"] componentsSeparatedByString:@","][0];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_MESSAGE_DELETED" object:messageKey];
        }
        else if ([type isEqualToString:@"MESSAGE_DELIVERED_READ"] || [type isEqualToString:@"APPLOZIC_08"])
        {
            NSArray  * deliveryParts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@","];
            NSString * pairedKey = deliveryParts[0];
            NSString * contactId = deliveryParts.count>1 ? deliveryParts[1]:nil;
            
            [self.alSyncCallService updateMessageDeliveryReport:pairedKey withStatus:DELIVERED_AND_READ];
            [self.mqttConversationDelegate delivered:pairedKey contactId:contactId withStatus:DELIVERED_AND_READ];
        }
        else if ([type isEqualToString:@"CONVERSATION_DELIVERED_AND_READ"] || [type isEqualToString:@"APPLOZIC_10"])
        {
            NSString *contactId = [theMessageDict objectForKey:@"message"];
            [self.alSyncCallService updateDeliveryStatusForContact: contactId withStatus:DELIVERED_AND_READ];
            [self.mqttConversationDelegate updateStatusForContact:contactId withStatus:DELIVERED_AND_READ];
        }
        else if ([type isEqualToString:@"USER_CONNECTED"]||[type isEqualToString: @"APPLOZIC_11"])
        {
            ALUserDetail *alUserDetail = [[ALUserDetail alloc] init];
            alUserDetail.userId = [theMessageDict objectForKey:@"message"];
            alUserDetail.lastSeenAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
            alUserDetail.connected = YES;
            [self.alSyncCallService updateConnectedStatus: alUserDetail];
            [self.mqttConversationDelegate updateLastSeenAtStatus: alUserDetail];
        }
        else if ([type isEqualToString:@"APPLOZIC_12"])
        {
            NSArray *parts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@","];
            
            ALUserDetail *alUserDetail = [[ALUserDetail alloc] init];
            alUserDetail.userId = parts[0];
            alUserDetail.lastSeenAtTime = [NSNumber numberWithDouble:[parts[1] doubleValue]];
            alUserDetail.connected = NO;
            [self.alSyncCallService updateConnectedStatus: alUserDetail];
            [self.mqttConversationDelegate updateLastSeenAtStatus: alUserDetail];
        }
        else if ([type isEqualToString:@"APPLOZIC_15"]) //Added or removed by admin
        {
            ALChannelService *channelService = [[ALChannelService alloc] init];
            [channelService syncCallForChannel];
            // TODO HANDLE
        }
        else if ([type isEqualToString:@"APPLOZIC_27"] || [type isEqualToString:@"CONVERSATION_DELETED"]){
            
            NSArray *parts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@","];
            NSString * contactID = parts[0];
            NSString * conversationID = parts[1];
            
            [self.alSyncCallService updateTableAtConversationDeleteForContact:contactID
                                                               ConversationID:conversationID
                                                                   ChannelKey:nil];
        }
        else if ( [type isEqualToString:@"GROUP_CONVERSATION_DELETED"] || [type isEqualToString:@"APPLOZIC_23"]){
            
            NSNumber * groupID = [NSNumber numberWithInt:[[theMessageDict objectForKey:@"message"] intValue]];
            [self.alSyncCallService updateTableAtConversationDeleteForContact:nil
                                                               ConversationID:nil
                                                                   ChannelKey:groupID];
        }
        else if ([type isEqualToString:@"APPLOZIC_16"])
        {
            [self processUserBlockNotification:theMessageDict andUserBlockFlag:YES];
        }
        else if ([type isEqualToString:@"APPLOZIC_17"])
        {
            [self processUserBlockNotification:theMessageDict andUserBlockFlag:NO];
        }
        else if ([type isEqualToString:@"APPLOZIC_30"])
        {
            //          FETCH USER DETAILS and UPDATE DB AND REAL-TIME
            NSString * userId = [theMessageDict objectForKey:@"message"];
            if(![userId isEqualToString:[ALUserDefaultsHandler getUserId]])
            {
                [self.mqttConversationDelegate updateUserDetail:userId];
            }
        }
        else if ([type isEqualToString:@"APPLOZIC_31"])
        {
            // BROADCAST MESSAGE : MESSAGE_DELIVERED
        }
        else if ([type isEqualToString:@"APPLOZIC_32"])
        {
            // BROADCAST MESSAGE : MESSAGE_DELIVERED_AND_READ
        }
        else
        {
            NSLog(@"MQTT NOTIFICATION \"%@\" IS NOT HANDLED",type);
        }
    }
}

-(void)subProcessTyping:(NSString *)fullMessage
{
    NSArray *typingParts = [fullMessage componentsSeparatedByString:@","];
    NSString *applicationKey = typingParts[0]; //Note: will get used once we support messaging from one app to another
    NSString *userId = typingParts[1];
    BOOL typingStatus = [typingParts[2] boolValue];
    if (![userId isEqualToString:[ALUserDefaultsHandler getUserId]])
    {
        [self.mqttConversationDelegate updateTypingStatus:applicationKey userId:userId status:typingStatus];
    }
}

-(void)processUserBlockNotification:(NSDictionary *)theMessageDict andUserBlockFlag:(BOOL)flag
{
    NSArray *mqttMSGArray = [[theMessageDict valueForKey:@"message"] componentsSeparatedByString:@":"];
    NSString *BlockType = mqttMSGArray[0];
    NSString *userId = mqttMSGArray[1];
    if(![BlockType isEqualToString:@"BLOCKED_BY"] && ![BlockType isEqualToString:@"UNBLOCKED_BY"])
    {
        return;
    }
    
    ALContactDBService *dbService = [ALContactDBService new];
    [dbService setBlockByUser:userId andBlockedByState:flag];
    [self.mqttConversationDelegate reloadDataForUserBlockNotification:userId andBlockFlag:flag];
}

- (void)subAckReceived:(MQTTSession *)session msgID:(UInt16)msgID grantedQoss:(NSArray *)qoss
{
    NSLog(@"subscribed");
}

- (void)connected:(MQTTSession *)session {
    
}

- (void)connectionClosed:(MQTTSession *)session
{
    NSLog(@"MQTT : CONNECTION CLOSED (MQTT DELEGATE)");
    [self.mqttConversationDelegate mqttConnectionClosed];
    
    //Todo: inform controller about connection closed.
}

- (void)handleEvent:(MQTTSession *)session
              event:(MQTTSessionEvent)eventCode
              error:(NSError *)error {
}

-(void) sendTypingStatus:(NSString *) applicationKey userID:(NSString *) userId andChannelKey:(NSNumber *)channelKey typing: (BOOL) typing;
{
    if(!self.session){
        return;
    }
    NSLog(@"Sending typing status %d to: %@", typing, userId);
    
    NSString * dataString = [NSString stringWithFormat:@"%@,%@,%i", [ALUserDefaultsHandler getApplicationKey],
                             [ALUserDefaultsHandler getUserId], typing ? 1 : 0];
    
    NSString * topicString = [NSString stringWithFormat:@"typing-%@-%@", [ALUserDefaultsHandler getApplicationKey], userId];
    
    if(channelKey)
    {
        topicString = [NSString stringWithFormat:@"typing-%@-%@", [ALUserDefaultsHandler getApplicationKey], channelKey];
    }
    NSLog(@"MQTT_PUBLISH :: %@",topicString);
    
    NSData * data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [self.session publishDataAtMostOnce:data onTopic:topicString];
    
}

-(void) unsubscribeToConversation {
    NSString *userKey = [ALUserDefaultsHandler getUserKeyString];
    [self unsubscribeToConversation: userKey];
}

-(void) unsubscribeToConversation: (NSString *) userKey
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.session == nil) {
            return;
        }
        [self.session publishAndWaitData:[[NSString stringWithFormat:@"%@,%@,%@",userKey, [ALUserDefaultsHandler getDeviceKeyString], @"0"] dataUsingEncoding:NSUTF8StringEncoding]
                                 onTopic:MQTT_TOPIC_STATUS
                                  retain:NO
                                     qos:MQTTQosLevelAtMostOnce];
        [self.session unsubscribeTopic:[ALUserDefaultsHandler getUserKeyString]];
        [self.session unsubscribeTopic:[NSString stringWithFormat:@"typing-%@-%@", [ALUserDefaultsHandler getApplicationKey], [ALUserDefaultsHandler getUserId]]];
        [self.session close];
        NSLog(@"MQTT : DISCONNECTED FROM MQTT");
    });
}

-(void)subscribeToChannelConversation:(NSNumber *)channelKey
{
    NSLog(@"MQTT_CHANNEL/USER_SUBSCRIBING");
    dispatch_async(dispatch_get_main_queue (),^{
        @try
        {
            if (!self.session && self.session.status == MQTTSessionStatusConnected) {
                NSLog(@"MQTT_SESSION_NULL");
                return;
            }
            NSString * topicString = @"";
            if(channelKey)
            {
                topicString = [NSString stringWithFormat:@"typing-%@-%@", [ALUserDefaultsHandler getApplicationKey], channelKey];
            }
            else
            {
                topicString = [NSString stringWithFormat:@"typing-%@-%@", [ALUserDefaultsHandler getApplicationKey], [ALUserDefaultsHandler getUserId]];
                [ALUserDefaultsHandler setLoggedInUserSubscribedMQTT:YES];
            }
            [self.session subscribeToTopic:topicString atLevel:MQTTQosLevelAtMostOnce];
            NSLog(@"MQTT_CHANNEL/USER_SUBSCRIBING_COMPLETE");
        }
        @catch (NSException * exp) {
            NSLog(@"Exception in subscribing channel :: %@", exp.description);
        }
    });
}

-(void)unSubscribeToChannelConversation:(NSNumber *)channelKey
{
    NSLog(@"MQTT_CHANNEL/USER_UNSUBSCRIBING");
    dispatch_async(dispatch_get_main_queue (), ^{
        
        if (!self.session) {
            NSLog(@"MQTT_SESSION_NULL");
            return;
        }
        NSString * topicString = @"";
        if(channelKey)
        {
            topicString = [NSString stringWithFormat:@"typing-%@-%@", [ALUserDefaultsHandler getApplicationKey], channelKey];
        }else
        {
            topicString = [NSString stringWithFormat:@"typing-%@-%@", [ALUserDefaultsHandler getApplicationKey], [ALUserDefaultsHandler getUserId]];
            [ALUserDefaultsHandler setLoggedInUserSubscribedMQTT:NO];
        }
        [self.session unsubscribeTopic:topicString];
        NSLog(@"MQTT_CHANNEL/USER_UNSUBSCRIBED_COMPLETE");
    });
}

-(void)subscribeToOpenChannel:(NSNumber *)channelKey
{
    NSLog(@"MQTT_CHANNEL/OPEN_GROUP_SUBSCRIBING");
    dispatch_async(dispatch_get_main_queue (),^{
        @try
        {
            if (!self.session && self.session.status == MQTTSessionStatusConnected) {
                NSLog(@"MQTT_SESSION_NULL");
                return;
            }
            NSString * openGroupString = @"";
            if(channelKey)
            {
                openGroupString = [NSString stringWithFormat:@"group-%@-%@", [ALUserDefaultsHandler getApplicationKey], channelKey];
            }

            [self.session subscribeToTopic:openGroupString atLevel:MQTTQosLevelAtMostOnce];
            NSLog(@"MQTT_CHANNEL/OPEN_GROUP_SUBSCRIBTION_COMPLETE");
        }
        @catch (NSException * exp) {
            NSLog(@"Exception in subscribing channel :: %@", exp.description);
        }
    });
}

-(void)unSubscribeToOpenChannel:(NSNumber *)channelKey
{
    NSLog(@"MQTT_/OPEN_GROUP_UNSUBSCRIBING");
    dispatch_async(dispatch_get_main_queue (), ^{

        if (!self.session) {
            NSLog(@"MQTT_SESSION_NULL");
            return;
        }
        NSString * topicString = @"";
        if(channelKey)
        {
            topicString = [NSString stringWithFormat:@"group-%@-%@", [ALUserDefaultsHandler getApplicationKey], channelKey];
        }
        [self.session unsubscribeTopic:topicString];
        NSLog(@"MQTT_CHANNEL/OPEN_GROUP_UNSUBSCRIBTION_COMPLETE");
    });
}

-(void) syncReceivedMessage :(ALMessage *)alMessage withNSMutableDictionary:(NSMutableDictionary*)nsMutableDictionary{
    
    ALPushAssist* assistant = [[ALPushAssist alloc] init];

    [ALMessageService getLatestMessageForUser:[ALUserDefaultsHandler getDeviceKeyString] withCompletion:^(NSMutableArray *message, NSError *error) {
        
        NSLog(@"ALMQTTConversationService SYNC CALL");
        if(!assistant.isOurViewOnTop)
        {
            [assistant assist:alMessage.contactIds and:nsMutableDictionary ofUser:alMessage.contactIds];
            [nsMutableDictionary setObject:@"mqtt" forKey:@"Calledfrom"];
        }
        else
        {
            [self.alSyncCallService syncCall:alMessage];
            [self.mqttConversationDelegate syncCall:alMessage andMessageList:nil];
        }
    }];
}

@end
