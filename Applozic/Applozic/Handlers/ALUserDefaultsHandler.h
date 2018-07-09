//
//  ALUserDefaultsHandler.h
//  ChatApp
//
//  Created by shaik riyaz on 12/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#define APPLICATION_KEY @"com.applozic.userdefault.APPLICATION_KEY"
#define EMAIL_VERIFIED @"com.applozic.userdefault.EMAIL_VERIFIED"
#define DISPLAY_NAME @"com.applozic.userdefault.DISPLAY_NAME"
#define DEVICE_KEY_STRING @"com.applozic.userdefault.DEVICE_KEY_STRING"
#define USER_KEY_STRING @"com.applozic.userdefault.USER_KEY_STRING"
#define EMAIL_ID @"com.applozic.userdefault.EMAIL_ID"
#define USER_ID @"com.applozic.userdefault.USER_ID"
#define APN_DEVICE_TOKEN @"com.applozic.userdefault.APN_DEVICE_TOKEN"
#define GOOGLE_MAP_API_KEY @"com.applozic.userdefault.GOOGLE_MAP_API_KEY"

#define LAST_SYNC_TIME @"com.applozic.userdefault.LAST_SYNC_TIME"
#define CONVERSATION_DB_SYNCED @"com.applozic.userdefault.CONVERSATION_DB_SYNCED"
#define LOGOUT_BUTTON_VISIBLITY @"com.applozic.userdefault.LOGOUT_BUTTON_VISIBLITY"
#define BOTTOM_TAB_BAR_VISIBLITY @"com.applozic.userdefault.BOTTOM_TAB_BAR_VISIBLITY"
#define BACK_BTN_VISIBILITY_ON_CON_LIST @"com.applozic.userdefault.BACK_BTN_VISIBILITY_ON_CON_LIST"
#define CONVERSATION_CONTACT_IMAGE_VISIBILITY @"com.applozic.userdefault.CONVERSATION_CONTACT_IMAGE_VISIBILITY"
#define MSG_LIST_CALL_SUFIX @"com.applozic.userdefault.MSG_CALL_MADE:"
#define PROCESSED_NOTIFICATION_IDS  @"com.applozic.userdefault.PROCESSED_NOTIFICATION_IDS"
#define LAST_SEEN_SYNC_TIME @"com.applozic.userdefault.LAST_SEEN_SYNC_TIME"
#define SHOW_LOAD_ERLIER_MESSAGE @"com.applozic.userdefault.SHOW_LOAD_ERLIER_MESSAGE:"
#define LAST_SYNC_CHANNEL_TIME @"com.applozic.userdefault.LAST_SYNC_CHANNEL_TIME"
#define USER_BLOCK_LAST_TIMESTAMP @"com.applozic.userdefault.USER_BLOCK_LAST_TIMESTAMP"
#define APP_MODULE_NAME_ID @"com.applozic.userdefault.APP_MODULE_NAME_ID"
#define CONTACT_VIEW_LOADED @"com.applozic.userdefault.CONTACT_VIEW_LOADED"
#define USER_INFO_API_CALLED_SUFFIX @"com.applozic.userdefault.USER_INFO_API_CALLED:"
#define APPLOZIC_BASE_URL @"APPLOZIC_BASE_URL"
#define APPLOZIC_MQTT_URL @"APPLOZIC_MQTT_URL"
#define APPLOZIC_FILE_URL @"APPLOZIC_FILE_URL"
#define APPLOZIC_MQTT_PORT @"APPLOZIC_MQTT_PORT"
#define USER_TYPE_ID @"com.applozic.userdefault.USER_TYPE_ID"
#define MESSSAGE_LIST_LAST_TIME @"com.applozic.userdefault.MESSSAGE_LIST_LAST_TIME"
#define ALL_CONVERSATION_FETCHED @"com.applozic.userdefault.ALL_CONVERSATION_FETCHED"
#define CONVERSATION_FETCH_PAGE_SIZE @"com.applozic.userdefault.CONVERSATION_FETCH_PAGE_SIZE"
#define NOTIFICATION_MODE @"com.applozic.userdefault.NOTIFICATION_MODE"
#define USER_PASSWORD @"com.applozic.userdefault.USER_PASSWORD"
#define USER_AUTHENTICATION_TYPE_ID @"com.applozic.userdefault.USER_AUTHENTICATION_TYPE_ID"
#define UNREAD_COUNT_TYPE @"com.applozic.userdefault.UNREAD_COUNT_TYPE"
#define MSG_SYN_CALL @"com.applozic.userdefault.MSG_SYN_CALL"
#define DEBUG_LOG_FLAG @"com.applozic.userdefault.DEBUG_LOG_FLAG"
#define LOGIN_USER_CONTACT @"com.applozic.userdefault.LOGIN_USER_CONTACT"
#define LOGIN_USER_PROFILE_IMAGE @"com.applozic.userdefault.LOGIN_USER_PROFILE_IMAGE"
#define LOGIN_USER_PROFILE_IMAGE_SERVER @"com.applozic.userdefault.LOGIN_USER_PROFILE_IMAGE_SERVER"
#define LOGGEDIN_USER_STATUS @"com.applozic.userdefault.LOGGEDIN_USER_STATUS"
#define LOGIN_USER_SUBSCRIBED_MQTT @"com.applozic.userdefault.LOGIN_USER_SUBSCRIBED_MQTT"
#define USER_ENCRYPTION_KEY @"com.applozic.userdefault.USER_ENCRYPTION_KEY"
#define USER_PRICING_PACKAGE @"com.applozic.userdefault.USER_PRICING_PACKAGE"
#define DEVICE_ENCRYPTION_ENABLE @"com.applozic.userdefault.DEVICE_ENCRYPTION_ENABLE"
#define NOTIFICATION_SOUND_FILE_NAME @"com.applozic.userdefault.NOTIFICATION_SOUND_FILE_NAME"
#define AL_CONTACT_SERVER_CALL_IS_DONE @"com.applozic.userdefault.AL_CONTACT_SERVER_CALL_IS_DONE"
#define AL_CONTACT_SCROLLING_DONE @"com.applozic.userdefault.AL_CONTACT_SCROLLING_DONE"
#define KEY_PREFIX @"com.applozic.userdefault"
#define GROUP_FILTER_LAST_SYNC_TIME @"com.applozic.GROUP_FILTER_LAST_SYNC_TIME"
#define AL_USER_ROLE_TYPE @"com.applozic.userdefault.AL_USER_ROLE_TYPE"

