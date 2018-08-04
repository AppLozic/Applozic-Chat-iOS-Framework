//
//  ALUserDefaultsHandler.m
//  ChatApp
//
//  Created by shaik riyaz on 12/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALUserDefaultsHandler.h"
#define NOTIFICATION_TITLE @"NOTIFICATION_TITLE"

@implementation ALUserDefaultsHandler

+(void) setConversationContactImageVisibility:(BOOL)visibility
{
    [[NSUserDefaults standardUserDefaults] setBool:visibility forKey:CONVERSATION_CONTACT_IMAGE_VISIBILITY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL) isConversationContactImageVisible
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CONVERSATION_CONTACT_IMAGE_VISIBILITY];
}

+(void) setBottomTabBarHidden:(BOOL)visibleStatus
{
    [[NSUserDefaults standardUserDefaults] setBool:visibleStatus forKey:BOTTOM_TAB_BAR_VISIBLITY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL) isBottomTabBarHidden
{
    BOOL flag = [[NSUserDefaults standardUserDefaults] boolForKey:BOTTOM_TAB_BAR_VISIBLITY];
    if(flag)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+(void) setNavigationRightButtonHidden:(BOOL)flagValue
{
    [[NSUserDefaults standardUserDefaults] setBool:flagValue forKey:LOGOUT_BUTTON_VISIBLITY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL) isNavigationRightButtonHidden
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:LOGOUT_BUTTON_VISIBLITY];
}

+(void) setBackButtonHidden:(BOOL)flagValue
{
    [[NSUserDefaults standardUserDefaults] setBool:flagValue forKey:BACK_BTN_VISIBILITY_ON_CON_LIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL) isBackButtonHidden
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:BACK_BTN_VISIBILITY_ON_CON_LIST];
}

+(void) setApplicationKey:(NSString *)applicationKey
{
    [[NSUserDefaults standardUserDefaults] setValue:applicationKey forKey:APPLICATION_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *) getApplicationKey
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:APPLICATION_KEY];
}

+(BOOL) isLoggedIn
{
    return [ALUserDefaultsHandler getDeviceKeyString] != nil;
}

+(void) clearAll
{
    NSLog(@"CLEARING_USER_DEFAULTS");
    NSDictionary * dictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSArray * keyArray = [dictionary allKeys];
    for(NSString * defaultKeyString in keyArray)
    {
        if([defaultKeyString hasPrefix:KEY_PREFIX] && ![defaultKeyString isEqualToString:APN_DEVICE_TOKEN])
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:defaultKeyString];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

+(void) setApnDeviceToken:(NSString *)apnDeviceToken
{
    [[NSUserDefaults standardUserDefaults] setValue:apnDeviceToken forKey:APN_DEVICE_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString*) getApnDeviceToken
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:APN_DEVICE_TOKEN];
}

+(void) setEmailVerified:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:EMAIL_VERIFIED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void) getEmailVerified
{
    [[NSUserDefaults standardUserDefaults] boolForKey: EMAIL_VERIFIED];
}

// isConversationDbSynced

+(void)setBoolForKey_isConversationDbSynced:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:CONVERSATION_DB_SYNCED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getBoolForKey_isConversationDbSynced
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CONVERSATION_DB_SYNCED];
}

+(void)setEmailId:(NSString *)emailId
{
    [[NSUserDefaults standardUserDefaults] setValue:emailId forKey:EMAIL_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getEmailId
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:EMAIL_ID];
}
    

+(void)setDisplayName:(NSString *)displayName
{
    [[NSUserDefaults standardUserDefaults] setValue:displayName forKey:DISPLAY_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getDisplayName
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:DISPLAY_NAME];
}

//deviceKey String
+(void)setDeviceKeyString:(NSString *)deviceKeyString
{
    [[NSUserDefaults standardUserDefaults] setValue:deviceKeyString forKey:DEVICE_KEY_STRING];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getDeviceKeyString{
    return [[NSUserDefaults standardUserDefaults] valueForKey:DEVICE_KEY_STRING];
}

+(void)setUserKeyString:(NSString *)suUserKeyString
{
    [[NSUserDefaults standardUserDefaults] setValue:suUserKeyString forKey:USER_KEY_STRING];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getUserKeyString
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:USER_KEY_STRING];
}

//LOGIN USER ID
+(void)setUserId:(NSString *)userId
{
    [[NSUserDefaults standardUserDefaults] setValue:userId forKey:USER_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getUserId
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:USER_ID];
}

//LOGIN USER PASSWORD
+(void)setPassword:(NSString *)password
{
    [[NSUserDefaults standardUserDefaults] setValue:password forKey:USER_PASSWORD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getPassword
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:USER_PASSWORD];
}

