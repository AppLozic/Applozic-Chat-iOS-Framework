//
//  ALVOIPNotificationHandler.h
//  Applozic
//
//  Created by Abhishek Thapliyal on 1/13/17.
//  Copyright © 2017 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALAudioVideoBaseVC.h"
#import "ALChatViewController.h"
#import "ALUtilityClass.h"
#import <UserNotifications/UserNotifications.h>

@interface ALVOIPNotificationHandler : NSObject <UNUserNotificationCenterDelegate, UIApplicationDelegate>

@property (nonatomic, strong) ALAudioVideoBaseVC *baseAV;

@property (nonatomic, strong) UIViewController *presenterVC;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

+(instancetype)sharedManager;

-(void)launchAVViewController:(NSString *)userID
                 andLaunchFor:(NSNumber *)type
                     orRoomId:(NSString *)roomId
                 andCallAudio:(BOOL)flag
            andViewController:(UIViewController *)viewSelf;

+(void)sendMessageWithMetaData:(NSMutableDictionary *)dictionary
                 andReceiverId:(NSString *)userId
                andContentType:(short)contentType
                     andMsgText:(NSString *)msgText;

+(NSMutableDictionary *)getMetaData:(NSString *)msgType
                       andCallAudio:(BOOL)flag
                          andRoomId:(NSString *)metaRoomID;

-(void)handleAVMsg:(ALMessage *)alMessage andViewController:(UIViewController *)viewSelf;

-(void)invalidateCallNotifying;

@end