#import <Foundation/Foundation.h>

@interface ALUserDefaultsHandler : NSObject

+(void) setConversationContactImageVisibility: (BOOL) visibility;

+(BOOL) isConversationContactImageVisible;

+(void) setBottomTabBarHidden: (BOOL) visibleStatus;

+(BOOL) isBottomTabBarHidden;

+(void)setNavigationRightButtonHidden:(BOOL)flagValue;
+(BOOL)isNavigationRightButtonHidden;

+(void) setBackButtonHidden: (BOOL)flagValue;

+(BOOL) isBackButtonHidden;

+(BOOL) isLoggedIn;

+(void) clearAll;

+(NSString *) getApplicationKey;

+(void) setApplicationKey: (NSString*) applicationKey;

+(void) setEmailVerified: (BOOL) value;

+(void) setApnDeviceToken: (NSString*) apnDeviceToken;

+(NSString *) getApnDeviceToken;

+(void) setBoolForKey_isConversationDbSynced:(BOOL) value;

+(BOOL) getBoolForKey_isConversationDbSynced;

+(void) setDeviceKeyString:(NSString*)deviceKeyString;

+(void) setUserKeyString:(NSString*)userKeyString;

+(void) setDisplayName:(NSString*)displayName;

+(void) setEmailId:(NSString*)emailId;

+(NSString *)getEmailId;

+(NSString *) getDeviceKeyString;

+(void) setUserId: (NSString *) userId;

+(NSString*)getUserId;

+(void) setLastSyncTime: (NSNumber *) lastSyncTime;

+(void)setServerCallDoneForMSGList:(BOOL) value forContactId:(NSString*)constactId;

+(BOOL)isServerCallDoneForMSGList:(NSString *) contactId;

+(void) setProcessedNotificationIds:(NSMutableArray*) arrayWithIds;

+(NSMutableArray*) getProcessedNotificationIds;

+(BOOL)isNotificationProcessd:(NSString*)withNotificationId;

+(NSNumber *) getLastSeenSyncTime;

+(void) setLastSeenSyncTime :(NSNumber*) lastSeenTime;

