//
//  ALVideoCell.m
//  Applozic
//
//  Created by devashish on 23/02/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALVideoCell.h"
#import "UIImageView+WebCache.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"

// Constants
#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"
#define DATE_LABEL_SIZE 12

#define BUBBLE_PADDING_X 13
#define BUBBLE_PADDING_Y 00
#define BUBBLE_PADDING_WIDTH 120
#define BUBBLE_PADDING_HEIGHT 160
#define BUBBLE_PADDING_HEIGHT_GRP 130

#define CHANNEL_PADDING_X 5
#define CHANNEL_PADDING_Y 2
#define CHANNEL_PADDING_WIDTH 30
#define CHANNEL_PADDING_HEIGHT 20

#define IMAGE_VIEW_PADDING_X 5
#define IMAGE_VIEW_PADDING_Y 5
#define IMAGE_VIEW_WIDTH 10
#define IMAGE_VIEW_HEIGHT 10
#define IMAGE_VIEW_HEIGHT_GRP 30

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

#define DOWNLOAD_RETRY_X 45
#define DOWNLOAD_RETRY_Y 20
#define DOWNLOAD_RETRY_PADDING_WIDTH 10
#define DOWNLOAD_RETRY_PADDING_HEIGHT 10

@implementation ALVideoCell
{
    CGFloat msgFrameHeight;
}
-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        self.mDowloadRetryButton.frame = CGRectMake(self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width/2.0 - 50 , self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height/2.0 - 20 , 100, 40);
        
        [self.mDowloadRetryButton addTarget:self action:@selector(downloadRetryAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoFullScreen:)];
        self.tapper.numberOfTapsRequired = 1;
        [self.contentView addSubview:self.mImageView];
        [self.mImageView setImage: [ALUtilityClass getImageFromFramworkBundle:@"VIDEO.png"]];
        
        self.videoPlayFrontView = [[UIImageView alloc] init];
        [self.videoPlayFrontView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3]];
        [self.videoPlayFrontView setContentMode:UIViewContentModeScaleAspectFit];
        [self.videoPlayFrontView setImage: [ALUtilityClass getImageFromFramworkBundle:@"playImage.png"]];
        [self.contentView addSubview:self.videoPlayFrontView];
        if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
            self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.videoPlayFrontView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mImageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
        
        UITapGestureRecognizer * menuTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(proccessTapForMenu:)];
        [self.contentView addGestureRecognizer:menuTapGesture];

    }
    
    return self;
}

-(void) addShadowEffects
{
    self.mBubleImageView.layer.shadowOpacity = 0.3;
    self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
    self.mBubleImageView.layer.shadowRadius = 1;
    self.mBubleImageView.layer.masksToBounds = NO;
}

