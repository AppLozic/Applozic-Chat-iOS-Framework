//
//  ALDocumentsCell.m
//  Applozic
//
//  Created by devashish on 29/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

// Constants
#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"
#define DATE_LABEL_SIZE 12

#import "ALDocumentsCell.h"
#import "ALMessage.h"
#import "ALContactDBService.h"
#import "ALColorUtility.h"
#import "UIImageView+WebCache.h"
#import "KAProgressLabel.h"
#import "ALUtilityClass.h"
#import "ALMessageService.h"
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"


#define BUBBLE_PADDING_X 13
#define BUBBLE_PADDING_X_OUTBOX 60
#define BUBBLE_PADDING_Y 27
#define BUBBLE_HEIGHT 80
#define BUBBLE_HEIGHT_GRP 110
#define BUBBLE_PADDING_WIDTH 120

#define MESSAGE_PADDING_X 10
#define MESSAGE_PADDING_Y 10
#define MESSAGE_PADDING_WIDTH 20
#define MESSAGE_PADDING_HEIGHT 20

#define CHANNEL_PADDING_X 5
#define CHANNEL_PADDING_Y 2
#define CHANNEL_PADDING_WIDTH 30
#define CHANNEL_PADDING_HEIGHT 20

#define IMAGE_VIEW_PADDING_X 00
#define IMAGE_VIEW_PADDING_Y 10
#define IMAGE_VIEW_WIDTH 60
#define IMAGE_VIEW_HEIGHT 60

#define DATE_PADDING_X 20
#define DATE_PADDING_WIDTH 20
#define DATE_HEIGHT 20
#define DATE_WIDTH 80

#define MSG_STATUS_WIDTH 20
#define MSG_STATUS_HEIGHT 20
#define SIZE_HEIGHT 20

#define DOC_NAME_PADDING_X 5
#define DOC_NAME_PADDING_Y 0
#define DOC_NAME_PADDING_WIDTH 20
#define DOC_NAME_HEIGHT 60

//VIEW
#define DOWNLOAD_RETRY_PADDING_X 5
#define DOWNLOAD_RETRY_PADDING_Y -2
#define DOWNLOAD_RETRY_PADDING_WIDTH 70
#define DOWNLOAD_RETRY_PADDING_HEIGHT 70
//BUTTON
#define DOWNLOAD_RETRY_BUTTON_PADDING_X 15
#define DOWNLOAD_RETRY_BUTTON_PADDING_Y 0
#define DOWNLOAD_RETRY_BUTTON_PADDING_WIDTH 40
#define DOWNLOAD_RETRY_BUTTON_PADDING_HEIGHT 40

@implementation ALDocumentsCell
{
    CGFloat msgFrameHeight;
    NSURL *fileSourceURL;
    UIViewController *viewController;
}

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        [self.mDowloadRetryButton addTarget:self action:@selector(downloadRetry) forControlEvents:UIControlEventTouchUpInside];
        [self.mDowloadRetryButton setBackgroundColor:[UIColor clearColor]];
        
        self.tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suggestionAction)];
        self.tapper.numberOfTapsRequired = 1;
        
        [self.mImageView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.mImageView];
        
        self.documentName = [[UILabel alloc] init];
        [self.documentName setBackgroundColor:[UIColor clearColor]];
        [self.documentName setFont:[UIFont fontWithName:@"DroidArabicKufi" size:14]];
        [self.documentName setNumberOfLines:4];
        [self.contentView addSubview:self.documentName];
        
        self.downloadRetryView = [UIView new];
        [self.downloadRetryView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
        [self.contentView addSubview:self.downloadRetryView];
        self.downloadRetryView.layer.cornerRadius = 5;
        self.downloadRetryView.layer.masksToBounds = YES;
        
        self.sizeLabel = [UILabel new];
        [self.sizeLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
        [self.sizeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.sizeLabel setTextColor:[UIColor clearColor]];
        [self.sizeLabel setTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.sizeLabel];
        
        UITapGestureRecognizer * menuTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(proccessTapForMenu:)];
        [self.contentView addGestureRecognizer:menuTapGesture];

        
    }
    return self;
}

