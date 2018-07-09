//
//  ALVOIPNotificationHandler.m
//  Applozic
//
//  Created by Abhishek Thapliyal on 1/13/17.
//  Copyright © 2017 applozic Inc. All rights reserved.
//

#import "ALVOIPNotificationHandler.h"
#import "UIView+Toast.h"
#import "ALContactService.h"
#import "ALNotificationView.h"

@implementation ALVOIPNotificationHandler
{
    NSTimer * apnTimer;
    int count;
    UNMutableNotificationContent *content;
    SystemSoundID soundID;
    NSString *soundPath;
    UILocalNotification *localNotification;
    UIApplication *appObject;
    UNUserNotificationCenter *center;
}

+(instancetype)sharedManager
{
    static ALVOIPNotificationHandler *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

-(id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

//==============================================================================================================================================
#pragma mark - LAUNCH AUDIO/VIDEO VC
//==============================================================================================================================================

-(void)launchAVViewController:(NSString *)userID andLaunchFor:(NSNumber *)type
                     orRoomId:(NSString *)roomId andCallAudio:(BOOL)flag andViewController:(UIViewController *)viewSelf
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"AudioVideo" bundle:nil];
    self.baseAV = (ALAudioVideoBaseVC *)[storyboard instantiateViewControllerWithIdentifier:[ALApplozicSettings getAudioVideoClassName]];
    self.baseAV.userID = userID;
    self.baseAV.launchFor = type;
    self.baseAV.callForAudio = flag;
    self.baseAV.baseRoomId = roomId;
    
    [viewSelf presentViewController:self.baseAV animated:YES completion:nil];
}

//==============================================================================================================================
#pragma mark - SEND AUDIO/VIDEO MESSAGE WITH META DATA
//==============================================================================================================================

+(void)sendMessageWithMetaData:(NSMutableDictionary *)dictionary
                 andReceiverId:(NSString *)userId
                andContentType:(short)contentType
                     andMsgText:(NSString *)msgText {
    
    ALMessage * messageWithMetaData = [ALMessageService createMessageWithMetaData:dictionary
                                                                   andContentType:contentType
                                                                    andReceiverId:userId
                                                                   andMessageText:msgText];
    
    [ALMessageService sendMessages:messageWithMetaData withCompletion:^(NSString *message, NSError *error) {
        
        NSLog(@"AUDIO/VIDEO MSG_RESPONSE :: %@",message);
        NSLog(@"ERROR IN AUDIO/VIDEO MESSAGE WITH META-DATA : %@", error);
    }];
}

+(NSMutableDictionary *)getMetaData:(NSString *)msgType
                       andCallAudio:(BOOL)flag
                          andRoomId:(NSString *)metaRoomID {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:msgType forKey:@"MSG_TYPE"];
    [dict setObject:metaRoomID forKey:@"CALL_ID"];
    [dict setObject:[NSNumber numberWithBool:flag] forKey:@"CALL_AUDIO_ONLY"];
    
    return dict;
}

