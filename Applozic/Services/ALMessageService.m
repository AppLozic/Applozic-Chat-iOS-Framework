//
//  ALMessageService.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALMessageService.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALUtilityClass.h"
#import "ALSyncMessageFeed.h"
#import "ALMessageDBService.h"
#import "ALMessageList.h"
#import "ALDBHandler.h"
#import "ALConnection.h"
#import "ALConnectionQueueHandler.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessageClientService.h"
#import "ALSendMessageResponse.h"
#import "ALUserService.h"
#import "ALUserDetail.h"
#import "ALContactDBService.h"
#import "ALContactService.h"
#import "ALConversationService.h"
#import "ALMessage.h"
#include <tgmath.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ALApplozicSettings.h"

@implementation ALMessageService 

static ALMessageClientService *alMsgClientService;

+(void) processLatestMessagesGroupByContact
{
    ALMessageClientService * almessageClientService = [[ALMessageClientService alloc] init];
    
    [almessageClientService getLatestMessageGroupByContact:[ALUserDefaultsHandler getFetchConversationPageSize]
         startTime:[ALUserDefaultsHandler getLastMessageListTime]  withCompletion:^( ALMessageList *alMessageList, NSError *error) {
        
        if(alMessageList)
        {
            ALMessageDBService *alMessageDBService = [[ALMessageDBService alloc] init];
            [alMessageDBService addMessageList:alMessageList.messageList];
            ALContactDBService *alContactDBService = [[ALContactDBService alloc] init];
            [alContactDBService addUserDetails:alMessageList.userDetailsList];
            [ALUserDefaultsHandler setBoolForKey_isConversationDbSynced:YES];
            
            [self getMessageListForUserIfLastIsHiddenMessageinMessageList:alMessageList
                   withCompletion:^(NSMutableArray * messages, NSError *error, NSMutableArray *userDetailArray) {
                       
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:CONVERSATION_CALL_COMPLETED object:nil userInfo:nil];
            
            if(alMessageListResponse.messageList.count){
                
                 for(ALMessage *message in [alMessageListResponse.messageList subarrayWithRange:NSMakeRange(0, MIN(6, alMessageListResponse.messageList.count))] ){
                    
                    if(message.groupId != nil && message.groupId != 0){
                        
                        MessageListRequest * messageListRequest = [[MessageListRequest alloc] init];
                        messageListRequest.userId = nil;
                        messageListRequest.channelKey = message.groupId;
                        messageListRequest.skipRead = YES;
                        
                        [self getMessageListForUser:messageListRequest withCompletion:^(NSMutableArray *messages, NSError *error, NSMutableArray *userDetailArray) {

                        }];
                    }else{
                        
                        MessageListRequest * messageListRequest = [[MessageListRequest alloc] init];
                        messageListRequest.userId = message.contactIds;
                        messageListRequest.channelKey = nil;
                        messageListRequest.skipRead = YES;
                        
                        [self getMessageListForUser:messageListRequest withCompletion:^(NSMutableArray *messages, NSError *error, NSMutableArray *userDetailArray) {
                            
                        }];
                        
                    }
                }
            }
        }
        else{
            NSLog(@"Message List Response Nil");
        }
    }];
}

+(void)getMessagesListGroupByContactswithCompletionService:(void(^)(NSMutableArray * messages, NSError * error))completion
{
    ALMessageClientService * almessageClientService = [[ALMessageClientService alloc] init];
    
   [almessageClientService getLatestMessageGroupByContact:[ALUserDefaultsHandler getFetchConversationPageSize]
    startTime:[ALUserDefaultsHandler getLastMessageListTime]  withCompletion:^(ALMessageList *alMessageList, NSError *error) {
        
        [self getMessageListForUserIfLastIsHiddenMessageinMessageList:alMessageList
                   withCompletion:^(NSMutableArray *responseMessages, NSError *responseErrorH, NSMutableArray *userDetailArray) {
       
            completion(responseMessages, responseErrorH);
            
        }];
    }];
    
}

+(void)getMessageListForUserIfLastIsHiddenMessageinMessageList:(ALMessageList*)alMessageList
                                                withCompletion:(void (^)(NSMutableArray *, NSError *, NSMutableArray *))completion
{
    
/*____If latest_message of a contact is HIDDEN MESSAGE OR MESSSAGE HIDE = TRUE, then get MessageList of that user from server___*/
    
    for(ALMessage * alMessage in alMessageList.messageList)
    {
        if(![alMessage isHiddenMessage] && ![alMessage isMsgHidden])
        {
            continue;
        }
        
        NSNumber * time = alMessage.createdAtTime;
        
        MessageListRequest * messageListRequest = [[MessageListRequest alloc] init];
        messageListRequest.userId = alMessage.contactIds;
        messageListRequest.channelKey = alMessage.groupId;
        messageListRequest.endTimeStamp = time;
        messageListRequest.conversationId = alMessage.conversationId;
        
        [self getMessageListForUser:messageListRequest withCompletion:^(NSMutableArray *messages, NSError *error, NSMutableArray *userDetailArray) {
            
            completion (messages,error,userDetailArray);
        }];
        
    }
    completion(alMessageList.messageList, nil, nil);
    
}

+(void)getMessageListForUser:(MessageListRequest *)messageListRequest withCompletion:(void (^)(NSMutableArray *, NSError *, NSMutableArray *))completion
{
    //On Message List Cell Tap
    ALMessageDBService *almessageDBService =  [[ALMessageDBService alloc] init];
    NSMutableArray * messageList = [almessageDBService getMessageListForContactWithCreatedAt:messageListRequest.userId withCreatedAt:messageListRequest.endTimeStamp andChannelKey:messageListRequest.channelKey conversationId:messageListRequest.conversationId];
    
    //Found Record in DB itself ...if not make call to server
    if(messageList.count > 0 && ![ALUserDefaultsHandler isServerCallDoneForMSGList:messageListRequest.userId])
    {
       // NSLog(@"the Message List::%@",messageList);
        completion(messageList, nil, nil);
        return;
    }
    else
    {
        NSLog(@"message list is coming from DB %ld", (unsigned long)messageList.count);
    }
    
    
    ALChannelService *channelService = [[ALChannelService alloc] init];
    if(messageListRequest.channelKey)
    {
        
       [channelService getChannelInformation:messageListRequest.channelKey orClientChannelKey:nil withCompletion:^(ALChannel *alChannel) {
            if(alChannel){
                messageListRequest.channelType = alChannel.type;
            }
    
       }];
        
    }
    
    ALMessageClientService *alMessageClientService = [[ALMessageClientService alloc] init];
    ALContactDBService *alContactDBService = [[ALContactDBService alloc] init];
    
    [alMessageClientService getMessageListForUser:messageListRequest withOpenGroup:messageListRequest.channelType == OPEN
                   withCompletion:^(NSMutableArray *messages,
                                    NSError *error,
                                    NSMutableArray *userDetailArray) {
                       
                       [alContactDBService addUserDetails:userDetailArray];

                       ALContactService *contactService = [ALContactService new];
                       NSMutableArray * userNotPresentIds = [NSMutableArray new];
                      
                       for(ALMessage* msg  in messages){
                           
                           NSString* contactId = msg.to;
                           
                           if(![contactService isContactExist:contactId]){
                               [userNotPresentIds addObject:contactId];
                           }
                           
                       }
                       
                       if(userNotPresentIds.count>0)
                       {
                           NSLog(@"Call userDetails...");
                           ALUserService *alUserService = [ALUserService new];
                           [alUserService fetchAndupdateUserDetails:userNotPresentIds withCompletion:^(NSMutableArray *userDetailArray, NSError *theError) {
                               NSLog(@"User detail response sucessfull.");
                               [alContactDBService addUserDetails:userDetailArray];
                               completion(messages, error,userDetailArray);
                           }];
                       }
                       else
                       {
                           completion(messages, error,userDetailArray);
                       }
    }];
}



+(void) getMessageListForContactId:(NSString *)contactIds isGroup:(BOOL )isGroup channelKey:(NSNumber *)channelKey conversationId:(NSNumber *)conversationId startIndex:(NSInteger)startIndex withCompletion:(void (^)(NSMutableArray *))completion {
    int rp = 200;

    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [theRequest setFetchLimit:rp];
    NSPredicate* predicate1;
    if(conversationId && [ALApplozicSettings getContextualChatOption])
    {
        predicate1 = [NSPredicate predicateWithFormat:@"conversationId = %d", [conversationId intValue]];
    }
    else if(isGroup)
    {
        predicate1 = [NSPredicate predicateWithFormat:@"groupId = %d", [channelKey intValue]];
    }
    else
    {
        predicate1 = [NSPredicate predicateWithFormat:@"contactId = %@ && groupId = nil", contactIds];
    }

    //    NSUInteger* mTotalCount = [theDbHandler.managedObjectContext countForFetchRequest:theRequest error:nil];

    NSPredicate* predicate2 = [NSPredicate predicateWithFormat:@"deletedFlag == NO AND msgHidden == %@",@(NO)];
    NSPredicate* predicate3 = [NSPredicate predicateWithFormat:@"contentType != %i",ALMESSAGE_CONTENT_HIDDEN];
    NSPredicate* compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2,predicate3]];
    [theRequest setPredicate:compoundPredicate];
    [theRequest setFetchOffset:startIndex];
    [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];

    NSArray * theArray = [theDbHandler.managedObjectContext executeFetchRequest:theRequest error:nil];
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc]init];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];

    for (DB_Message * theEntity in theArray)
    {
        ALMessage * theMessage = [messageDBService createMessageEntity:theEntity];
        [tempArray insertObject:theMessage atIndex:0];
        //[self.mMessageListArrayKeyStrings insertObject:theMessage.key atIndex:0];
    }
    completion(tempArray);
}


