//
//  ALMessage.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALMessage.h"
#import "ALUtilityClass.h"
#import "ALAudioVideoBaseVC.h"


@implementation ALMessage

-(NSNumber *)getGroupId
{
    if([self.groupId isEqualToNumber:[NSNumber numberWithInt:0]])
    {
        return nil;
    }
    else
    {
        return self.groupId;
    }
}

-(id)initWithDictonary:(NSDictionary *)messageDictonary
{
    @try
    {
        [self parseMessage:messageDictonary];
    }
    @catch (NSException *exception)
    {
        NSLog(@"EXCEPTION : MSG_PARSING :: %@",exception.description);
    }
    @finally
    { }

    return self;
}

-(void)parseMessage:(id) messageJson
{

    // key String

    self.key =  [super getStringFromJsonValue:messageJson[@"key"]];

    self.pairedMessageKey = [super getStringFromJsonValue:messageJson[@"pairedMessageKey"]];


    // device keyString

    self.deviceKey = [self getStringFromJsonValue:messageJson[@"deviceKey"]];


    // su user keyString

    self.userKey = [self getStringFromJsonValue:messageJson[@"suUserKeyString"]];


    // to

    self.to = [self getStringFromJsonValue:messageJson[@"to"]];


    // message

    self.message = [self getStringFromJsonValue:messageJson[@"message"]];


    // sent

//    self.sent = [self getBoolFromJsonValue:messageJson[@"sent"]];


    // sendToDevice

    self.sendToDevice = [self getBoolFromJsonValue:messageJson[@"sendToDevice"]];


    // shared

    self.shared = [self getBoolFromJsonValue:messageJson[@"shared"]];


    // createdAtTime

    self.createdAtTime = [self getNSNumberFromJsonValue:messageJson[@"createdAtTime"]];


    // type

    self.type = [self getStringFromJsonValue:messageJson[@"type"]];


    // source

//    self.source = [self getStringFromJsonValue:messageJson[@"source"]];
     self.source = [self getShortFromJsonValue:messageJson[@"source"]];


    // contactIds

    self.contactIds = [self getStringFromJsonValue:messageJson[@"contactIds"]];


    // storeOnDevice

    self.storeOnDevice = [self getBoolFromJsonValue:messageJson[@"storeOnDevice"]];


    // read

    //self.read = [self getBoolFromJsonValue:messageJson[@"read"]];

    //develired
    self.delivered = [self getBoolFromJsonValue:messageJson[@"delivered"]];

    //groupId

    self.groupId = [self getNSNumberFromJsonValue:messageJson[@"groupId"]];

    //contentType

    self.contentType = [self getShortFromJsonValue:messageJson[@"contentType"]];

    //conversationID
    self.conversationId = [self getNSNumberFromJsonValue:messageJson[@"conversationId"]];

    //status
    self.status = [self getNSNumberFromJsonValue:messageJson[@"status"]];

    // file meta info

     NSDictionary * fileMetaDict = messageJson[@"fileMeta"];

            if ([self validateJsonClass:fileMetaDict]) {

                ALFileMetaInfo * theFileMetaInfo = [ALFileMetaInfo new];

                theFileMetaInfo.blobKey = [self getStringFromJsonValue:fileMetaDict[@"blobKey"]];
                theFileMetaInfo.contentType = [self getStringFromJsonValue:fileMetaDict[@"contentType"]];
                theFileMetaInfo.createdAtTime = [self getNSNumberFromJsonValue:fileMetaDict[@"createdAtTime"]];
                theFileMetaInfo.key = [self getStringFromJsonValue:fileMetaDict[@"key"]];
                theFileMetaInfo.name = [self getStringFromJsonValue:fileMetaDict[@"name"]];
                theFileMetaInfo.userKey = [self getStringFromJsonValue:fileMetaDict[@"userKey"]];
                theFileMetaInfo.size = [self getStringFromJsonValue:fileMetaDict[@"size"]];
                theFileMetaInfo.thumbnailUrl = [self getStringFromJsonValue:fileMetaDict[@"thumbnailUrl"]];
                theFileMetaInfo.url = [self getStringFromJsonValue:fileMetaDict[@"url"]];

                self.fileMeta = theFileMetaInfo;
            }

    self.deleted = NO;

    self.metadata = [[NSMutableDictionary  alloc] initWithDictionary:messageJson[@"metadata"]];

    self.msgHidden = [self isMsgHidden];

}