-(instancetype) populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize
{
    
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    
    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];
    
    //    [self.mDowloadRetryButton setHidden:NO];
    self.mDowloadRetryButton.alpha = 1;
    [self.contentView bringSubviewToFront:self.mDowloadRetryButton];
    
    self.progresLabel.alpha = 0;
    [self.mNameLabel setHidden:YES];
    self.mMessage = alMessage;
    
    [self.mMessageStatusImageView setHidden:YES];
    [self.mChannelMemberName setHidden:YES];
    [self.replyParentView setHidden:YES];
    
    
    [self.imageWithText setHidden:YES];
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150 font:self.mDateLabel.font.fontName fontSize:self.mDateLabel.font.pointSize];
    
    CGSize theTextSize = [ALUtilityClass getSizeForText:alMessage.message maxWidth:viewSize.width - 130 font:self.imageWithText.font.fontName fontSize:self.imageWithText.font.pointSize];
    
    ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
    ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
    NSString *receiverName = [alContact getDisplayName];
    
    if([alMessage.type isEqualToString:@MT_INBOX_CONSTANT])
    {
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];
        
        [self.mUserProfileImageView setFrame:CGRectMake(USER_PROFILE_PADDING_X, 0,
                                                        USER_PROFILE_WIDTH, USER_PROFILE_HEIGHT)];
        
        if([ALApplozicSettings isUserProfileHidden])
        {
            [self.mUserProfileImageView setFrame:CGRectMake(USER_PROFILE_PADDING_X, 0, 0, USER_PROFILE_HEIGHT)];
        }
        
        self.mUserProfileImageView.layer.cornerRadius = self.mUserProfileImageView.frame.size.width/2;
        self.mUserProfileImageView.layer.masksToBounds = YES;
        
        
        CGFloat requiredHeight = viewSize.width - BUBBLE_PADDING_HEIGHT;
        CGFloat imageViewHeight = requiredHeight -IMAGE_VIEW_HEIGHT;
        
        CGFloat imageViewY = self.mBubleImageView.frame.origin.y + IMAGE_VIEW_PADDING_Y;
        
        //initial buble reference
        [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                  self.mUserProfileImageView.frame.origin.y,
                                                  viewSize.width - BUBBLE_PADDING_WIDTH,
                                                  requiredHeight)];
        if(alMessage.groupId)
        {
            [self.mChannelMemberName setHidden:NO];
            [self.mChannelMemberName setText:receiverName];
            [self.mChannelMemberName setTextColor: [ALColorUtility getColorForAlphabet:receiverName]];
            self.mChannelMemberName.frame = CGRectMake(self.mBubleImageView.frame.origin.x + CHANNEL_PADDING_X,
                                                       self.mBubleImageView.frame.origin.y + CHANNEL_PADDING_Y,
                                                       self.mBubleImageView.frame.size.width + CHANNEL_PADDING_WIDTH, CHANNEL_PADDING_HEIGHT);
            
            requiredHeight = requiredHeight + self.mChannelMemberName.frame.size.height;
            imageViewY = imageViewY +  self.mChannelMemberName.frame.size.height;
            
        }
        
        if(alMessage.isAReplyMessage)
        {
            [self processReplyOfChat:alMessage andViewSize:viewSize];
            
            requiredHeight = requiredHeight + self.replyParentView.frame.size.height;
            imageViewY = imageViewY +  self.replyParentView.frame.size.height;
            
        }
        
        //resize according to view
        [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                  self.mUserProfileImageView.frame.origin.y,
                                                  viewSize.width - BUBBLE_PADDING_WIDTH,
                                                  requiredHeight)];
        
        [self.mImageView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + IMAGE_VIEW_PADDING_X,
                                             imageViewY,
                                             self.mBubleImageView.frame.size.width - IMAGE_VIEW_WIDTH,
                                             imageViewHeight)];        if(alMessage.message.length > 0)
                                                 
                                                 if(alMessage.message.length > 0)
                                                 {
                                                     [self.imageWithText setHidden:NO];
                                                     self.imageWithText.textColor = [ALApplozicSettings getReceiveMsgTextColor];
                                                     self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                                                             0, viewSize.width - BUBBLE_PADDING_WIDTH,
                                                                                             (viewSize.width - BUBBLE_PADDING_HEIGHT) +
                                                                                             theTextSize.height + 20);
                                                     
                                                     self.imageWithText.frame = CGRectMake(self.mImageView.frame.origin.x,
                                                                                           self.mBubleImageView.frame.origin.y + self.mImageView.frame.size.height + 10,
                                                                                           self.mImageView.frame.size.width, theTextSize.height);
                                                 }
        
        [self.mDateLabel setFrame:CGRectMake(self.mBubleImageView.frame.origin.x,
                                             self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height,
                                             DATE_WIDTH, DATE_HEIGHT)];
        
        self.mNameLabel.frame = self.mUserProfileImageView.frame;
        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:receiverName]];
        
        if(alContact.contactImageUrl)
        {
            NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
            [self.mUserProfileImageView sd_setImageWithURL:theUrl1 placeholderImage:[ALUtilityClass getImageFromFramworkBundle:@"ic_contact_picture_holo_light.png"] options:SDWebImageRefreshCached];
        }
        else
        {
            [self.mUserProfileImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil options:SDWebImageRefreshCached];
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:receiverName];
        }
        
        [self.mDowloadRetryButton setFrame:CGRectMake(self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2.0 - DOWNLOAD_RETRY_X,
                                                      self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2.0 - DOWNLOAD_RETRY_Y,
                                                      90, 40)];
        
        [self setupProgressValueX: (self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2 - 30)
                             andY: (self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2 - 30)];
        
        if (alMessage.imageFilePath == nil)
        {
            [self.mDowloadRetryButton setHidden:NO];
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.mDowloadRetryButton setHidden:YES];
        }
        
        if (alMessage.inProgress == YES)
        {
            self.progresLabel.alpha = 1;
            [self.mDowloadRetryButton setHidden:YES];
        }
        else
        {
            self.progresLabel.alpha = 0;
        }
    
        
        
    }
    else
    {
        [self.mUserProfileImageView setFrame:CGRectMake(viewSize.width - USER_PROFILE_PADDING_X_OUTBOX, 5, 0, USER_PROFILE_WIDTH)];
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];
        
        [self.mMessageStatusImageView setHidden:NO];
        
        CGFloat requiredHeight = viewSize.width - BUBBLE_PADDING_HEIGHT;
        CGFloat imageViewHeight = requiredHeight -IMAGE_VIEW_HEIGHT;
        
        CGFloat imageViewY = self.mBubleImageView.frame.origin.y + IMAGE_VIEW_PADDING_Y;
        
        [self.mBubleImageView setFrame:CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + 60),
                                                  0, viewSize.width - BUBBLE_PADDING_WIDTH, requiredHeight)];
        
        if(alMessage.isAReplyMessage)
        {
            [self processReplyOfChat:alMessage andViewSize:viewSize ];
            
            requiredHeight = requiredHeight + self.replyParentView.frame.size.height;
            imageViewY = imageViewY +  self.replyParentView.frame.size.height;
            
        }
        
        [self.mBubleImageView setFrame:CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + 60),
                                                  0, viewSize.width - BUBBLE_PADDING_WIDTH, requiredHeight)];
        
        [self.contentView sendSubviewToBack:self.mBubleImageView];
        [self.mImageView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + IMAGE_VIEW_PADDING_X,
                                             imageViewY,
                                             self.mBubleImageView.frame.size.width - IMAGE_VIEW_WIDTH,
                                             imageViewHeight)];
        
        
        
        [self.mDowloadRetryButton setFrame:CGRectMake(self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2.0 - DOWNLOAD_RETRY_X,
                                                      self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2.0 - DOWNLOAD_RETRY_Y,
                                                      90, 40)];
        
        [self setupProgressValueX: (self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2 - 30)
                             andY: (self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2 - 30)];
        
        if(alMessage.message.length > 0)
        {
            [self.imageWithText setHidden:NO];
            self.imageWithText.backgroundColor = [UIColor clearColor];
            self.imageWithText.textColor = [ALApplozicSettings getSendMsgTextColor];
            
            self.mBubleImageView.frame = CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + 60), 0,
                                                    viewSize.width - BUBBLE_PADDING_WIDTH,
                                                    (viewSize.width - BUBBLE_PADDING_HEIGHT) + theTextSize.height + 20);
            
            self.imageWithText.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 5,
                                                  self.mBubleImageView.frame.origin.y + self.mImageView.frame.size.height + 10,
                                                  self.mImageView.frame.size.width, theTextSize.height);
            
        }
        
        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x +
                                            self.mBubleImageView.frame.size.width) - theDateSize.width - DATE_PADDING_WIDTH,
                                           self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height,
                                           theDateSize.width, DATE_HEIGHT);
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width,
                                                        self.mDateLabel.frame.origin.y,
                                                        MSG_STATUS_WIDTH, MSG_STATUS_HEIGHT);
        
        self.progresLabel.alpha = 0;
        self.mDowloadRetryButton.alpha = 0;
        
        if (alMessage.inProgress == YES)
        {
            self.progresLabel.alpha = 1;
            NSLog(@"calling you progress label....");
        }
        else if(!alMessage.imageFilePath && alMessage.fileMeta.blobKey)
        {
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];
        }
        else if (alMessage.imageFilePath && !alMessage.fileMeta.blobKey)
        {
            
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"uploadI1.png"] forState:UIControlStateNormal];
        }
      msgFrameHeight = self.mBubleImageView.frame.size.height;
    }
    
    [self.contentView bringSubviewToFront:self.videoPlayFrontView];
    [self.videoPlayFrontView setFrame:self.mImageView.frame];
    [self.videoPlayFrontView setHidden:YES];
    
    if(alMessage.imageFilePath != nil && alMessage.fileMeta.blobKey)
    {
        NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * filePath = [docDir stringByAppendingPathComponent:alMessage.imageFilePath];
        self.videoFileURL = [NSURL fileURLWithPath:filePath];
        [self.mImageView addGestureRecognizer:self.tapper];
        [self.videoPlayFrontView setHidden:NO];
        [self setVideoThumbnail:filePath];
    }
    else
    {
        [self.mImageView setImage:[ALUtilityClass getImageFromFramworkBundle:@"VIDEO.png"]];
        [self.videoPlayFrontView setHidden:YES];
        [self.mImageView removeGestureRecognizer:self.tapper];
        
    }
    
    [self.mImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.mImageView setBackgroundColor:[UIColor whiteColor]];
    
    [self addShadowEffects];
    
    self.imageWithText.text = alMessage.message;
    self.mDateLabel.text = theDate;
    
    if ([alMessage.type isEqualToString:@MT_OUTBOX_CONSTANT]) {
        
        self.mMessageStatusImageView.hidden = NO;
        NSString * imageName;
        
        switch (alMessage.status.intValue) {
            case DELIVERED_AND_READ :{
                imageName = @"ic_action_read.png";
            }break;
            case DELIVERED:{
                imageName = @"ic_action_message_delivered.png";
            }break;
            case SENT:{
                imageName = @"ic_action_message_sent.png";
            }break;
            default:{
                imageName = @"ic_action_about.png";
            }break;
        }
        self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:imageName];
    }
    
    [self.contentView bringSubviewToFront:self.replyParentView];

    return self;
}


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