+(void) sendMessages:(ALMessage *)alMessage withCompletion:(void(^)(NSString * message, NSError * error)) completion {
    
    //DB insert if objectID is null
    DB_Message* dbMessage;
    ALMessageDBService * dbService = [[ALMessageDBService alloc] init];
    NSError *theError=nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateConversationTableNotification" object:alMessage userInfo:nil];
    
    ALChannel *channel;
    if(alMessage.groupId){
        ALChannelService *channelService = [[ALChannelService alloc]init];
        channel  = [channelService getChannelByKey:alMessage.groupId];
        
    }
    
    if (alMessage.msgDBObjectId == nil)
    {
        NSLog(@"message not in DB new insertion.");
        if(channel ){
            if(channel.type != OPEN){
                dbMessage = [dbService addMessage:alMessage];
            }
        }else{
            dbMessage = [dbService addMessage:alMessage];
        }
    }
    else
    {
        NSLog(@"message found in DB just getting it not inserting new one...");
        dbMessage = (DB_Message*)[dbService getMeesageById:alMessage.msgDBObjectId error:&theError];
    }
    //convert to dic
    NSDictionary * messageDict = [alMessage dictionary];
    ALMessageClientService * alMessageClientService = [[ALMessageClientService alloc]init];
    [alMessageClientService sendMessage:messageDict WithCompletionHandler:^(id theJson, NSError *theError) {
        
        NSString *statusStr=nil;
        
        if(!theError)
        {
            ALAPIResponse  *apiResponse = [[ALAPIResponse alloc] initWithJSONString:theJson ];
            ALSendMessageResponse  *response = [[ALSendMessageResponse alloc] initWithJSONString:apiResponse.response];
            
            if(!response.isSuccess){
                theError = [NSError errorWithDomain:@"Applozic" code:1
                                           userInfo:[NSDictionary
                                                     dictionaryWithObject:@"error sedning message"
                                                     forKey:NSLocalizedDescriptionKey]];
                
            }else{


                if(channel){
                    if(channel.type != OPEN){
                        alMessage.msgDBObjectId = dbMessage.objectID;
                        [dbService updateMessageSentDetails:response.messageKey withCreatedAtTime:response.createdAt withDbMessage:dbMessage];

                    }
                }else{
                    alMessage.msgDBObjectId = dbMessage.objectID;
                    [dbService updateMessageSentDetails:response.messageKey withCreatedAtTime:response.createdAt withDbMessage:dbMessage];
                }
                
                
                alMessage.key = response.messageKey;
                alMessage.sentToServer = YES;
                alMessage.inProgress = NO;
                alMessage.isUploadFailed= NO;
                alMessage.status = [NSNumber numberWithInt:SENT];
                
            }
            
        }else{
            NSLog(@" got error while sending messages");
        }
        completion(statusStr,theError);
    }];
    
}