-(NSString *)getCreatedAtTime:(BOOL)today {

    NSString *formattedStr = today?@"hh:mm a":@"dd MMM";

    NSString *formattedDateStr;

    NSDate *currentTime = [[NSDate alloc] init];

    NSDate *msgDate = [[NSDate alloc] init];
    msgDate = [NSDate dateWithTimeIntervalSince1970:self.createdAtTime.doubleValue/1000];
    NSTimeInterval difference = [currentTime timeIntervalSinceDate:msgDate];

    float minutes;
    if(difference <= 3600)
    {
        if(difference <= 60)
        {
            formattedDateStr = NSLocalizedStringWithDefaultValue(@"justNow", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Just Now", @"");

        }
        else
        {
            minutes = difference/60;
            formattedDateStr = [NSString stringWithFormat:@"%.0f", minutes];
            formattedDateStr = [formattedDateStr stringByAppendingString:@" m"];
        }
    }
    else if(difference <= 7200)
    {
        minutes = (difference - 3600)/60;
        formattedDateStr = [NSString stringWithFormat:@"%.0f", minutes];
        NSString *hour = @"1h ";
        formattedDateStr = [hour stringByAppendingString:formattedDateStr];
        formattedDateStr = [formattedDateStr stringByAppendingString:@"m"];
    }
    else
    {
        formattedDateStr = [ALUtilityClass formatTimestamp:[self.createdAtTime doubleValue]/1000 toFormat:formattedStr];
    }
    
    return [formattedDateStr stringByReplacingOccurrencesOfString:@"m" withString:@"دقيقة"];

    return formattedDateStr;
}

-(NSString *)getCreatedAtTimeChat:(BOOL)today {

   // NSString *formattedStr = today?@"hh:mm a":@"dd MMM hh:mm a";
    NSString *formattedStr = @"hh:mm a";
    NSString *formattedDateStr = [ALUtilityClass formatTimestamp:[self.createdAtTime doubleValue]/1000 toFormat:formattedStr];

    return formattedDateStr;

}
-(BOOL)isDownloadRequired{

    //TODO:check for SD card
    return (self.fileMeta && !self.imageFilePath);
}

-(BOOL)isUploadRequire{
    //TODO:check for SD card
    return ( (self.imageFilePath && !self.fileMeta && [self.type  isEqualToString:@"5"])
            || self.isUploadFailed==YES );
}


-(BOOL)isHiddenMessage
{
    return ((self.contentType == ALMESSAGE_CONTENT_HIDDEN) || [self isVOIPNotificationMessage]
            || [self isPushNotificationMessage] || [self isMessageCategoryHidden]
            || self.getReplyType== AL_REPLY_BUT_HIDDEN || self.isMsgHidden );
}

-(BOOL)isVOIPNotificationMessage
{
    return (self.contentType == AV_CALL_CONTENT_TWO);
}


-(BOOL)isToIgnoreUnreadCountIncrement
{
    return (self.contentType == AV_CALL_CONTENT_THREE);
}


-(NSString*)getNotificationText
{

    if(self.contentType == ALMESSAGE_CONTENT_LOCATION)
    {
        return NSLocalizedStringWithDefaultValue(@"location", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Location", @"");

    }
    else if(self.contentType == ALMESSAGE_CONTENT_VCARD)
    {
        return NSLocalizedStringWithDefaultValue(@"contact", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Contact", @"");
    }
    if(self.message && ![self.message isEqualToString:@""])
    {
        return self.message;
    }
    else
    {
        return NSLocalizedStringWithDefaultValue(@"attachment", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Attachment", @"");
    }
}


-(NSMutableDictionary *)getMetaDataDictionary:(NSString *)string
{

    if(string == nil){
        return nil;
    }

    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
//    NSString * error;
    NSPropertyListFormat format;
    NSMutableDictionary * metaDataDictionary;
//    NSMutableDictionary * metaDataDictionary = [NSPropertyListSerialization
//                          propertyListFromData:data
//                          mutabilityOption:NSPropertyListImmutable
//                          format:&format
//                          errorDescription:&error];
    @try
    {
        NSError * error;
        metaDataDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable
                                                                                     format:&format
                                                                                      error:&error];
        if(!metaDataDictionary)
        {
//            NSLog(@"ERROR: COULD NOT PARSE META-DATA : %@", error.description);
        }
    }
    @catch(NSException * exp)
    {
//         NSLog(@"METADATA_DICTIONARY_EXCEPTION :: %@", exp.description);
    }

    return metaDataDictionary;
}

-(NSString *)getVOIPMessageText
{
    NSString *msgType = (NSString *)[self.metadata objectForKey:@"MSG_TYPE"];
    BOOL flag = [[self.metadata objectForKey:@"CALL_AUDIO_ONLY"] boolValue];

    NSString * text = self.message;

    if([msgType isEqualToString:@"CALL_MISSED"])
    {
        text = flag ? @"Missed Audio Call" : @"Missed Video Call";
    }
    else if([msgType isEqualToString:@"CALL_END"])
    {
        text = flag ? @"Audio Call" : @"Video Call";
    }
    else if([msgType isEqualToString:@"CALL_REJECTED"])
    {
        text = @"Call Busy";
    }

    return text;
}

-(BOOL)isMsgHidden
{
    BOOL hide = [[self.metadata objectForKey:@"hide"] boolValue];

    return hide;
}

-(BOOL)isPushNotificationMessage
{
  return (self.metadata && [self.metadata valueForKey:@"category"] &&
   [ [self.metadata valueForKey:@"category"] isEqualToString:CATEGORY_PUSHNNOTIFICATION]);
}

-(BOOL)isMessageCategoryHidden
{
    return (self.metadata && [self.metadata valueForKey:@"category"] &&
            [ [self.metadata valueForKey:@"category"] isEqualToString:CATEGORY_HIDDEN]);
}


-(BOOL)isAReplyMessage
{
    return (self.metadata && [self.metadata valueForKey:AL_MESSAGE_REPLY_KEY] );
}

-(BOOL)isSentMessage
{
    return [self.type isEqualToString:OUT_BOX];
}
-(BOOL)isReceivedMessage
{
    return [self.type isEqualToString:IN_BOX];

}

-(BOOL)isLocationMessage
{
    return (self.contentType ==ALMESSAGE_CONTENT_LOCATION);
}
-(BOOL)isContactMessage
{
    return (self.contentType ==ALMESSAGE_CONTENT_VCARD);

}
-(BOOL)isDocumentMessage
{
    return (self.contentType ==ALMESSAGE_CONTENT_ATTACHMENT) &&
    !([self.fileMeta.contentType hasPrefix:@"video"]|| [self.fileMeta.contentType hasPrefix:@"audio"] || [self.fileMeta.contentType hasPrefix:@"image"] );

}

-(BOOL)isSilentNotification{

    if( _metadata && [_metadata  valueForKey:@"show"] ){

        return ([ [_metadata  valueForKey:@"show"] isEqualToString:@"false"]);
    }
    return NO;
}

-(ALReplyType)getReplyType
{
    switch ([self.messageReplyType intValue])
    {

        case 1:
            return AL_A_REPLY;
            break;

        case 2:
            return AL_REPLY_BUT_HIDDEN;
            break;

        default:
            return AL_NOT_A_REPLY;
    }
}
@end