-(instancetype) populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize
{
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    
    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];
    
    [self.contentView bringSubviewToFront:self.mDowloadRetryButton];
    [self.replyUIView removeFromSuperview];
    self.progresLabel.alpha = 0;
    [self.mNameLabel setHidden:YES];
    [self setMMessage:alMessage];
    [self.mBubleImageView setUserInteractionEnabled:NO];
    [self.mImageView setHidden:YES];
    [self.mMessageStatusImageView setHidden:YES];
    [self.mChannelMemberName setHidden:YES];
    [self.replyParentView setHidden:YES];
    
    ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
    ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
    NSString *receiverName = [alContact getDisplayName];
    
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150 font:self.mDateLabel.font.fontName fontSize:self.mDateLabel.font.pointSize];
    
    [self.replyUIView removeFromSuperview];
    
    if([alMessage.type isEqualToString:@MT_INBOX_CONSTANT])
    {
        [self.mUserProfileImageView setFrame:CGRectMake(USER_PROFILE_PADDING_X, 0, USER_PROFILE_WIDTH, USER_PROFILE_HEIGHT)];
        
        if([ALApplozicSettings isUserProfileHidden])
        {
            [self.mUserProfileImageView setFrame:CGRectMake(USER_PROFILE_PADDING_X, 0, 0, USER_PROFILE_HEIGHT)];
        }
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];
        
        self.mUserProfileImageView.layer.cornerRadius = self.mUserProfileImageView.frame.size.width/2;
        self.mUserProfileImageView.layer.masksToBounds = YES;
        
        [self.documentName setTextColor:[UIColor grayColor]];
        
  
        CGFloat requiredHeight  = BUBBLE_HEIGHT;
        CGFloat imageViewY = self.mBubleImageView.frame.origin.y + IMAGE_VIEW_PADDING_Y ;
                [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                  self.mUserProfileImageView.frame.origin.y,
                                                  viewSize.width - BUBBLE_PADDING_WIDTH, requiredHeight)];
          if(alMessage.groupId)
        {
            [self.mChannelMemberName setText:receiverName];
            [self.mChannelMemberName setHidden:NO];
            [self.mChannelMemberName setTextColor: [ALColorUtility getColorForAlphabet:receiverName]];
            
            
            self.mChannelMemberName.frame = CGRectMake(self.mBubleImageView.frame.origin.x + CHANNEL_PADDING_X,
                                                       self.mBubleImageView.frame.origin.y + CHANNEL_PADDING_Y,
                                                       self.mBubleImageView.frame.size.width +
                                                       CHANNEL_PADDING_WIDTH, CHANNEL_PADDING_HEIGHT);
            requiredHeight =  requiredHeight + self.mChannelMemberName.frame.size.height;
            imageViewY = imageViewY + self.mChannelMemberName.frame.size.height;
            
        }
        
        if(alMessage.isAReplyMessage)
        {
            
            [self processReplyOfChat:alMessage andViewSize:viewSize];
            
            requiredHeight =  requiredHeight + self.replyParentView.frame.size.height;
            imageViewY = imageViewY + self.replyParentView.frame.size.height;
            
        }
        
        
        [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                  self.mUserProfileImageView.frame.origin.y,
                                                  viewSize.width - BUBBLE_PADDING_WIDTH, requiredHeight)];
        
        [self.mImageView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x,
                                             imageViewY,
                                             IMAGE_VIEW_WIDTH, IMAGE_VIEW_HEIGHT)];
        
        [self.downloadRetryView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + DOWNLOAD_RETRY_PADDING_X,
                                                    self.mImageView.frame.origin.y + DOWNLOAD_RETRY_PADDING_Y,
                                                    DOWNLOAD_RETRY_PADDING_WIDTH, DOWNLOAD_RETRY_PADDING_HEIGHT)];
        
        [self.mDateLabel setFrame:CGRectMake(self.mBubleImageView.frame.origin.x,
                                             self.mBubleImageView.frame.size.height,
                                             DATE_WIDTH, DATE_HEIGHT)];
        
        self.mNameLabel.frame = self.mUserProfileImageView.frame;
        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:receiverName]];
        
        [self.mDowloadRetryButton setFrame:CGRectMake(self.downloadRetryView.frame.origin.x + DOWNLOAD_RETRY_BUTTON_PADDING_X,
                                                      self.downloadRetryView.frame.origin.y + DOWNLOAD_RETRY_BUTTON_PADDING_Y,
                                                      DOWNLOAD_RETRY_BUTTON_PADDING_WIDTH, DOWNLOAD_RETRY_BUTTON_PADDING_HEIGHT)];
        
        [self.sizeLabel setFrame:CGRectMake(self.downloadRetryView.frame.origin.x,
                                            self.mDowloadRetryButton.frame.origin.y + self.mDowloadRetryButton.frame.size.height,
                                            self.downloadRetryView.frame.size.width, SIZE_HEIGHT)];
        
        [self.documentName setFrame:CGRectMake(self.downloadRetryView.frame.origin.x + self.downloadRetryView.frame.size.width
                                               + 5, self.downloadRetryView.frame.origin.y,
                                               self.mBubleImageView.frame.size.width - self.mImageView.frame.size.width - DOC_NAME_PADDING_WIDTH,
                                               DOC_NAME_HEIGHT)];
        
        [self setupProgressValueX: (self.downloadRetryView.frame.origin.x + self.downloadRetryView.frame.size.width/2 - 30)
                             andY: (self.downloadRetryView.frame.origin.y + self.downloadRetryView.frame.size.height/2 - 30)];
        
        [self.mImageView setImage:[ALUtilityClass getImageFromFramworkBundle:@"documentReceive.png"]];
        
        if(alContact.contactImageUrl)
        {
            NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
        
            [self.mUserProfileImageView sd_setImageWithURL:theUrl1 placeholderImage:[ALUtilityClass getImageFromFramworkBundle:@"ic_contact_picture_holo_light.png"]  options:SDWebImageRefreshCached];
        }
        else
        {
            [self.mUserProfileImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil options:SDWebImageRefreshCached];
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:receiverName];
        }
        
        if (alMessage.imageFilePath == nil)
        {
            self.mDowloadRetryButton.alpha = 1;
            self.downloadRetryView.alpha = 1;
            self.sizeLabel.alpha = 1;
            [self.sizeLabel setText:[alMessage.fileMeta getTheSize]];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];
        }
        else
        {
             self.mDowloadRetryButton.alpha = 0;
            self.downloadRetryView.alpha = 0;
            self.sizeLabel.alpha = 0;
        }
        
        if (alMessage.inProgress == YES)
        {
            self.progresLabel.alpha = 1;
            self.mDowloadRetryButton.alpha = 0;
            self.downloadRetryView.alpha = 0;
            self.sizeLabel.alpha = 0;
        }
        else
        {
            self.progresLabel.alpha = 0;
        }
        
    }
    else
    {
        [self.mUserProfileImageView setFrame:CGRectMake(viewSize.width - USER_PROFILE_PADDING_X_OUTBOX, 0, 0, USER_PROFILE_HEIGHT)];
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];
        
        [self.mMessageStatusImageView setHidden:NO];
        
        [self.documentName setTextColor:[UIColor whiteColor]];
 
        [self.mBubleImageView setFrame:CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + BUBBLE_PADDING_X_OUTBOX),
                                                  self.mUserProfileImageView.frame.origin.y,
                                                  viewSize.width - BUBBLE_PADDING_WIDTH, BUBBLE_HEIGHT)];
        [self.mImageView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x,
                                             self.mBubleImageView.frame.origin.y ,
                                             IMAGE_VIEW_WIDTH, IMAGE_VIEW_HEIGHT)];
        if( alMessage.isAReplyMessage)
        {
            
            [self processReplyOfChat:alMessage andViewSize:viewSize];
            
            [self.mBubleImageView setFrame:CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + BUBBLE_PADDING_X_OUTBOX),
                                                      self.mUserProfileImageView.frame.origin.y,
                                                      viewSize.width - BUBBLE_PADDING_WIDTH, BUBBLE_HEIGHT + self.replyParentView.frame.size.height)];
            
            [self.mImageView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x,
                                                 self.mBubleImageView.frame.origin.y + self.replyUIView.frame.size.height,
                                                 IMAGE_VIEW_WIDTH, IMAGE_VIEW_HEIGHT)];
            
        }
        
        [self.downloadRetryView setFrame:CGRectMake(self.mImageView.frame.origin.x + DOWNLOAD_RETRY_PADDING_X,
                                                    self.mImageView.frame.origin.y + DOWNLOAD_RETRY_PADDING_Y,
                                                    DOWNLOAD_RETRY_PADDING_WIDTH, DOWNLOAD_RETRY_PADDING_HEIGHT)];
        
        [self.mDowloadRetryButton setFrame:CGRectMake(self.downloadRetryView.frame.origin.x + DOWNLOAD_RETRY_BUTTON_PADDING_X,
                                                      self.downloadRetryView.frame.origin.y + DOWNLOAD_RETRY_BUTTON_PADDING_Y,
                                                      DOWNLOAD_RETRY_BUTTON_PADDING_WIDTH, DOWNLOAD_RETRY_BUTTON_PADDING_HEIGHT)];
        
        [self.sizeLabel setFrame:CGRectMake(self.downloadRetryView.frame.origin.x,
                                            self.mDowloadRetryButton.frame.origin.y + self.mDowloadRetryButton.frame.size.height,
                                            self.downloadRetryView.frame.size.width, SIZE_HEIGHT)];
        
        [self.documentName setFrame:CGRectMake(self.downloadRetryView.frame.origin.x + self.downloadRetryView.frame.size.width + 5,
                                               self.mImageView.frame.origin.y + 5,
                                               self.mBubleImageView.frame.size.width - self.mImageView.frame.size.width - DOC_NAME_PADDING_WIDTH,
                                               DOC_NAME_HEIGHT)];

        [self setupProgressValueX: (self.downloadRetryView.frame.origin.x + self.downloadRetryView.frame.size.width/2 - 30)
                             andY: (self.downloadRetryView.frame.origin.y + self.downloadRetryView.frame.size.height/2 - 30)];
        

        
        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x +
                                            self.mBubleImageView.frame.size.width) - theDateSize.width - DATE_PADDING_WIDTH,
                                           self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height,
                                           theDateSize.width, DATE_HEIGHT);
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width,
                                                        self.mDateLabel.frame.origin.y,
                                                        MSG_STATUS_WIDTH, MSG_STATUS_HEIGHT);
        
        [self.mImageView setImage:[ALUtilityClass getImageFromFramworkBundle:@"documentSend.png"]];
        
         msgFrameHeight = self.mBubleImageView.frame.size.height;
        
        self.progresLabel.alpha = 0;
        
        self.mDowloadRetryButton.alpha = 0;
        self.downloadRetryView.alpha = 0;
        self.sizeLabel.alpha = 0;
        if (alMessage.inProgress == YES)
        {
            self.progresLabel.alpha = 1;
            //            NSLog(@"calling you progress label....");
        }
        else if(!alMessage.imageFilePath && alMessage.fileMeta.blobKey)
        {
             self.mDowloadRetryButton.alpha = 1;
            self.downloadRetryView.alpha = 1;
            self.sizeLabel.alpha = 1;
            [self.sizeLabel setText:[alMessage.fileMeta getTheSize]];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];
        }
        else if (alMessage.imageFilePath && !alMessage.fileMeta.blobKey)
        {
              self.mDowloadRetryButton.alpha = 1;
            self.downloadRetryView.alpha = 1;
            self.sizeLabel.alpha = 1;
            [self.sizeLabel setText:[alMessage.fileMeta getTheSize]];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"uploadI1.png"] forState:UIControlStateNormal];
        }
    }
    
    [self.documentName setText:alMessage.fileMeta.name];
    [self.mImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    if(alMessage.imageFilePath != nil && alMessage.fileMeta.blobKey)
    {
        NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * filePath = [docDir stringByAppendingPathComponent:alMessage.imageFilePath];
        [self.mBubleImageView setUserInteractionEnabled:YES];
        [self.mBubleImageView addGestureRecognizer:self.tapper];
        fileSourceURL = [NSURL fileURLWithPath:filePath];
        [self.mImageView setHidden:NO];
    }
    
    [self addShadowEffects];
    
    self.mDateLabel.text = theDate;
    
    if ([alMessage.type isEqualToString:@MT_OUTBOX_CONSTANT])
    {
        self.mMessageStatusImageView.hidden = NO;
        NSString * imageName;
        
        switch (alMessage.status.intValue)
        {
            case DELIVERED_AND_READ :
            {
                imageName = @"ic_action_read.png";
            }
                break;
            case DELIVERED:
            {
                imageName = @"ic_action_message_delivered.png";
            }
                break;
            case SENT:
            {
                imageName = @"ic_action_message_sent.png";
            }
                break;
            default:
            {
                imageName = @"ic_action_about.png";
            }
                break;
        }
        self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:imageName];
    }
    

    
    return self;
}