+(void) sendMessage:(ALMessage *)alMessage
withAttachmentAtLocation:(NSString *)attachmentLocalPath
            andContentType:(short)contentype
      withCompletion:(void(^)(NSString * message, NSError * error)) completion {
   
    //Message Creation
    ALMessage * theMessage = alMessage;
    theMessage.contentType = contentype;
    theMessage.imageFilePath = attachmentLocalPath.lastPathComponent;
    
    //File Meta Creation
    theMessage.fileMeta.name = [NSString stringWithFormat:@"AUD-5-%@", attachmentLocalPath.lastPathComponent];
    if(alMessage.contactIds){
        theMessage.fileMeta.name = [NSString stringWithFormat:@"%@-5-%@",alMessage.contactIds, attachmentLocalPath.lastPathComponent];
    }
    
    CFStringRef pathExtension = (__bridge_retained CFStringRef)[attachmentLocalPath pathExtension];
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    CFRelease(pathExtension);
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    
    theMessage.fileMeta.contentType = mimeType;
    if( theMessage.contentType == ALMESSAGE_CONTENT_VCARD){
        theMessage.fileMeta.contentType = @"text/x-vcard";
    }
    NSData *imageSize = [NSData dataWithContentsOfFile:attachmentLocalPath];
    theMessage.fileMeta.size = [NSString stringWithFormat:@"%lu",(unsigned long)imageSize.length];
    
    //DB Addition
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
    DB_Message * theMessageEntity = [messageDBService createMessageEntityForDBInsertionWithMessage:theMessage];
    [theDBHandler.managedObjectContext save:nil];
    theMessage.msgDBObjectId = [theMessageEntity objectID];
    theMessageEntity.inProgress = [NSNumber numberWithBool:YES];
    theMessageEntity.isUploadFailed = [NSNumber numberWithBool:NO];
    [[ALDBHandler sharedInstance].managedObjectContext save:nil];
    
    NSDictionary * userInfo = [alMessage dictionary];
    
    ALMessageClientService * clientService  = [[ALMessageClientService alloc]init];
    [clientService sendPhotoForUserInfo:userInfo withCompletion:^(NSString *message, NSError *error) {
        
        if (error)
        {
            NSLog(@" <<<ERROR>>> SEND PHOTO FOR USER%@",error);
//            [self handleErrorStatus:theMessage];
             completion (message,error);
            return;
        }
        [self proessUploadImageForMessage:theMessage databaseObj:theMessageEntity.fileMetaInfo uploadURL:message  withdelegate:self];
        
        completion (message,error);
        
    }];

}
+(void) getLatestMessageForUser:(NSString *)deviceKeyString withCompletion:(void (^)( NSMutableArray *, NSError *))completion
{
    
    if(!alMsgClientService)
    {
        alMsgClientService = [[ALMessageClientService alloc] init];
    }
    
    @synchronized(alMsgClientService) {
        
        [alMsgClientService getLatestMessageForUser:deviceKeyString withCompletion:^(ALSyncMessageFeed * syncResponse , NSError *error) {
            NSMutableArray *messageArray = nil;
           
            if(!error)
            {
                if (syncResponse.deliveredMessageKeys.count > 0)
                {
                    [ALMessageService updateDeliveredReport:syncResponse.deliveredMessageKeys withStatus:DELIVERED];
                }
                if(syncResponse.messagesList.count > 0)
                {
                    messageArray = [[NSMutableArray alloc] init];
                    ALMessageDBService * dbService = [[ALMessageDBService alloc] init];
                    messageArray = [dbService addMessageList:syncResponse.messagesList];
                    
                    NSMutableArray * hiddenMsgFilteredArray = [[NSMutableArray alloc] initWithArray:messageArray];
                    for(ALMessage * message in hiddenMsgFilteredArray)
                    {
                        if([message isHiddenMessage] && ![message isVOIPNotificationMessage])
                        {
                            [messageArray removeObject:message];
                        }
                        else if(![message isToIgnoreUnreadCountIncrement])
                        {
                            [ALMessageService incrementContactUnreadCount:message];
                        }
                
                        if (message.groupId != nil && message.contentType == ALMESSAGE_CHANNEL_NOTIFICATION) {
                            ALChannelService *channelService = [[ALChannelService alloc] init];
                            [channelService syncCallForChannel];
                            if([message isMsgHidden]) {
                                [messageArray removeObject:message];
                            }
                        }
                        
                    }
                    
                    [ALUserService processContactFromMessages:messageArray withCompletion:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NEW_MESSAGE_NOTIFICATION object:messageArray userInfo:nil];
                        
                    }];
   
                     completion(messageArray,error);
                    
                }else
                {
                    completion(messageArray,error);
                }
                
                [ALUserDefaultsHandler setLastSyncTime:syncResponse.lastSyncTime];
                ALMessageClientService *messageClientService = [[ALMessageClientService alloc] init];
                [messageClientService updateDeliveryReports:syncResponse.messagesList];
                
            }
            else
            {
                completion(messageArray,error);
            }
            
        }];
    }
    
}