-(void)handleAVMsg:(ALMessage *)alMessage andViewController:(UIViewController *)viewSelf
{

    self.presenterVC = viewSelf;
    self.backgroundTask = UIBackgroundTaskInvalid;
    appObject = [UIApplication sharedApplication];
    center = [UNUserNotificationCenter currentNotificationCenter];
    
    if (alMessage.contentType == AV_CALL_CONTENT_TWO)
    {
        if(![ALApplozicSettings isAudioVideoEnabled] )
        {
            NSLog(@" video/audio call not enables  ");
            return;
        }
        
        NSString *msgType = (NSString *)[alMessage.metadata objectForKey:@"MSG_TYPE"];
        BOOL isAudio = [[alMessage.metadata objectForKey:@"CALL_AUDIO_ONLY"] boolValue];
        NSString *roomId = (NSString *)[alMessage.metadata objectForKey:@"CALL_ID"];
        
        if([msgType isEqualToString:@"CALL_DIALED"])
        {
            if ([alMessage.type isEqualToString:@"5"] || [self isNotificationStale:alMessage])
            {
                return;
            }

            if ([ALAudioVideoBaseVC chatRoomEngage])
            {
                NSMutableDictionary * dictionary = [ALVOIPNotificationHandler getMetaData:@"CALL_REJECTED"
                                                                             andCallAudio:isAudio
                                                                                andRoomId:roomId];
                [ALVOIPNotificationHandler sendMessageWithMetaData:dictionary
                                                     andReceiverId:alMessage.to
                                                    andContentType:AV_CALL_CONTENT_TWO
                                                         andMsgText:roomId];
            }
            else if (appObject.applicationState == UIApplicationStateBackground)
            {
                ALContactService * cnService = [[ALContactService alloc] init];
                ALContact * alContact = [cnService loadContactByKey:@"userId" value:alMessage.to];
                
                soundPath = [[NSURL URLWithString:@"/Library/Ringtones/Marimba.m4r"] path];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundPath], &soundID);
                
                NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithDictionary:alMessage.metadata];
                [userInfo setObject:alMessage.to forKey:@"USER_ID"];
                NSString *alertString =@"";

                if(isAudio)
                {
                   alertString = [NSString stringWithFormat:@"Audio Call from %@",[alContact getDisplayName]];
                }
                else
                {
                    alertString = [NSString stringWithFormat:@"Video Call from %@",[alContact getDisplayName]];
  
                }
              
                if (IS_OS_EARLIER_THAN_10)
                {
                    appObject.delegate = self;
                    localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody =
                    localNotification.alertTitle = alertString;
                    localNotification.userInfo = [userInfo mutableCopy];
                }
                else
                {
                    content = [[UNMutableNotificationContent alloc] init];
                    content.title = @"";
                    content.body = alertString;
                    content.userInfo = [userInfo mutableCopy];
                    center.delegate = self;
                }
            
                count = 0;
                apnTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                           target:self
                                                         selector:@selector(showIncomingCall:)
                                                         userInfo:userInfo
                                                          repeats:YES];
                
                self.backgroundTask = [appObject beginBackgroundTaskWithExpirationHandler:^{
                    NSLog(@"ALVOIP : BACKGROUND_HANDLER_NO_MORE_TASK_RUNNING.");
                    [appObject endBackgroundTask:self.backgroundTask];
                    self.backgroundTask = UIBackgroundTaskInvalid;
                }];
            }
            else
            {
                ALVOIPNotificationHandler *voipHandler = [ALVOIPNotificationHandler sharedManager];
                [voipHandler launchAVViewController:alMessage.to
                                     andLaunchFor:[NSNumber numberWithInt:AV_CALL_RECEIVED]
                                         orRoomId:roomId
                                     andCallAudio:isAudio
                                  andViewController:viewSelf];
            }
        }
        else if ([msgType isEqualToString:@"CALL_ANSWERED"])
        {
            // MULTI_DEVICE (WHEN RECEIVER CALL_ANSWERED FROM ANOTHER DEVICE)
            // STOP RINGING AND DISMISSVIEW : CHECK INCOMING CALL_ID and CALL_ID OF OPEPENED VIEW
            if ([self.baseAV.baseRoomId isEqualToString:roomId] && [alMessage.type isEqualToString:@"5"])
            {
                [self.baseAV dismissAVViewController:YES];
            }
            [self invalidateCallNotifying];
        }
        else if ([msgType isEqualToString:@"CALL_REJECTED"])
        {
            // MULTI_DEVICE (WHEN RECEIVER CUTS FROM ANOTHER DEVICE)
            // STOP RINGING AND DISMISSVIEW : CHECK INCOMING CALL_ID and CALL_ID OF OPEPENED VIEW
            if ([self.baseAV.baseRoomId isEqualToString:roomId])
            {
                NSMutableDictionary * dictionary = [ALVOIPNotificationHandler getMetaData:@"CALL_REJECTED"
                                                                             andCallAudio:isAudio
                                                                                andRoomId:roomId];
                [ALVOIPNotificationHandler sendMessageWithMetaData:dictionary
                                                     andReceiverId:alMessage.to
                                                    andContentType:AV_CALL_CONTENT_THREE
                                                        andMsgText:roomId];
            }
            NSLog(@"CALL_IS_REJECTED");
            [self.baseAV dismissAVViewController:YES];
            [self invalidateCallNotifying];
            [ALNotificationView showNotification:@"Participant Busy"];
        }
        else if ([msgType isEqualToString:@"CALL_MISSED"])
        {
            NSLog(@"CALL_IS_MISSED");
            [self.baseAV dismissAVViewController:YES];
            
            // IF APP IS IN BACKGROUND
            [self invalidateCallNotifying];
        }
    }
}