-(void)setVideoThumbnail:(NSString *)videoFilePATH
{
    [self.mImageView setImage:[ALUtilityClass setVideoThumbnail:videoFilePATH]];
}

-(void) downloadRetryAction
{
    [self.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
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

-(void)videoFullScreen:(UITapGestureRecognizer *)sender
{
    MPMoviePlayerViewController * videoViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:self.videoFileURL];
    [videoViewController.moviePlayer setFullscreen:YES];
    [videoViewController.moviePlayer setScalingMode: MPMovieScalingModeAspectFit];
    
    [self.delegate showVideoFullScreen:videoViewController];
}

-(void) cancelAction
{
    if ([self.delegate respondsToSelector:@selector(stopDownloadForIndex:andMessage:)])
    {
        [self.delegate stopDownloadForIndex:(int)self.tag andMessage:self.mMessage];
    }
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
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
        return (self.mMessage.isDownloadRequired? (action == @selector(delete:) || action == @selector(msgInfo:)):(action == @selector(delete:)|| action == @selector(msgInfo:)||  [self isForwardMenuEnabled:action]  || [self isMessageReplyMenuEnabled:action] ) );
    }
    
    return (self.mMessage.isDownloadRequired? (action == @selector(delete:)):
            (action == @selector(delete:)||  [self isForwardMenuEnabled:action]  || [self isMessageReplyMenuEnabled:action]));
}


-(void) delete:(id)sender
{
    [self.delegate deleteMessageFromView:self.mMessage];
    
    //serverCall
    [ALMessageService deleteMessage:self.mMessage.key andContactId:self.mMessage.contactIds withCompletion:^(NSString *string, NSError *error) {
        
        NSLog(@"DELETE MESSAGE ERROR :: %@", error.description);
    }];
}

-(void) messageForward:(id)sender
{
    NSLog(@"Message forward option is pressed");
    [self.delegate processForwardMessage:self.mMessage];
    
}

-(void)openUserChatVC
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

-(BOOL)isForwardMenuEnabled:(SEL) action;
{
    return ([ALApplozicSettings isForwardOptionEnabled] && action == @selector(messageForward:));
}




-(void) messageReply:(id)sender
{
    NSLog(@"Message forward option is pressed");
    [self.delegate processMessageReply:self.mMessage];
    
}



-(BOOL)isMessageReplyMenuEnabled:(SEL) action
{

    return ([ALApplozicSettings isReplyOptionEnabled] && action == @selector(messageReply:));
    
}


@end
