//
//  ALRegisterUserClientService.h
//  ChatApp
//
//  Created by devashish on 18/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//
#define INVALID_APPLICATIONID @"INVALID_APPLICATIONID"
#define VERSION_CODE @"109"
#define LOGOUT_URL @"/rest/ws/device/logout"

#import <Foundation/Foundation.h>
#import "ALRegistrationResponse.h"
#import "ALUser.h"
#import "ALConstant.h"
#import "ALAPIResponse.h"

@interface ALRegisterUserClientService : NSObject

-(void) initWithCompletion:(ALUser *)user withCompletion:(void(^)(ALRegistrationResponse * message, NSError * error)) completion;

-(void) updateApnDeviceTokenWithCompletion:(NSString *)apnDeviceToken withCompletion:(void(^)(ALRegistrationResponse * message, NSError * error)) completion;

+(void) updateNotificationMode:(short)notificationMode withCompletion:(void(^)(ALRegistrationResponse * response, NSError *error)) completion;
-(void) connect;

-(void) disconnect;

-(void)logoutWithCompletionHandler:(void(^)(ALAPIResponse *response, NSError *error))completion;

+(BOOL)isAppUpdated;

-(void)syncAccountStatus;

@end
