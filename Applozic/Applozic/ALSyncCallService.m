//
//  ALSyncCallService.m
//  Applozic
//
//  Created by Applozic Inc on 12/14/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALSyncCallService.h"
#import "ALMessageDBService.h"
#import "ALContactDBService.h"
#import "ALChannelService.h"

@implementation ALSyncCallService


-(void) updateMessageDeliveryReport:(NSString *)messageKey withStatus:(int)status{
    ALMessageDBService *alMessageDBService = [[ALMessageDBService alloc] init];
    [alMessageDBService updateMessageDeliveryReport:messageKey withStatus:status];
    NSLog(@"delivery report for %@", messageKey);
    //Todo: update ui
}

-(void) updateDeliveryStatusForContact:(NSString *)contactId withStatus:(int)status {
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
    [messageDBService updateDeliveryReportForContact:contactId withStatus:status];
    //Todo: update ui
}

-(void) syncCall: (ALMessage *) alMessage {
    
    if (alMessage.groupId != nil && alMessage.contentType == ALMESSAGE_CHANNEL_NOTIFICATION) {
        ALChannelService *channelService = [[ALChannelService alloc] init];
        [channelService syncCallForChannel];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MQTT_APPLOZIC_01" object:alMessage];
}

-(void) updateConnectedStatus: (ALUserDetail *) alUserDetail {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userUpdate" object:alUserDetail];
    ALContactDBService* contactDBService = [[ALContactDBService alloc] init];
    [contactDBService updateLastSeenDBUpdate:alUserDetail];
}

-(void)updateTableAtConversationDeleteForContact:(NSString*)contactID
                                  ConversationID:(NSString *)conversationID
                                      ChannelKey:(NSNumber *)channelKey{
    
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
    [messageDBService deleteAllMessagesByContact:contactID orChannelKey:channelKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CONVERSATION_DELETION"
                                                        object:(contactID ? contactID :channelKey)];
    
}

@end
