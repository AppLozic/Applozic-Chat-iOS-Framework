//
//  ALUser.h
//  ChatApp
//
//  Created by devashish on 18/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ALJson.h"

typedef enum
{
    CLIENT = 0,
    APPLOZIC = 1,
    FACEBOOK = 2,
    
} AuthenticationType;

typedef enum
{
    DEVELOPMENT = 0,
    DISTRIBUTION = 1,

} deviceApnsType;


#define AV_FEATURE_ARRAY  [NSArray arrayWithObjects: @"101",@"102",nil]




@interface ALUser : ALJson

@property NSString *userId;
@property NSString *email;
@property NSString *password;
@property NSString *displayName;
@property NSString *registrationId;
@property NSString *applicationId;
@property NSString *contactNumber;
@property NSString *countryCode;
@property short prefContactAPI;
@property Boolean emailVerified;
@property NSString *timezone;
@property NSString *appVersionCode;
@property NSString *roleName;
@property short deviceType;
@property NSString *imageLink;
@property NSString * appModuleName;
@property short userTypeId;
@property short notificationMode;
@property short authenticationTypeId;
@property short unreadCountType;
@property short deviceApnsType;
@property BOOL enableEncryption;
@property NSNumber* contactType;
@property NSMutableArray * features;
@property NSString* notificationSoundFileName;
@property NSMutableDictionary * metadata;

-(instancetype)initWithUserId:(NSString *)userId
                     password:(NSString *)password
                        email:(NSString *)email
               andDisplayName:(NSString *)displayName;

@end

