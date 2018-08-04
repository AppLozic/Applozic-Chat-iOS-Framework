//
//  MessageReplyView.m
//  Applozic
//
//  Created by Adarsh Kumar Mishra on 4/21/17.
//  Copyright © 2017 applozic Inc. All rights reserved.
//

#import "MessageReplyView.h"
#import "UIImageView+WebCache.h"
#import  "ALUtilityClass.h"
#import "ALMessageService.h"
#import "ALContactService.h"
#import "ALApplozicSettings.h"
#import "ALLocationCell.h"
#import "ALDataNetworkConnection.h"

#define REPLY_VIEW_PADDING 5
#define FONT_NAME @"Helvetica"
#define FONT_SIZE 13
#define ATTACHMENT_PREVIEW_WIDTH 60

#define ATTACHMENT_TEXT_PHOTOS @"photo"
#define ATTACHMENT_TEXT_AUDIO @"Audio"
#define ATTACHMENT_TEXT_VIDEO #"Video"

#define ATTACHMENT_TEXT_CONATCT @"Conatct"
#define ATTACHMENT_TEXT_DOCUMENT @"Attachment"
#define SENT_MESSAGE_DISPLAY_NAME @"You"


@implementation MessageReplyView



/**
 build and pouplates values in views for

 @param alMessage ALMessage
 @param superView parent views
 @return retruns UIViews
 */
-(UIView*)populateUI:(ALMessage*)alMessage withSuperView:(UIView*)superView
{
    
    NSString * messageReplyId = [alMessage.metadata valueForKey:AL_MESSAGE_REPLY_KEY];
  //  NSString *attachmentType;
    if(messageReplyId)
    {
        
        ALMessage * replyMessage = [[ALMessageService new] getALMessageByKey:messageReplyId];
        
        CGRect frame = superView.frame;
        
        if(replyMessage.fileMeta || replyMessage.isLocationMessage || replyMessage.isContactMessage)
        {
            [self buildAttachentPreview:frame];
            [superView addSubview:self.attachmentImage];
        }else{
            [self.attachmentImage setHidden:YES];
        }
        [self buildDisplayNameView:frame];
        [self buildMessageTextView:frame];
        
        [superView  addSubview:self.contactName];
        [superView addSubview:self.replyMessageText];
        [self pouplateValues:replyMessage];
    }
    
    return self;
}

/**
 Calculates require width for rendering reply view

 @param alMessage Message details
 @param viewSize  viewWidth
 @return returns total width required
 */
-(CGFloat) getWidthRequired:(ALMessage *)replyMessage andViewSize:(CGSize)viewSize
{
    
  
    if( (replyMessage.fileMeta && replyMessage.message.length==0) ||  replyMessage.isContactMessage || replyMessage.isLocationMessage)
    {
        replyMessage.message = [self getMessageText:replyMessage];
    }
    
    CGFloat maxWidth =  viewSize.width-(115);
    
    if(replyMessage.fileMeta)
    {
        maxWidth = viewSize.width-(115) -( REPLY_VIEW_PADDING + ATTACHMENT_PREVIEW_WIDTH);
    }
    CGSize size = [ALUtilityClass getSizeForText:replyMessage.message maxWidth:maxWidth
                                            font:FONT_NAME
                                        fontSize:FONT_SIZE];
    ALContact * senderContact = [[ALContactService new] loadContactByKey:@"userId" value:replyMessage.to];
    
    if(replyMessage.isSentMessage)
    {
        senderContact.displayName = SENT_MESSAGE_DISPLAY_NAME;
    }
    
    
    CGSize contactNameSize = [ALUtilityClass getSizeForText:senderContact.getDisplayName maxWidth:maxWidth
                              font:FONT_NAME
                          fontSize:15];
    
    
    if(contactNameSize.width > size.width)
    {
        size = contactNameSize;
         size.width  =  size.width +10;
    }
    
    
    if(replyMessage.fileMeta || replyMessage.isLocationMessage || replyMessage.isContactMessage)
    {
        size.width = size.width + 2*REPLY_VIEW_PADDING + ATTACHMENT_PREVIEW_WIDTH;
    }
    return size.width;
    
}


/**
 build UILabel view to show message text or attachment text for reply message.

 @param frame frame where UILabel should be added
 */
