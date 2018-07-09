//
//  ALMessageWrapper.m
//  Applozic
//
//  Created by Adarsh Kumar Mishra on 12/14/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALMessageServiceWrapper.h"
#import <Applozic/ALMessageService.h>
#import <Applozic/ALMessageDBService.h>
#import <Applozic/ALConnection.h>
#import <Applozic/ALConnectionQueueHandler.h>
#import <Applozic/ALMessageClientService.h>
#include <tgmath.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Applozic/ALApplozicSettings.h>


@implementation ALMessageServiceWrapper

-(void)sendTextMessage:(NSString*)text andtoContact:(NSString*)toContactId {
    
    ALMessage * almessage = [self createMessageEntityOfContentType:ALMESSAGE_CONTENT_DEFAULT toSendTo:toContactId withText:text];
    
    [ALMessageService sendMessages:almessage withCompletion:^(NSString *message, NSError *error) {
        
        if(error)
        {
            NSLog(@"REACH_SEND_ERROR : %@",error);
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_MESSAGE_SEND_STATUS" object:almessage];
    }];
}


-(void)sendTextMessage:(NSString*)messageText andtoContact:(NSString*)contactId orGroupId:(NSNumber*)channelKey{
    
    ALMessage * almessage = [self createMessageEntityOfContentType:ALMESSAGE_CONTENT_DEFAULT toSendTo:contactId withText:messageText];
    
    almessage.groupId=channelKey;
    
    [ALMessageService sendMessages:almessage withCompletion:^(NSString *message, NSError *error) {
        
        if(error)
        {
            NSLog(@"REACH_SEND_ERROR : %@",error);
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_MESSAGE_SEND_STATUS" object:almessage];
    }];
}

-(void) sendMessage:(ALMessage *)alMessage
withAttachmentAtLocation:(NSString *)attachmentLocalPath
andWithStatusDelegate:(id)statusDelegate
     andContentType:(short)contentype{
    
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
            [self.messageServiceDelegate uploadDownloadFailed:alMessage];
            return;
        }
        
        [ALMessageService proessUploadImageForMessage:theMessage databaseObj:theMessageEntity.fileMetaInfo uploadURL:message  withdelegate:self];
        
    }];
    
}



-(ALMessage *)createMessageEntityOfContentType:(int)contentType
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



-(void) downloadMessageAttachment:(ALMessage*)alMessage{
    
    [ALMessageService processImageDownloadforMessage:alMessage withdelegate:self];
    
}

-(void)connectionDidFinishLoading:(ALConnection *)connection{
    
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
                [self.messageServiceDelegate uploadDownloadFailed:almessage];
                return;
            }else{
                [self.messageServiceDelegate uploadCompleted:almessage];
            }
        }];
        
    } else {
        
        //This is download Sucessfull...
        DB_Message * messageEntity = (DB_Message*)[dbService getMessageByKey:@"key" value:connection.keystring];
        
        NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSArray *componentsArray = [messageEntity.fileMetaInfo.name componentsSeparatedByString:@"."];
        NSString *fileExtension = [componentsArray lastObject];
        NSString * filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_local.%@",connection.keystring,fileExtension]];
        [connection.mData writeToFile:filePath atomically:YES];
        
        // UPDATE DB
        messageEntity.inProgress = [NSNumber numberWithBool:NO];
        messageEntity.isUploadFailed=[NSNumber numberWithBool:NO];
        messageEntity.filePath = [NSString stringWithFormat:@"%@_local.%@",connection.keystring,fileExtension];
        [[ALDBHandler sharedInstance].managedObjectContext save:nil];
        ALMessage * almessage = [[ALMessageDBService new ] createMessageEntity:messageEntity];
        [self.messageServiceDelegate DownloadCompleted:almessage];
    }
    
}

-(void)connection:(ALConnection *)connection didReceiveData:(NSData *)data{
    
    [connection.mData appendData:data];
    
    if ([connection.connectionType isEqualToString:@"Image Posting"])
    {
        NSLog(@" file posting done");
        return;
    }
    [self.messageServiceDelegate updateBytesDownloaded:connection.mData.length];
    
}

-(void)connection:(ALConnection *)connection didSendBodyData:(NSInteger)bytesWritten
totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    //upload percentage
    NSLog(@"didSendBodyData..upload is in process...");
    [self.messageServiceDelegate updateBytesUploaded:totalBytesWritten];
}


@end