+(BOOL)incrementContactUnreadCount:(ALMessage*)message{
    
    if(![ALMessageService isIncrementRequired:message]){
        return NO;
    }
    
    if(message.groupId){
        
        NSNumber * groupId = message.groupId;
        ALChannelDBService * channelDBService =[[ALChannelDBService alloc] init];
        ALChannel * channel = [channelDBService loadChannelByKey:groupId];
        channel.unreadCount = [NSNumber numberWithInt:channel.unreadCount.intValue+1];
        [channelDBService updateUnreadCountChannel:message.groupId unreadCount:channel.unreadCount];
    }
    else{
        
        NSString * contactId = message.contactIds;
        ALContactService * contactService=[[ALContactService alloc] init];
        ALContact * contact = [contactService loadContactByKey:@"userId" value:contactId];
        contact.unreadCount = [NSNumber numberWithInt:[contact.unreadCount intValue] + 1];
        [contactService addContact:contact];
        [contactService updateContact:contact];
    }
    
    if(message.conversationId){
        [self fetchTopicDetails:message.conversationId];
    }
        
    return YES;
}

+(BOOL)isIncrementRequired:(ALMessage *)message{
    
    if([message.status isEqualToNumber:[NSNumber numberWithInt:DELIVERED_AND_READ]]
       || (message.groupId && message.contentType == ALMESSAGE_CHANNEL_NOTIFICATION)
       || [message.type isEqualToString:@"5"]
       || [message isHiddenMessage]
       || [message isVOIPNotificationMessage]) {
        
        return NO;
        
    }else{
        return YES;
    }
}
+(void)fetchTopicDetails :(NSNumber *)conversationId
{
    if(conversationId)
    {
        ALConversationService * alConversationService = [[ALConversationService alloc] init];
        [alConversationService fetchTopicDetails:conversationId];
    }
}