-(void)buildMessageTextView: (CGRect)frame
{
    self.replyMessageText = [[UILabel alloc]init];
    self.replyMessageText.numberOfLines =3;
    [self.replyMessageText setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
    
    
    self.replyMessageText.frame = CGRectMake( REPLY_VIEW_PADDING ,
                                             self.contactName.frame.origin.y + self.contactName.frame.size.height + REPLY_VIEW_PADDING,
                                             frame.size.width- self.attachmentImage.frame.size.width+5,
                                             30);
    
}

/**
 build UIImageView  to show attachment preview.
 
 @param frame frame where UILabel should be added
 */
-(void)buildAttachentPreview: (CGRect)frame
{
    self.attachmentImage =  [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - ATTACHMENT_PREVIEW_WIDTH,
                                                                          0,
                                                                          ATTACHMENT_PREVIEW_WIDTH,
                                                                          frame.size.height)];
    
    
    self.attachmentImage.clipsToBounds = YES;
    self.attachmentImage.layer.cornerRadius = 2;
}

/**
 build UILabel view to show displayname of contacts.
 
 @param frame frame where UILabel should be added
 */
-(void)buildDisplayNameView: (CGRect)frame
{
    self.contactName = [[UILabel alloc]init];
    self.contactName.frame =  CGRectMake(REPLY_VIEW_PADDING,
                                         REPLY_VIEW_PADDING,
                                         frame.size.width,
                                         20);
    [self.contactName setFont:[UIFont fontWithName:FONT_NAME size:15]];
}

-(void)pouplateValues:(ALMessage*)replyMessage
{
    NSURL * url;
    
    replyMessage.message = [self getMessageText:replyMessage];
    
    if(replyMessage.isSentMessage)
    {
        self.contactName.text = SENT_MESSAGE_DISPLAY_NAME;
    }
    else
    {
        ALContact * senderContact = [[ALContactService new] loadContactByKey:@"userId" value:replyMessage.to];
        self.contactName.text =senderContact.getDisplayName;
    }
    
    self.replyMessageText.text = replyMessage.message;
    
    if(replyMessage.isContactMessage)
    {
        [self.attachmentImage setImage:[ALUtilityClass getImageFromFramworkBundle:@"ic_person.png"]];
        
    }
    else if(replyMessage.isLocationMessage)
    {
        if([ALDataNetworkConnection checkDataNetworkAvailable])
        {
            NSString * finalURl = [ALUtilityClass getLocationUrl:replyMessage size:self.attachmentImage.frame];
            NSURL *url = [NSURL URLWithString:finalURl]  ;
            [self.attachmentImage sd_setImageWithURL:url];
        }
        else
        {
            [self.attachmentImage setImage:[ALUtilityClass getImageFromFramworkBundle:@"ic_map_no_data.png"]];
        }
        
    }
    
    else if(replyMessage.fileMeta)
    {
        if(replyMessage.isDocumentMessage){
            
            [self.attachmentImage setImage:[ALUtilityClass getImageFromFramworkBundle:@"documentReceive.png"]];
            return;
        }
        if([replyMessage.fileMeta.contentType hasPrefix:@"audio"])
        {
            [self.attachmentImage setImage:[ALUtilityClass getImageFromFramworkBundle:@"ic_mic.png"]];
            return;
        }else if([replyMessage.fileMeta.contentType hasPrefix:@"video"]){
        
            if(replyMessage.imageFilePath){
                NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString * filePath = [docDir stringByAppendingPathComponent:replyMessage.imageFilePath];
                NSURL *url = [NSURL fileURLWithPath:filePath];
                
                [ALUtilityClass subVideoImage:url withCompletion:^(UIImage *image) {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [self.attachmentImage setImage:image];
                        return;
                    });
                }];
            }else{
                [self.attachmentImage setImage:[ALUtilityClass getImageFromFramworkBundle:@"ic_action_video.png"]];
            }
            return;
        }else if([replyMessage.fileMeta.contentType hasPrefix:@"image"]){
            if ( replyMessage.imageFilePath != NULL)
            {
                NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString * filePath = [docDir stringByAppendingPathComponent:replyMessage.imageFilePath];
                url = [NSURL fileURLWithPath:filePath];
            }
            else
            {
                url = [NSURL URLWithString:replyMessage.fileMeta.thumbnailUrl];
            }
            
            [self.attachmentImage sd_setImageWithURL:url];
        }else{
            [self.attachmentImage setImage:[ALUtilityClass getImageFromFramworkBundle:@"documentReceive.png"]];
        }
    }

}

-(NSString*)getMessageText:(ALMessage*)replyMessage{
 
    if(replyMessage.isLocationMessage)
    {
        return @"Location";
    }
    else if(replyMessage.message.length >0 )
    {
        return replyMessage.message;
    }
    if(replyMessage.isContactMessage)
    {
       return @"Contact";
        
    }
    else if([replyMessage.fileMeta.contentType hasPrefix:@"audio"])
    {
        return @"Audio";
    }
    else if([replyMessage.fileMeta.contentType hasPrefix:@"video"])
    {
        return @"Video";
    }
    else if([replyMessage.fileMeta.contentType hasPrefix:@"image"])
    {
        return @"Image";
    }
    return @"Attachment";
}

@end