+(void) setShowLoadEarlierOption : (BOOL) value forContactId:(NSString*)constactId;

+(BOOL)isShowLoadEarlierOption :(NSString*)constactId;

+(void)setLastSyncChannelTime:(NSNumber *)lastSyncChannelTime;

+(NSNumber *)getLastSyncChannelTime;

+(NSNumber *)getLastSyncTime;

+(NSString *)getUserKeyString;

+(NSString *)getDisplayName;

+(void)setUserBlockLastTimeStamp:(NSNumber *)lastTimeStamp;

+(NSNumber *)getUserBlockLastTimeStamp;

//+(NSString *)getNotificationTitle;
//+(void)setNotificationTitle:(NSString *)notificationTitle;

+(NSString *)getPassword;
+(void )setPassword:(NSString *)password;

+(void)setAppModuleName:(NSString*)appModuleName;
+(NSString*)getAppModuleName;

+(BOOL) getContactViewLoaded;
+(void) setContactViewLoadStatus:(BOOL)status;

+(void)setServerCallDoneForUserInfo:(BOOL)value ForContact:(NSString*)contactId;
+(BOOL)isServerCallDoneForUserInfoForContact:(NSString*)contactId;

+(void)setBASEURL:(NSString *)baseURL;
+(NSString *)getBASEURL;

+(void)setMQTTURL:(NSString *)mqttURL;
+(NSString *)getMQTTURL;

+(void)setFILEURL:(NSString *)fileURL;
+(NSString *)getFILEURL;

+(void)setMQTTPort:(NSString *)portNumber;
+(NSString *)getMQTTPort;

+(void)setUserTypeId:(short)type;
+(short)getUserTypeId;

+(NSNumber *)getLastMessageListTime;
+(void)setLastMessageListTime:(NSNumber *)lastTime;

+(BOOL)getFlagForAllConversationFetched;
+(void)setFlagForAllConversationFetched:(BOOL)flag;

+(NSInteger)getFetchConversationPageSize;
+(void)setFetchConversationPageSize:(NSInteger)limit;

+(short)getNotificationMode;
+(void)setNotificationMode:(short)mode;

+(short)getUserAuthenticationTypeId;
+(void)setUserAuthenticationTypeId:(short)type;

+(short)getUnreadCountType;
+(void)setUnreadCountType:(short)mode;

+(BOOL)isMsgSyncRequired;
+(void)setMsgSyncRequired:(BOOL)flag;

+(BOOL)isDebugLogsRequire;
+(void)setDebugLogsRequire:(BOOL)flag;

+(BOOL)getLoginUserConatactVisibility;
+(void)setLoginUserConatactVisibility:(BOOL)flag;

// LOGIN USER PROFILE IMAGE LINK
+(NSString *)getProfileImageLink;
+(void)setProfileImageLink:(NSString *)imageLink;

+(NSString *)getProfileImageLinkFromServer;
+(void)setProfileImageLinkFromServer:(NSString *)imageLink;

+(NSString *)getLoggedInUserStatus;
+(void)setLoggedInUserStatus:(NSString *)status;

+(BOOL)isUserLoggedInUserSubscribedMQTT;
+(void)setLoggedInUserSubscribedMQTT:(BOOL)flag;

+(NSString *)getEncryptionKey;
+(void)setEncryptionKey:(NSString *)encrptionKey;

+(short)getUserPricingPackage;
+(void)setUserPricingPackage:(short)pricingPackage;

+(BOOL)getEnableEncryption;
+(void)setEnableEncryption:(BOOL)flag;

+(void) setGoogleMapAPIKey:(NSString *)googleMapAPIKey;
+(NSString *) getGoogleMapAPIKey;

+(NSString *) getNotificationSoundFileName;
+(void) setNotificationSoundFileName:(NSString *) notificationSoundFileName;

+(BOOL)isContactServerCallIsDone;
+(void)setContactServerCallIsDone:(BOOL)flag;

+(BOOL)isContactScrollingIsInProgress;
+(void)setContactScrollingIsInProgress:(BOOL)flag;

+(void) setLastGroupFilterSyncTime: (NSNumber *) lastSyncTime;
+(NSNumber *)getLastGroupFilterSyncTIme;

+(void)setUserRoleType:(short)type;
+(short)getUserRoleType;

@end