+(void) updateDeliveredReport: (NSArray *) deliveredMessageKeys withStatus:(int)status
{
    for (id key in deliveredMessageKeys)
    {
        ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
        [messageDBService updateMessageDeliveryReport:key withStatus:status];
    }
}

+(void )deleteMessage:( NSString * ) keyString andContactId:( NSString * )contactId withCompletion:(void (^)(NSString *, NSError *))completion{
    
    //db
    ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
    DB_Message* dbMessage=(DB_Message*)[dbService getMessageByKey:@"key" value:keyString];
    [dbMessage setDeletedFlag:[NSNumber numberWithBool:YES]];
    ALMessage * message =  [dbService createMessageEntity:dbMessage];
    bool isUsedForReply = (message.getReplyType == AL_A_REPLY);
    
    if(isUsedForReply)
    {
        dbMessage.replyMessageType = [NSNumber numberWithInt:AL_REPLY_BUT_HIDDEN];
        
    }
    
    NSError *error;
    if (![[dbMessage managedObjectContext] save:&error])
    {
        NSLog(@"Delete Flag Not Set");
    }
    
    ALMessageDBService * dbService2 = [[ALMessageDBService alloc]init];
    DB_Message* dbMessage2=(DB_Message*)[dbService2 getMessageByKey:@"key" value:keyString];
    NSArray *keys = [[[dbMessage2 entity] attributesByName] allKeys];
    NSDictionary *dict = [dbMessage2 dictionaryWithValuesForKeys:keys];
    NSLog(@"DB Message In Del: %@",dict);
    
    
    ALMessageClientService *alMessageClientService =  [[ALMessageClientService alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        [alMessageClientService deleteMessage:keyString andContactId:contactId
                               withCompletion:^(NSString * response, NSError *error) {
                                   if(!error){
                                       //none error then delete from DB.
                                       if(!isUsedForReply)
                                       {
                                           [dbService deleteMessageByKey:keyString];
                                       }
                                   }
                                   completion(response,error);
                               }];
        
    });
    
    
}


+(void)deleteMessageThread:(NSString *)contactId orChannelKey:(NSNumber *)channelKey withCompletion:(void (^)(NSString *, NSError *))completion
{
    ALMessageClientService *alMessageClientService = [[ALMessageClientService alloc] init];
    [alMessageClientService deleteMessageThread:contactId orChannelKey:channelKey withCompletion:^(NSString * response, NSError *error) {
        
        if (!error)
        {
             //delete sucessfull
             NSLog(@"sucessfully deleted !");
             ALMessageDBService * dbService = [[ALMessageDBService alloc] init];
             [dbService deleteAllMessagesByContact:contactId orChannelKey:channelKey];
             
             if(channelKey)
             {
                 [ALChannelService setUnreadCountZeroForGroupID:channelKey];
             }
             else
             {
                 [ALUserService setUnreadCountZeroForContactId:contactId];
             }
         }
         completion(response, error);
         }];
}