#pragma mark - Menu option tap Method -

-(void) proccessTapForMenu:(id)tap{
    
//    UIMenuItem * messageForward = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"forwardOptionTitle", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Forward", @"") action:@selector(messageForward:)];
    UIMenuItem * messageReply = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"replyOptionTitle", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Reply", @"") action:@selector(messageReply:)];
    
    if ([self.mMessage.type isEqualToString:@MT_INBOX_CONSTANT]){
        
        [[UIMenuController sharedMenuController] setMenuItems: @[messageReply]];
        
    }else if ([self.mMessage.type isEqualToString:@MT_OUTBOX_CONSTANT]){

        
//        UIMenuItem * msgInfo = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"infoOptionTitle", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Info", @"") action:@selector(msgInfo:)];
        
        [[UIMenuController sharedMenuController] setMenuItems: @[messageReply]];
    }
    [[UIMenuController sharedMenuController] update];
    
}




-(void) addShadowEffects
{
    self.mBubleImageView.layer.shadowOpacity = 0.3;
    self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
    self.mBubleImageView.layer.shadowRadius = 1;
    self.mBubleImageView.layer.masksToBounds = NO;
}

-(void) setupProgressValueX:(CGFloat)cooridinateX andY:(CGFloat)cooridinateY
{
    self.progresLabel = [[KAProgressLabel alloc] init];
    self.progresLabel.cancelButton.frame = CGRectMake(10, 10, 40, 40);
    [self.progresLabel.cancelButton setBackgroundImage:[ALUtilityClass getImageFromFramworkBundle:@"DELETEIOSX.png"] forState:UIControlStateNormal];
    [self.progresLabel setFrame:CGRectMake(cooridinateX, cooridinateY, 60, 60)];
    self.progresLabel.delegate = self;
    [self.progresLabel setTrackWidth: 4.0];
    [self.progresLabel setProgressWidth: 4];
    [self.progresLabel setStartDegree:0];
    [self.progresLabel setEndDegree:0];
    [self.progresLabel setRoundedCornersWidth:1];
    self.progresLabel.fillColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0];
    self.progresLabel.trackColor = [UIColor colorWithRed:104.0/255 green:95.0/255 blue:250.0/255 alpha:1];
    self.progresLabel.progressColor = [UIColor whiteColor];
    [self.contentView addSubview: self.progresLabel];
}

