//
//  ALMessageWrapper.h
//  Applozic
//
//  Created by Adarsh Kumar Mishra on 12/14/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ALMessage.h"

@protocol MessageServiceWrapperDelegate <NSObject>

@optional

-(void)updateBytesDownloaded:(NSUInteger) bytesReceived;
-(void)updateBytesUploaded:(NSUInteger) bytesSent;
-(void)uploadDownloadFailed:(ALMessage*)alMessage;
-(void)uploadCompleted:(ALMessage *) alMessage;
-(void)DownloadCompleted:(ALMessage *) alMessage;

@end

@interface ALMessageServiceWrapper : NSObject <NSURLConnectionDataDelegate>

@property (strong, nonatomic) id <MessageServiceWrapperDelegate> messageServiceDelegate;

-(void)sendTextMessage:(NSString*)text andtoContact:(NSString*)toContactId;

-(void)sendTextMessage:(NSString*)messageText andtoContact:(NSString*)contactId orGroupId:(NSNumber*)channelKey;

-(void) sendMessage:(ALMessage *)alMessage
withAttachmentAtLocation:(NSString *)attachmentLocalPath
andWithStatusDelegate:(id)statusDelegate
     andContentType:(short)contentype;

-(void) downloadMessageAttachment:(ALMessage*)alMessage;

-(ALMessage *)createMessageEntityOfContentType:(int)contentType
                                      toSendTo:(NSString*)to
                                      withText:(NSString*)text;


@end