+(void) proessUploadImageForMessage:(ALMessage *)message databaseObj:(DB_FileMetaInfo *)fileMetaInfo uploadURL:(NSString *)uploadURL withdelegate:(id)delegate{
    
    
    NSString * docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * timestamp = message.imageFilePath;
    NSString * filePath = [docDirPath stringByAppendingPathComponent:timestamp];
    NSLog(@"FILE_PATH : %@",filePath);
    NSMutableURLRequest * request = [ALRequestHandler createPOSTRequestWithUrlString:uploadURL paramString:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //Create boundary, it can be anything
        NSString *boundary = @"------ApplogicBoundary4QuqLuM1cE5lMwCy";
        // set Content-Type in HTTP header
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        // post body
        NSMutableData *body = [NSMutableData data];
        //Populate a dictionary with all the regular values you would like to send.
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        // add params (all params are strings)
        for (NSString *param in parameters) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        NSString* FileParamConstant;
        if(ALApplozicSettings.isCustomStorageServiceEnabled){
            FileParamConstant = @"file";
        }else{
            FileParamConstant = @"files[]";
        }
        NSData *imageData = [[NSData alloc]initWithContentsOfFile:filePath];
        NSLog(@"Attachment data length: %f",imageData.length/1024.0);
        //Assuming data is not nil we add this to the multipart form
        if (imageData)
        {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", FileParamConstant,message.fileMeta.name] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Type:%@\r\n\r\n", message.fileMeta.contentType] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        //Close off the request with the boundary
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // setting the body of the post to the request
        [request setHTTPBody:body];
        // set URL
        [request setURL:[NSURL URLWithString:uploadURL]];
        NSMutableArray * theCurrentConnectionsArray = [[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue];
        NSArray * theFiletredArray = [theCurrentConnectionsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"keystring == %@", message.key]];
        
        if( theFiletredArray.count>0 ){
            NSLog(@"upload is already running .....not starting new one ....");
            return;
        }
        ALConnection * connection = [[ALConnection alloc] initWithRequest:request delegate:delegate startImmediately:YES];
        connection.keystring = message.key;
        connection.connectionType = @"Image Posting";
        [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] addObject:connection];
        NSLog(@"CONNECTION_BEFORE_MQTT : %@",connection.mData);
    }
    else{
        NSLog(@"<<< ERROR >>> :: FILE DO NOT EXIT AT GIVEN PATH");
    }
    
}

+(void) processImageDownloadforMessage:(ALMessage *) message withdelegate:(id)delegate
{
    NSMutableURLRequest * theRequest;
    if(message.fileMeta.url) {
        NSString *urlString = message.fileMeta.url;
        theRequest = [ALRequestHandler createGETRequestWithUrlStringWithoutHeader:urlString paramString:nil];
    } else if(ALApplozicSettings.isStorageServiceEnabled) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@",KBASE_FILE_URL,IMAGE_DOWNLOAD_ENDPOINT, message.fileMeta.blobKey];
        theRequest = [ALRequestHandler createGETRequestWithUrlString:urlString paramString:nil];
    } else {
        NSString *urlString = [NSString stringWithFormat:@"%@/rest/ws/aws/file/%@",KBASE_FILE_URL,message.fileMeta.blobKey];
      theRequest = [ALRequestHandler createGETRequestWithUrlString:urlString paramString:nil];
    }

    ALConnection * connection = [[ALConnection alloc] initWithRequest:theRequest delegate:delegate startImmediately:YES];
    connection.keystring = message.key;
    connection.connectionType = @"Image Downloading";
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] addObject:connection];
}

+(ALMessage*) processFileUploadSucess: (ALMessage *) message{
    
    ALMessageDBService * dbService = [[ALMessageDBService alloc] init];
    DB_Message *dbMessage =  (DB_Message*)[dbService getMessageByKey:@"key" value:message.key];
    
    dbMessage.fileMetaInfo.blobKeyString = message.fileMeta.blobKey;
    dbMessage.fileMetaInfo.contentType = message.fileMeta.contentType;
    dbMessage.fileMetaInfo.createdAtTime = message.fileMeta.createdAtTime;
    dbMessage.fileMetaInfo.key = message.fileMeta.key;
    dbMessage.fileMetaInfo.name = message.fileMeta.name;
    dbMessage.fileMetaInfo.size = message.fileMeta.size;
    dbMessage.fileMetaInfo.suUserKeyString = message.fileMeta.userKey;
    message.fileMetaKey = message.fileMeta.key;
    [[ALDBHandler sharedInstance].managedObjectContext save:nil];
    return message;
}