//last sync time
+(void)setLastSyncTime :( NSNumber *) lstSyncTime
{
    lstSyncTime = @([lstSyncTime doubleValue] + 1);
    NSLog(@"saving last Sync time in the preference ...%@" ,lstSyncTime);
    [[NSUserDefaults standardUserDefaults] setDouble:[lstSyncTime doubleValue] forKey:LAST_SYNC_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSNumber *)getLastSyncTime
{
   // NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    return [[NSUserDefaults standardUserDefaults] valueForKey:LAST_SYNC_TIME];
}


+(void)setServerCallDoneForMSGList:(BOOL) value forContactId:(NSString*)contactId
{
    if(!contactId)
    {
        return;
    }
    
    NSString * key = [MSG_LIST_CALL_SUFIX stringByAppendingString: contactId];
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isServerCallDoneForMSGList:(NSString *)contactId
{
    if(!contactId)
    {
        return true;
    }
    NSString * key = [MSG_LIST_CALL_SUFIX stringByAppendingString: contactId];
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+(void) setProcessedNotificationIds:(NSMutableArray*)arrayWithIds
{
    [[NSUserDefaults standardUserDefaults] setObject:arrayWithIds forKey:PROCESSED_NOTIFICATION_IDS];
}

+(NSMutableArray*) getProcessedNotificationIds
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:PROCESSED_NOTIFICATION_IDS] mutableCopy];
}

+(BOOL)isNotificationProcessd:(NSString*)withNotificationId
{
    NSMutableArray * mutableArray = [self getProcessedNotificationIds];
    
    if(mutableArray == nil)
    {
        mutableArray = [[NSMutableArray alloc]init];
    }
    
    BOOL isTheObjectThere = [mutableArray containsObject:withNotificationId];
    
    if (isTheObjectThere){
       // [mutableArray removeObject:withNotificationId];
    }else {
        [mutableArray addObject:withNotificationId];
    }
    //WE will just store 20 notificationIds for processing...
    if(mutableArray.count > 20)
    {
        [mutableArray removeObjectAtIndex:0];
    }
    [self setProcessedNotificationIds:mutableArray];
    return isTheObjectThere;
    
}

+(void) setLastSeenSyncTime :(NSNumber*) lastSeenTime
{
    NSLog(@"saving last seen time in the preference ...%@" ,lastSeenTime);
    [[NSUserDefaults standardUserDefaults] setDouble:[lastSeenTime doubleValue] forKey:LAST_SEEN_SYNC_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSNumber *) getLastSeenSyncTime
{
    NSNumber * timeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_SEEN_SYNC_TIME];
    return timeStamp ? timeStamp : [NSNumber numberWithInt:0];
}

+(void)setShowLoadEarlierOption:(BOOL) value forContactId:(NSString*)contactId
{
    if(!contactId)
    {
        return;
    }
    NSString *key = [SHOW_LOAD_ERLIER_MESSAGE stringByAppendingString:contactId];
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isShowLoadEarlierOption:(NSString *)contactId
{
    if(!contactId)
    {
        return NO;
    }
    NSString *key = [SHOW_LOAD_ERLIER_MESSAGE stringByAppendingString:contactId];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:key])
    {
        return [[NSUserDefaults standardUserDefaults] boolForKey:key];
    }
    else
    {
        return YES;
    }
    
}
//Notification settings...

+(void)setNotificationTitle:(NSString *)notificationTitle
{
    [[NSUserDefaults standardUserDefaults] setValue:notificationTitle forKey:NOTIFICATION_TITLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getNotificationTitle
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:NOTIFICATION_TITLE];
}

+(void)setLastSyncChannelTime:(NSNumber *)lastSyncChannelTime
{
    lastSyncChannelTime = @([lastSyncChannelTime doubleValue] + 1);
    
    [[NSUserDefaults standardUserDefaults] setDouble:[lastSyncChannelTime doubleValue] forKey:LAST_SYNC_CHANNEL_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSNumber *)getLastSyncChannelTime
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:LAST_SYNC_CHANNEL_TIME];
}

+(void)setUserBlockLastTimeStamp:(NSNumber *)lastTimeStamp
{
    lastTimeStamp = @([lastTimeStamp doubleValue] + 1);
    [[NSUserDefaults standardUserDefaults] setDouble:[lastTimeStamp doubleValue] forKey:USER_BLOCK_LAST_TIMESTAMP];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSNumber *)getUserBlockLastTimeStamp
{
    NSNumber * lastSyncTimeStamp = [[NSUserDefaults standardUserDefaults] valueForKey:USER_BLOCK_LAST_TIMESTAMP];
    if(!lastSyncTimeStamp)                      //FOR FIRST TIME USER
    {
        lastSyncTimeStamp = [NSNumber numberWithInt:1000];
    }
    
    return lastSyncTimeStamp;
}

