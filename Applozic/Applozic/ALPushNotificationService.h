//
//  ALPushNotificationService.h
//  ChatApp
//
//  Created by devashish on 28/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

// NEW CODES FOR VERSION CODE 105...

#define MT_SYNC @"APPLOZIC_01"
#define MT_DELIVERED @"APPLOZIC_04"
#define MT_DELETE_MESSAGE @"APPLOZIC_05"
#define MT_CONVERSATION_DELETED @"APPLOZIC_06"
#define MT_MESSAGE_READ @"APPLOZIC_07"
#define MT_MESSAGE_DELIVERED_AND_READ @"APPLOZIC_08"
#define MT_CONVERSATION_READ @"APPLOZIC_09"
#define MT_CONVERSATION_DELIVERED_AND_READ @"APPLOZIC_10"
#define USER_CONNECTED @"APPLOZIC_11"
#define USER_DISCONNECTED @"APPLOZIC_12"
#define MT_MESSAGE_SENT @"APPLOZIC_02"
#define MT_USER_BLOCK @"APPLOZIC_16"
#define MT_USER_UNBLOCK @"APPLOZIC_17"
#define TEST_NOTIFICATION @"APPLOZIC_20"

#define MTEXTER_USER @"MTEXTER_USER"
#define MT_CONTACT_VERIFIED @"MT_CONTACT_VERIFIED"
#define MT_DEVICE_CONTACT_SYNC @"MT_DEVICE_CONTACT_SYNC"
#define MT_EMAIL_VERIFIED @"MT_EMAIL_VERIFIED"
#define MT_DEVICE_CONTACT_MESSAGE @"MT_DEVICE_CONTACT_MESSAGE"
#define MT_CANCEL_CALL @"MT_CANCEL_CALL"
#define MT_MESSAGE @"MT_MESSAGE"
#define MT_DELETE_MULTIPLE_MESSAGE @"MT_DELETE_MULTIPLE_MESSAGE"
#define MT_SYNC_PENDING @"MT_SYNC_PENDING"

#define APPLOZIC_PREFIX @"APPLOZIC_"
#define APPLOZIC_CATEGORY_KEY @"category"


#import <Foundation/Foundation.h>
#import "ALMessage.h"
#import "ALUserDetail.h"
#import "ALSyncCallService.h"
#import <Applozic/ALChatLauncher.h>


@interface ALPushNotificationService : NSObject

-(BOOL) isApplozicNotification: (NSDictionary *) dictionary;

-(BOOL) processPushNotification: (NSDictionary *) dictionary updateUI: (NSNumber*) updateUI;

@property(nonatomic,strong) ALSyncCallService * alSyncCallService;

@property(nonatomic, readonly, strong) UIViewController *topViewController;

@property(nonatomic,strong) ALChatLauncher * chatLauncher;

-(void)notificationArrivedToApplication:(UIApplication*)application withDictionary:(NSDictionary *)userInfo;
+(void)applicationEntersForeground;
+(void)userSync;
-(BOOL) checkForLaunchNotification:(NSDictionary *)dictionary;
@end