+(void)processPendingMessages
{
    ALMessageDBService * dbService = [[ALMessageDBService alloc] init];
    NSMutableArray * pendingMessageArray = [dbService getPendingMessages];
    NSLog(@"service called....%lu",(unsigned long)pendingMessageArray.count);
    
    for(ALMessage *msg  in pendingMessageArray )
    {
        
        if((!msg.fileMeta && !msg.pairedMessageKey))
        {
            NSLog(@"RESENDING_MESSAGE : %@", msg.message);
            [self sendMessages:msg withCompletion:^(NSString *message, NSError *error) {
                if(error)
                {
                    NSLog(@"PENDING_MESSAGES_NO_SENT : %@", error);
                    return;
                }
                NSLog(@"SENT_SUCCESSFULLY....MARKED_AS_DELIVERED : %@", message);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_MESSAGE_SEND_STATUS" object:msg];
            }];
        }
        else if(msg.contentType == ALMESSAGE_CONTENT_VCARD)
        {
            NSLog(@"REACH_PRESENT");
            NSError *THE_ERROR;
            DB_Message *dbMessage = (DB_Message*)[dbService getMeesageById:msg.msgDBObjectId error:&THE_ERROR];
            NSLog(@"ERROR_IF_ANY : %@", THE_ERROR);
            dbMessage.inProgress = [NSNumber numberWithBool:YES];
            dbMessage.isUploadFailed = [NSNumber numberWithBool:NO];
            [[ALDBHandler sharedInstance].managedObjectContext save:nil];
            
            ALMessageClientService * clientService = [ALMessageClientService new];
            NSDictionary *info = [msg dictionary];
            [clientService sendPhotoForUserInfo:info withCompletion:^(NSString *message, NSError *error) {
                
                if(!error)
                {
                    ALMessageService *alMessageService = [ALMessageService new];
                    [ALMessageService proessUploadImageForMessage:msg databaseObj:dbMessage.fileMetaInfo uploadURL:message withdelegate:alMessageService];
                }
            }];
        }
        else
        {
            NSLog(@"FILE_META_PRESENT : %@",msg.fileMeta );
        }
    }
}

+(ALMessage*)getMessagefromKeyValuePair:(NSString*)key andValue:(NSString*)value
{    
    ALMessageDBService * dbService = [[ALMessageDBService alloc]init];
    DB_Message *dbMessage =  (DB_Message*)[dbService getMessageByKey:key value:value];
    return [dbService createMessageEntity:dbMessage];
}

-(void)getMessageInformationWithMessageKey:(NSString *)messageKey withCompletionHandler:(void(^)(ALMessageInfoResponse *msgInfo, NSError *theError))completion
{
    ALMessageClientService *msgClient = [ALMessageClientService new];
    [msgClient getCurrentMessageInformation:messageKey withCompletionHandler:^(ALMessageInfoResponse *msgInfo, NSError *theError) {
        
        if(theError)
        {
            NSLog(@"ERROR IN MSG INFO RESPONSE : %@", theError);
        }
        else
        {
            completion(msgInfo, theError);
        }
    }];
}

+(void)getMessageSENT:(ALMessage*)alMessage  withCompletion:(void (^)( NSMutableArray *, NSError *))completion{
    
    ALMessage * localMessage = [ALMessageService getMessagefromKeyValuePair:@"key" andValue:alMessage.key];
    if(localMessage.key ==  nil){
        [ALMessageService getLatestMessageForUser:[ALUserDefaultsHandler getDeviceKeyString] withCompletion:^(NSMutableArray *message, NSError *error) {
            completion (message,error);
        }];
    }

}
#pragma mark - Multi Receiver API
//================================

+(void)multiUserSendMessage:(ALMessage *)alMessage toContacts:(NSMutableArray*)contactIdsArray toGroups:(NSMutableArray*)channelKeysArray withCompletion:(void(^)(NSString * json, NSError * error)) completion{
    
    [ALUserClientService multiUserSendMessage:[alMessage dictionary] toContacts:contactIdsArray
                                     toGroups:channelKeysArray withCompletion:^(NSString *json, NSError *error) {
        
        if(error)
        {
            NSLog(@"SERVICE_ERROR: Multi User Send Message : %@", error);
        }
        
        completion(json, error);
    }];
}

-(void)connectionDidFinishLoading:(ALConnection *)connection
{
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
    ALMessageDBService * dbService = [[ALMessageDBService alloc] init];
    if ([connection.connectionType isEqualToString:@"Image Posting"])
    {
        DB_Message * dbMessage = (DB_Message*)[dbService getMessageByKey:@"key" value:connection.keystring];
        ALMessage * message = [dbService createMessageEntity:dbMessage];
        NSError * theJsonError = nil;
        NSDictionary *theJson = [NSJSONSerialization JSONObjectWithData:connection.mData options:NSJSONReadingMutableLeaves error:&theJsonError];

        if(ALApplozicSettings.isCustomStorageServiceEnabled){
            [message.fileMeta populate:theJson];
        }else{
            NSDictionary *fileInfo = [theJson objectForKey:@"fileMeta"];
            [message.fileMeta populate:fileInfo];
        }

        ALMessage * almessage =  [ALMessageService processFileUploadSucess:message];
        [ALMessageService sendMessages:almessage withCompletion:^(NSString *message, NSError *error) {
            
            if(error)
            {
                NSLog(@"REACH_SEND_ERROR : %@",error);
                return;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_MESSAGE_SEND_STATUS" object:almessage];
        }];
    }
}

-(void)connection:(ALConnection *)connection didSendBodyData:(NSInteger)bytesWritten
totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
//    NSLog(@"didSendBodyData..");
}