-(void)showIncomingCall:(NSTimer *)timer
{
    if (count < 60)
    {
        NSLog(@"BG_TIME_REMAIN : %f",appObject.backgroundTimeRemaining);
        if (IS_OS_EARLIER_THAN_10)
        {
            [appObject presentLocalNotificationNow:localNotification];
            if (count != 0)
            {
                // REMOVE FROM NOTIFICATION CENTER
            }
        }
        else
        {
            NSString *reuqestIdentifier = [NSString stringWithFormat:@"%@_%i",@"INCOMING_VOIP_APN",count];
            UNNotificationRequest * request = [UNNotificationRequest requestWithIdentifier:reuqestIdentifier content:content trigger:nil];
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"PUSHKIT : INCOMING_VOIP_APN");
                }
            }];
            
            if (count != 0)
            {
                NSString *cancelIdentifier = [NSString stringWithFormat:@"%@_%i",@"INCOMING_VOIP_APN",(count - 3)];
                [center removeDeliveredNotificationsWithIdentifiers:@[cancelIdentifier]];
            }
        }
        AudioServicesPlaySystemSound(soundID);
        count = count + 3;
        return;
    }
    
    // TIMEOUT : STOP TIMER AND LOCAL NOTIFICATION BACKGROUND TASK
    [self invalidateCallNotifying];
}

-(void)invalidateCallNotifying
{
    [apnTimer invalidate];
    AudioServicesDisposeSystemSoundID(soundID);
    if (self.backgroundTask != UIBackgroundTaskInvalid)
    {
        [appObject endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

//==============================================================================================================================
#pragma mark - NOTIFICATION TAP ACTION
//==============================================================================================================================

-(void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
        withCompletionHandler:(void (^)(void))completionHandler {

    UNNotificationContent * notifyContent = response.notification.request.content;
    [self didReceiveLocalNotification:notifyContent.userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"ALVOIP : DID_RECEIVE_LOCAL_NOTIFICATION");
    [self didReceiveLocalNotification:notification.userInfo];
}

-(void)didReceiveLocalNotification:(NSDictionary *)userInfo
{
    BOOL flag = [[userInfo objectForKey:@"CALL_AUDIO_ONLY"] boolValue];
    NSString *roomId = (NSString *)[userInfo objectForKey:@"CALL_ID"];
    NSString *userId = (NSString *)[userInfo objectForKey:@"USER_ID"];
    
    [self launchAVViewController:userId
                    andLaunchFor:[NSNumber numberWithInt:AV_CALL_RECEIVED]
                        orRoomId:roomId
                    andCallAudio:flag
               andViewController:self.presenterVC];
    
    // IF APP IS IN BACKGROUND
    [self invalidateCallNotifying];
}

-(BOOL)isNotificationStale:(ALMessage*)alMessage
{
    NSLog(@"[[NSDate date]timeIntervalSince1970] - [alMessage.createdAtTime doubleValue] ::%d", [[NSDate date]timeIntervalSince1970]*1000 - [alMessage.createdAtTime doubleValue]);
    return ( ([[NSDate date] timeIntervalSince1970] - [alMessage.createdAtTime doubleValue]/1000) > 30);
}

-(void)dealloc
{
    [self invalidateCallNotifying];
}

@end