-(void)downloadRetry
{
    [super.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
}

//========================================================================================
#pragma mark - UIDocumentInteraction Delegate Methods
//========================================================================================

-(void)suggestionAction
{
    if(!fileSourceURL)
    {
        return;
    }
    
    //    NSLog(@"CALL_GESTURE_SELECTOR FILE_URL : %@",fileSourceURL);
    [self.delegate showSuggestionView:fileSourceURL andFrame:[self.imageView frame]];
}
//========================================================================================
#pragma mark - KAProgressLabel Delegate Methods
//========================================================================================

-(void)cancelAction
{
    if ([self.delegate respondsToSelector:@selector(stopDownloadForIndex:andMessage:)])
    {
        [self.delegate stopDownloadForIndex:(int)self.tag andMessage:self.mMessage];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)dealloc
{
    if(super.mMessage.fileMeta)
    {
        [super.mMessage.fileMeta removeObserver:self forKeyPath:@"progressValue" context:nil];
    }
}

-(void)setMMessage:(ALMessage *)mMessage
{
    if(super.mMessage.fileMeta)
    {
        [super.mMessage.fileMeta removeObserver:self forKeyPath:@"progressValue" context:nil];
    }
    
    super.mMessage = mMessage;
    [super.mMessage.fileMeta addObserver:self forKeyPath:@"progressValue" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    ALFileMetaInfo *metaInfo = (ALFileMetaInfo *)object;
    [self setNeedsDisplay];
    self.progresLabel.startDegree = 0;
    self.progresLabel.endDegree = metaInfo.progressValue;
}


-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    
    if(self.mMessage.groupId){
        
        ALChannelService *channelService = [[ALChannelService alloc] init];
        ALChannel *channel =  [channelService getChannelByKey:self.mMessage.groupId];
        if(channel && channel.type == OPEN){
            return NO;
        }
    }
    
    
    
    if([self.mMessage.type isEqualToString:@MT_OUTBOX_CONSTANT] && self.mMessage.groupId)
    {
        return (self.mMessage.isDownloadRequired? (action == @selector(delete:) || action == @selector(msgInfo:)):(action == @selector(delete:)|| action == @selector(msgInfo:)|| [self isMessageReplyMenuEnabled:action] ||  [self isForwardMenuEnabled:action] ));
    }
    
    return (self.mMessage.isDownloadRequired? (action == @selector(delete:)):(action == @selector(delete:)
                                                                              ||  [self isForwardMenuEnabled:action]
                                                                              || [self isMessageReplyMenuEnabled:action]));
}




-(void) delete:(id)sender
{
    //UI
    [self.delegate deleteMessageFromView:self.mMessage];
    
    //serverCall
    [ALMessageService deleteMessage:self.mMessage.key andContactId:self.mMessage.contactIds withCompletion:^(NSString *string, NSError *error) {
        
        NSLog(@"DELETE MESSAGE ERROR :: %@", error.description);
    }];
}
            
            

-(void) messageReply:(id)sender
{
    NSLog(@"Message forward option is pressed");
    [self.delegate processMessageReply:self.mMessage];
    
}-(void)openUserChatVC
{
    [self.delegate processUserChatView:self.mMessage];
}

- (void)msgInfo:(id)sender
{
    [self.delegate showAnimationForMsgInfo:YES];
    UIStoryboard *storyboardM = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALMessageInfoViewController *msgInfoVC = (ALMessageInfoViewController *)[storyboardM instantiateViewControllerWithIdentifier:@"ALMessageInfoView"];
    
     __weak typeof(ALMessageInfoViewController *) weakObj = msgInfoVC;
    
    [msgInfoVC setMessage:self.mMessage andHeaderHeight:msgFrameHeight withCompletionHandler:^(NSError *error) {
        
        if(!error)
        {
            [self.delegate loadViewForMedia:weakObj];
        }
        else
        {
            [self.delegate showAnimationForMsgInfo:NO];
        }
    }];
}
            
            
-(void) messageForward:(id)sender
{
    NSLog(@"Message forward option is pressed");
    [self.delegate processForwardMessage:self.mMessage];
        
}


-(BOOL)isForwardMenuEnabled:(SEL) action;
{
    return ([ALApplozicSettings isForwardOptionEnabled] && action == @selector(messageForward:));
}
-(BOOL)isMessageReplyMenuEnabled:(SEL) action
{
    
    
    return ([ALApplozicSettings isReplyOptionEnabled] && action == @selector(messageReply:));
}



@end