-(void)connection:(ALConnection *)connection didReceiveData:(NSData *)data
{
    [connection.mData appendData:data];
    if ([connection.connectionType isEqualToString:@"Image Posting"])
    {
        NSLog(@"FILE_POSTING_MSG_SERVICE");
        return;
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"OFFLINE_FAILED_TO_UPLOAD : %@", error);
}

+(ALMessage *)createCustomTextMessageEntitySendTo:(NSString *)to withText:(NSString*)text
{
    return [self createMessageEntityOfContentType:ALMESSAGE_CONTENT_CUSTOM toSendTo:to withText:text];;
}

+(ALMessage *)createHiddenMessageEntitySentTo:(NSString*)to withText:(NSString*)text
{
    return [self createMessageEntityOfContentType:ALMESSAGE_CONTENT_HIDDEN toSendTo:to withText:text];
}

+(ALMessage *)createMessageEntityOfContentType:(int)contentType
                                      toSendTo:(NSString*)to
                                      withText:(NSString*)text{
    
    ALMessage * theMessage = [ALMessage new];
    
    theMessage.contactIds = to;//1
    theMessage.to = to;//2
    theMessage.message = text;//3
    theMessage.contentType = contentType;//4
    
    theMessage.type = @"5";
    theMessage.createdAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
    theMessage.deviceKey = [ALUserDefaultsHandler getDeviceKeyString ];
    theMessage.sendToDevice = NO;
    theMessage.shared = NO;
    theMessage.fileMeta = nil;
    theMessage.storeOnDevice = NO;
    theMessage.key = [[NSUUID UUID] UUIDString];
    theMessage.delivered = NO;
    theMessage.fileMetaKey = nil;
    
    return theMessage;
}

+(ALMessage *)createMessageWithMetaData:(NSMutableDictionary *)metaData andContentType:(short)contentType
                          andReceiverId:(NSString *)receiverId andMessageText:(NSString *)msgTxt
{
    ALMessage * theMessage = [self createMessageEntityOfContentType:contentType toSendTo:receiverId withText:msgTxt];

    theMessage.metadata = metaData;
    return theMessage;
}

-(NSUInteger)getMessagsCountForUser:(NSString *)userId
{
    ALMessageDBService * dbService = [ALMessageDBService new];
    return [dbService getMessagesCountFromDBForUser:userId];
}

//============================================================================================================
#pragma mark ADD BROADCAST MESSAGE TO DB
//============================================================================================================

+(void)addBroadcastMessageToDB:(ALMessage *)alMessage {
    [ALMessageDBService addBroadcastMessageToDB:alMessage];
}

//============================================================================================================
#pragma mark GET LATEST MESSAGE FOR USER/CHANNEL
//============================================================================================================

-(ALMessage *)getLatestMessageForUser:(NSString *)userId
{
    ALMessageDBService *alMsgDBService = [[ALMessageDBService alloc] init];
    return [alMsgDBService getLatestMessageForUser:userId];
}

-(ALMessage *)getLatestMessageForChannel:(NSNumber *)channelKey excludeChannelOperations:(BOOL)flag
{
    ALMessageDBService *alMsgDBService = [[ALMessageDBService alloc] init];
    return [alMsgDBService getLatestMessageForChannel:channelKey excludeChannelOperations:flag];
}

-(ALMessage *)getALMessageByKey:(NSString*)messageReplyId
{
    //GET Message From Server if not present on Server
    ALMessageDBService *alMsgDBService = [[ALMessageDBService alloc] init];
    DB_Message * dbMessage = (DB_Message*) [alMsgDBService getMessageByKey:@"key" value:messageReplyId];
    return [alMsgDBService createMessageEntity:dbMessage];
}

+(void)addOpenGroupMessage:(ALMessage*)alMessage{
    {
        
        if(!alMessage){
            return;
        }
        
        NSMutableArray * singlemessageArray = [[NSMutableArray alloc] init];
        [singlemessageArray addObject:alMessage];
        NSMutableArray * hiddenMsgFilteredArray = [[NSMutableArray alloc] initWithArray:singlemessageArray];
        for(ALMessage * message in hiddenMsgFilteredArray)
        {
            
            if (message.groupId != nil && message.contentType == ALMESSAGE_CHANNEL_NOTIFICATION) {
                ALChannelService *channelService = [[ALChannelService alloc] init];
                [channelService syncCallForChannel];
                if([message isMsgHidden]) {
                    [singlemessageArray removeObject:message];
                }
            }
            
        }
        
        [ALUserService processContactFromMessages:singlemessageArray withCompletion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NEW_MESSAGE_NOTIFICATION object:singlemessageArray userInfo:nil];
            
        }];
        
    }
}


@end