//App Module Name
+(void )setAppModuleName:(NSString *)appModuleName
{
    [[NSUserDefaults standardUserDefaults] setValue:appModuleName forKey:APP_MODULE_NAME_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getAppModuleName
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:APP_MODULE_NAME_ID];
}

+(void) setContactViewLoadStatus:(BOOL)status
{
    [[NSUserDefaults standardUserDefaults] setBool:status forKey:CONTACT_VIEW_LOADED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL) getContactViewLoaded
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CONTACT_VIEW_LOADED];
}

+(void)setServerCallDoneForUserInfo:(BOOL)value ForContact:(NSString *)contactId
{
    if(!contactId)
    {
        return;
    }
    
    NSString * key = [USER_INFO_API_CALLED_SUFFIX stringByAppendingString:contactId];
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isServerCallDoneForUserInfoForContact:(NSString *)contactId
{
    if(!contactId)
    {
        return true;
    }
    
    NSString * key = [USER_INFO_API_CALLED_SUFFIX stringByAppendingString:contactId];
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}


+(void)setBASEURL:(NSString *)baseURL
{
    [[NSUserDefaults standardUserDefaults] setValue:baseURL forKey:APPLOZIC_BASE_URL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getBASEURL
{
    NSString * kBaseUrl = [[NSUserDefaults standardUserDefaults] valueForKey:APPLOZIC_BASE_URL];
    return (kBaseUrl && ![kBaseUrl isEqualToString:@""]) ? kBaseUrl : @"https://apps.applozic.com";
}

+(void)setMQTTURL:(NSString *)mqttURL
{
    [[NSUserDefaults standardUserDefaults] setValue:mqttURL forKey:APPLOZIC_MQTT_URL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getMQTTURL
{
    NSString * kMqttUrl = [[NSUserDefaults standardUserDefaults] valueForKey:APPLOZIC_MQTT_URL];
    return (kMqttUrl && ![kMqttUrl isEqualToString:@""]) ? kMqttUrl : @"apps.applozic.com";
}

+(void)setFILEURL:(NSString *)fileURL
{
    [[NSUserDefaults standardUserDefaults] setValue:fileURL forKey:APPLOZIC_FILE_URL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getFILEURL
{
    NSString * kFileUrl = [[NSUserDefaults standardUserDefaults] valueForKey:APPLOZIC_FILE_URL];
    return (kFileUrl && ![kFileUrl isEqualToString:@""]) ? kFileUrl : @"https://applozic.appspot.com";
}

+(void)setMQTTPort:(NSString *)portNumber
{
    [[NSUserDefaults standardUserDefaults] setValue:portNumber forKey:APPLOZIC_MQTT_PORT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getMQTTPort
{
    NSString * kPortNumber = [[NSUserDefaults standardUserDefaults] valueForKey:APPLOZIC_MQTT_PORT];
    return (kPortNumber && ![kPortNumber isEqualToString:@""]) ? kPortNumber : @"1883";
}

+(void)setUserTypeId:(short)type
{
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:USER_TYPE_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(short)getUserTypeId{
    return [[NSUserDefaults standardUserDefaults] integerForKey:USER_TYPE_ID];
}

+(void)setLastMessageListTime:(NSNumber *)lastTime
{
    lastTime = @([lastTime doubleValue] + 1);
    [[NSUserDefaults standardUserDefaults] setDouble:[lastTime doubleValue] forKey:MESSSAGE_LIST_LAST_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSNumber *)getLastMessageListTime
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:MESSSAGE_LIST_LAST_TIME];
}

+(void)setFlagForAllConversationFetched:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:ALL_CONVERSATION_FETCHED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getFlagForAllConversationFetched
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:ALL_CONVERSATION_FETCHED];
}

+(void)setFetchConversationPageSize:(NSInteger)limit
{
    [[NSUserDefaults standardUserDefaults] setInteger:limit forKey:CONVERSATION_FETCH_PAGE_SIZE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)getFetchConversationPageSize
{
    NSInteger maxLimit = [[NSUserDefaults standardUserDefaults] integerForKey:CONVERSATION_FETCH_PAGE_SIZE];
    return maxLimit ? maxLimit : 60;
}

+(void)setNotificationMode:(short)mode
{
    [[NSUserDefaults standardUserDefaults] setInteger:mode forKey:NOTIFICATION_MODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(short)getNotificationMode
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:NOTIFICATION_MODE];
}

+(void)setUserAuthenticationTypeId:(short)type
{
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:USER_AUTHENTICATION_TYPE_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(short)getUserAuthenticationTypeId
{
    short type = [[NSUserDefaults standardUserDefaults] integerForKey:USER_AUTHENTICATION_TYPE_ID];
    return type ? type : 0;
}

+(void)setUnreadCountType:(short)mode
{
    [[NSUserDefaults standardUserDefaults] setInteger:mode forKey:UNREAD_COUNT_TYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(short)getUnreadCountType
{
    short type = [[NSUserDefaults standardUserDefaults] integerForKey:UNREAD_COUNT_TYPE];
    return type ? type : 0;
}

+(void)setMsgSyncRequired:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:MSG_SYN_CALL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isMsgSyncRequired
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:MSG_SYN_CALL];
}

+(void)setDebugLogsRequire:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:DEBUG_LOG_FLAG];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isDebugLogsRequire
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:DEBUG_LOG_FLAG];
}

+(void)setLoginUserConatactVisibility:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:LOGIN_USER_CONTACT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getLoginUserConatactVisibility
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:LOGIN_USER_CONTACT];
}

+(void)setProfileImageLink:(NSString *)imageLink
{
    [[NSUserDefaults standardUserDefaults] setValue:imageLink forKey:LOGIN_USER_PROFILE_IMAGE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getProfileImageLink
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:LOGIN_USER_PROFILE_IMAGE];
}

+(void)setProfileImageLinkFromServer:(NSString *)imageLink
{
    [[NSUserDefaults standardUserDefaults] setValue:imageLink forKey:LOGIN_USER_PROFILE_IMAGE_SERVER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getProfileImageLinkFromServer
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:LOGIN_USER_PROFILE_IMAGE_SERVER];
}

+(void)setLoggedInUserStatus:(NSString *)status
{
    [[NSUserDefaults standardUserDefaults] setValue:status forKey:LOGGEDIN_USER_STATUS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getLoggedInUserStatus
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:LOGGEDIN_USER_STATUS];
}

+(BOOL)isUserLoggedInUserSubscribedMQTT
{
     return [[NSUserDefaults standardUserDefaults] boolForKey:LOGIN_USER_SUBSCRIBED_MQTT];
}

+(void)setLoggedInUserSubscribedMQTT:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:LOGIN_USER_SUBSCRIBED_MQTT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getEncryptionKey
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:USER_ENCRYPTION_KEY];
}

+(void)setEncryptionKey:(NSString *)encrptionKey
{
    [[NSUserDefaults standardUserDefaults] setValue:encrptionKey forKey:USER_ENCRYPTION_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)setUserPricingPackage:(short)pricingPackage
{
    [[NSUserDefaults standardUserDefaults] setInteger:pricingPackage forKey:USER_PRICING_PACKAGE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(short)getUserPricingPackage
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:USER_PRICING_PACKAGE];
}

+(void)setEnableEncryption:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:DEVICE_ENCRYPTION_ENABLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getEnableEncryption
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:DEVICE_ENCRYPTION_ENABLE];
}

+(void)setGoogleMapAPIKey:(NSString *)googleMapAPIKey
{
    [[NSUserDefaults standardUserDefaults] setValue:googleMapAPIKey forKey:GOOGLE_MAP_API_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString*)getGoogleMapAPIKey
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:GOOGLE_MAP_API_KEY];
}

+(NSString*)getNotificationSoundFileName
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:NOTIFICATION_SOUND_FILE_NAME];
}


+(void)setNotificationSoundFileName:(NSString *)notificationSoundFileName
{
    [[NSUserDefaults standardUserDefaults] setValue:notificationSoundFileName forKey:NOTIFICATION_SOUND_FILE_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)setContactServerCallIsDone:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:AL_CONTACT_SERVER_CALL_IS_DONE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isContactServerCallIsDone
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:AL_CONTACT_SERVER_CALL_IS_DONE];
}

+(void)setContactScrollingIsInProgress:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:AL_CONTACT_SCROLLING_DONE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isContactScrollingIsInProgress
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:AL_CONTACT_SCROLLING_DONE];
}

+(void) setLastGroupFilterSyncTime: (NSNumber *) lastSyncTime
{
    [[NSUserDefaults standardUserDefaults] setDouble:[lastSyncTime doubleValue] forKey:GROUP_FILTER_LAST_SYNC_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSNumber *)getLastGroupFilterSyncTIme
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:GROUP_FILTER_LAST_SYNC_TIME];

}

+(void)setUserRoleType:(short)type{
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:AL_USER_ROLE_TYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(short)getUserRoleType{
    
    short roleType = [[NSUserDefaults standardUserDefaults] integerForKey:AL_USER_ROLE_TYPE];
    return roleType ? roleType : 3;
    
}


@end
