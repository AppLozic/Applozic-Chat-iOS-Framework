//
//  ALAudioCell.m
//  Applozic
//
//  Created by devashish on 20/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALAudioCell.h"
#import "UIImageView+WebCache.h"
#import "ALMediaPlayer.h"
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"

// Constants
#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"
#define DATE_LABEL_SIZE 12


#define DOWNLOAD_RETRY_PADDING_X 45
#define DOWNLOAD_RETRY_PADDING_Y 20
#define DOWNLOAD_RETRY_WIDTH 60
#define DOWNLOAD_RETRY_HEIGHT 60

#define MAX_WIDTH 150
#define MAX_WIDTH2 130


#define IMAGE_VIEW_PADDING_X 5
#define IMAGE_VIEW_PADDING_Y 5
#define IMAGE_VIEW_PADDING_WIDTH 10
#define IMAGE_VIEW_PADDING_HEIGHT 10

#define DATE_HEIGHT 20
#define DATE_WIDTH 80
#define DATE_PADDING_X 20

#define MSG_STATUS_WIDTH 20
#define MSG_STATUS_HEIGHT 20

#define IMAGE_VIEW_WITHTEXT_PADDING_Y 10

#define BUBBLE_PADDING_X 13
#define BUBBLE_PADDING_WIDTH 50
#define BUBBLE_PADDING_HEIGHT 70


#define CHANNEL_PADDING_X 5
#define CHANNEL_PADDING_Y 2
#define CHANNEL_PADDING_WIDTH 5
#define CHANNEL_HEIGHT 20

#define BUTTON_PADDING_X 5
#define BUTTON_PADDING_Y 5
#define BUTTON_PADDING_WIDTH 60
#define BUTTON_PADDING_HEIGHT 60

#define MEDIA_NAME_HEIGHT 40

#define PROGRESS_HEIGHT 30
#define MEDIATRACKLENGTH_HEIGHT 20
#define MEDIATRACKLENGTH_WIDTH 80

@interface ALAudioCell()

@end

@implementation ALAudioCell
{
    CGFloat msgFrameHeight;
    CGFloat ORDINATE_CONSTANT;
}
-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        
        self.mediaName = [[UILabel alloc] init];
        [self.mediaName setTextColor:[UIColor blackColor]];
        [self.mediaName setBackgroundColor:[UIColor clearColor]];
        [self.mediaName setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:DATE_LABEL_SIZE]];
        [self.contentView addSubview:self.mediaName];
        [self.mediaName setNumberOfLines:2];
        [self.contentView sizeToFit];
        
        
        self.playPauseStop = [[UIButton alloc] init];
        [self.playPauseStop addTarget:self action:@selector(mediaButtonAction) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:self.playPauseStop];
        
        self.mediaTrackProgress = [[UIProgressView alloc] init];
        [self.contentView addSubview:self.mediaTrackProgress];
        
        self.mediaTrackLength = [[UILabel alloc] init];
        [self.mediaTrackLength setTextColor:[UIColor blackColor]];
        [self.mediaTrackLength setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:DATE_LABEL_SIZE]];
        [self.contentView addSubview:self.mediaTrackLength];
        
        [self.playPauseStop setImage:[ALUtilityClass getImageFromFramworkBundle:@"PLAY.png"] forState: UIControlStateNormal];
        
        [self.mDowloadRetryButton addTarget:self action:@selector(dowloadRetryAction) forControlEvents:UIControlEventTouchUpInside];
        
        if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
            self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mediaName.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.playPauseStop.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mediaTrackProgress.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mediaTrackLength.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.playPauseStop.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            
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
    
    [self.mediaName setText:alMessage.fileMeta.name];
    self.mediaTrackLength.text = [self getAudioLength:alMessage.imageFilePath];
    [self.contentView bringSubviewToFront:self.mDowloadRetryButton];
    
    self.mMessage = alMessage;
    self.progresLabel.alpha = 0;
    
    [self.playPauseStop setHidden:YES];
    [self.mNameLabel setHidden:YES];
    [self.replyParentView setHidden:YES];
    [self.mChannelMemberName setHidden:YES];
    self.mBubleImageView.backgroundColor = [UIColor whiteColor];
    
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150 font:self.mDateLabel.font.fontName fontSize:self.mDateLabel.font.pointSize];
    
    [self.mMessageStatusImageView setHidden:YES];
    
    ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
    ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
    NSString *receiverName = [alContact getDisplayName];
    [self.replyUIView removeFromSuperview];

    
    if([alMessage.type isEqualToString:@MT_INBOX_CONSTANT])
    {
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];
        
        [self.mUserProfileImageView setFrame:CGRectMake(USER_PROFILE_PADDING_X, 0, USER_PROFILE_WIDTH, USER_PROFILE_HEIGHT)];
        
        if([ALApplozicSettings isUserProfileHidden])
        {
            [self.mUserProfileImageView setFrame:CGRectMake(USER_PROFILE_PADDING_X, 0, 0, USER_PROFILE_HEIGHT)];
        }
        
        self.mUserProfileImageView.layer.cornerRadius = self.mUserProfileImageView.frame.size.width/2;
        self.mUserProfileImageView.layer.masksToBounds = YES;
        
         
        self.mNameLabel.frame = self.mUserProfileImageView.frame;
        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:alMessage.to]];
        
        if(alContact.contactImageUrl)
        {
            NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
            [self.mUserProfileImageView sd_setImageWithURL:theUrl1 placeholderImage:[ALUtilityClass getImageFromFramworkBundle:@"ic_contact_picture_holo_light.png"] options:SDWebImageRefreshCached];
        }
        else
        {
            [self.mUserProfileImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil options:SDWebImageRefreshCached];
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:alMessage.to];
        }
         CGFloat requiredHeight  = BUBBLE_PADDING_HEIGHT;
        CGFloat paypauseBUttonY = self.mBubleImageView.frame.origin.y + BUTTON_PADDING_Y ;
            
  [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                  self.mUserProfileImageView.frame.origin.y,
                                                  viewSize.width/2 + BUBBLE_PADDING_WIDTH, requiredHeight)];
        
        
        if(alMessage.groupId)
        {
         
            [self.mChannelMemberName setHidden:NO];
            [self.mChannelMemberName setTextColor: [ALColorUtility getColorForAlphabet:receiverName]];
            [self.mChannelMemberName setText:receiverName];
   
            self.mChannelMemberName.frame = CGRectMake(self.mBubleImageView.frame.origin.x + CHANNEL_PADDING_X,
                                                       self.mBubleImageView.frame.origin.y + CHANNEL_PADDING_Y,
                                                       self.mBubleImageView.frame.size.width - CHANNEL_PADDING_WIDTH, CHANNEL_HEIGHT);
            
            requiredHeight =  requiredHeight + self.mChannelMemberName.frame.size.height;
            paypauseBUttonY = paypauseBUttonY + self.mChannelMemberName.frame.size.height;
            
        }    
        if(alMessage.isAReplyMessage)
        {
            [self processReplyOfChat:alMessage andViewSize:viewSize];
            
            requiredHeight =  requiredHeight + self.replyParentView.frame.size.height;
            paypauseBUttonY = paypauseBUttonY + self.replyParentView.frame.size.height;
            
        }
                    
            [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                      self.mUserProfileImageView.frame.origin.y,
                                                      viewSize.width/2 + BUBBLE_PADDING_WIDTH, requiredHeight)];
             [self.playPauseStop setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + BUTTON_PADDING_X,
                                                paypauseBUttonY,
                                                BUTTON_PADDING_WIDTH, BUTTON_PADDING_HEIGHT)];
        
        
        CGFloat nameWidth = self.mBubleImageView.frame.size.width - self.playPauseStop.frame.size.width - 20;
        CGFloat nameX = self.playPauseStop.frame.origin.x + self.playPauseStop.frame.size.width + 10;
        [self.mediaName setFrame:CGRectMake(nameX, self.playPauseStop.frame.origin.y, nameWidth, MEDIA_NAME_HEIGHT)];
        
        [self.mDowloadRetryButton setFrame:CGRectMake(self.playPauseStop.frame.origin.x ,
                                                      self.playPauseStop.frame.origin.y,
                                                      DOWNLOAD_RETRY_WIDTH, DOWNLOAD_RETRY_HEIGHT)];
        
        [self setupProgressValueX: (self.playPauseStop.frame.origin.x) andY: (self.playPauseStop.frame.origin.y)];
        
        CGFloat progressBarWidth = self.mBubleImageView.frame.size.width - self.playPauseStop.frame.size.width - 30;
        
        CGFloat progressX = self.playPauseStop.frame.origin.x + self.playPauseStop.frame.size.width + 10;
        [self.mediaTrackProgress setFrame:CGRectMake(progressX, self.mediaName.frame.origin.y + self.mediaName.frame.size.height,
                                                     progressBarWidth, PROGRESS_HEIGHT)];
        
        [self.mediaTrackLength setFrame:CGRectMake(self.mediaTrackProgress.frame.origin.x,
                                                   self.mediaTrackProgress.frame.origin.y + self.mediaTrackProgress.frame.size.height,
                                                   MEDIATRACKLENGTH_WIDTH, MEDIATRACKLENGTH_HEIGHT)];
        
        [self.mDateLabel setFrame:CGRectMake(self.mBubleImageView.frame.origin.x,
                                             self.mBubleImageView.frame.size.height + self.mBubleImageView.frame.origin.y,
                                             DATE_WIDTH, DATE_HEIGHT)];
        
        if (alMessage.imageFilePath == nil)
        {
            [self.mDowloadRetryButton setHidden:NO];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"DownloadiOS.png"] forState:UIControlStateNormal];
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
    
    
    }else
    {

        [self.mUserProfileImageView setFrame:CGRectMake(viewSize.width - USER_PROFILE_PADDING_X_OUTBOX, 0, 0, USER_PROFILE_HEIGHT)];
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];
        
        [self.mBubleImageView setFrame:CGRectMake(viewSize.width - (viewSize.width/2 + 50) - 10,
                                                  self.mUserProfileImageView.frame.origin.y,
                                                  viewSize.width/2 + BUBBLE_PADDING_WIDTH, BUBBLE_PADDING_HEIGHT)];
        
        [self.mMessageStatusImageView setHidden:NO];
        
  
        if(alMessage.isAReplyMessage)
        {
            [self processReplyOfChat:alMessage andViewSize:viewSize ];
            
            [self.mBubleImageView setFrame:CGRectMake(viewSize.width - (viewSize.width/2 + 50) - 10,
                                                      self.mUserProfileImageView.frame.origin.y,
                                                      viewSize.width/2 + BUBBLE_PADDING_WIDTH, BUBBLE_PADDING_HEIGHT+ self.replyParentView.frame.size.height)];
            [self.playPauseStop setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + BUTTON_PADDING_X,
                                                    self.mBubleImageView.frame.origin.y + BUTTON_PADDING_Y + self.replyParentView.frame.size.height,
                                                    BUTTON_PADDING_WIDTH, BUTTON_PADDING_HEIGHT)];
            
        }
        else
        {
            
            [self.playPauseStop setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + BUTTON_PADDING_X,
                                                    self.mBubleImageView.frame.origin.y + BUTTON_PADDING_Y,
                                                    BUTTON_PADDING_WIDTH, BUTTON_PADDING_HEIGHT)];
            
        }
                [self.mDowloadRetryButton setFrame:CGRectMake(self.playPauseStop.frame.origin.x ,
                                                      self.playPauseStop.frame.origin.y,
                                                      DOWNLOAD_RETRY_WIDTH, DOWNLOAD_RETRY_WIDTH)];
        
        [self setupProgressValueX: (self.playPauseStop.frame.origin.x) andY: (self.playPauseStop.frame.origin.y)];
        
        msgFrameHeight = self.mBubleImageView.frame.size.height;
        
        CGFloat progressBarWidth = self.mBubleImageView.frame.size.width - self.playPauseStop.frame.size.width - 30;
        
        CGFloat progressX = self.playPauseStop.frame.origin.x + self.playPauseStop.frame.size.width + 10;
        
        CGFloat nameWidth = self.mBubleImageView.frame.size.width - self.playPauseStop.frame.size.width - 20;
        CGFloat nameX = self.playPauseStop.frame.origin.x + self.playPauseStop.frame.size.width + 10;
        
        [self.mediaName setFrame:CGRectMake(nameX, self.playPauseStop.frame.origin.y, nameWidth, MEDIA_NAME_HEIGHT)];
        
        [self.mediaTrackProgress setFrame:CGRectMake(progressX,
                                                     self.mediaName.frame.origin.y + self.mediaName.frame.size.height
                                                     ,progressBarWidth, PROGRESS_HEIGHT)];
        
        [self.mediaTrackLength setFrame:CGRectMake(self.mediaTrackProgress.frame.origin.x,
                                                   self.mediaTrackProgress.frame.origin.y + self.mediaTrackProgress.frame.size.height,
                                                   MEDIATRACKLENGTH_WIDTH, MEDIATRACKLENGTH_HEIGHT)];
        
        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width) -
                                           theDateSize.width - DATE_PADDING_X,
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
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"DownloadiOS.png"] forState:UIControlStateNormal];
        }
        
        else if (alMessage.imageFilePath && !alMessage.fileMeta.blobKey)
        {
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"UploadiOS2.png"] forState:UIControlStateNormal];
        }
        
    }
    
    if(alMessage.imageFilePath != nil && alMessage.fileMeta.blobKey)
    {
        NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * filePath = [docDir stringByAppendingPathComponent:alMessage.imageFilePath];
        NSURL * soundFileURL = [NSURL fileURLWithPath:filePath];
        NSLog(@"SOUND_URL :: %@",[soundFileURL path]);
        [self.playPauseStop setHidden:NO];
    }

    [self.mediaName sizeToFit];
    
    self.playPauseStop.layer.cornerRadius = self.playPauseStop.frame.size.width/2;
    self.playPauseStop.layer.masksToBounds = YES;
    
    self.mDowloadRetryButton.layer.cornerRadius = self.mDowloadRetryButton.frame.size.width/2;
    self.mDowloadRetryButton.layer.masksToBounds = YES;
    
    [self addShadowEffects];
    
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
    
    
    
    [self.contentView bringSubviewToFront:self.replyUIView];
    
    
    
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
//
        [[UIMenuController sharedMenuController] setMenuItems: @[messageReply]];
    }
    [[UIMenuController sharedMenuController] update];
    
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
        
    if([self.mMessage.type isEqualToString:@MT_OUTBOX_CONSTANT] && self.mMessage.groupId){
        
        return (self.mMessage.isDownloadRequired? (action == @selector(delete:) || action == @selector(msgInfo:)):(action == @selector(delete:)|| action == @selector(msgInfo:)|| [self isForwardMenuEnabled:action] || [self isMessageReplyMenuEnabled:action] ));
    }
    return (self.mMessage.isDownloadRequired? (action == @selector(delete:)):(action == @selector(delete:)||[self isForwardMenuEnabled:action] || [self isMessageReplyMenuEnabled:action]));
}


-(void) delete:(id)sender
{
    [self.delegate deleteMessageFromView:self.mMessage];
    [ALMessageService deleteMessage:self.mMessage.key andContactId:self.mMessage.contactIds withCompletion:^(NSString *string, NSError *error) {
        
        NSLog(@"DELETE MESSAGE ERROR :: %@", error.description);
    }];
}


-(void) messageForward:(id)sender
{
    NSLog(@"Message forward option is pressed");
    [self.delegate processForwardMessage:self.mMessage];
    
}


-(void) cancelAction
{
    if ([self.delegate respondsToSelector:@selector(stopDownloadForIndex:andMessage:)])
    {
        [self.delegate stopDownloadForIndex:(int)self.tag andMessage:self.mMessage];
    }
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void) dowloadRetryAction
{
    [self.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
}

-(void) dealloc
{
    if(self.mMessage.fileMeta)
    {
        //  [self.mMessage.fileMeta removeObserver:self forKeyPath:@"progressValue" context:nil];
    }
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


-(void) mediaButtonAction
{
    ALMediaPlayer * mediaPlayer =  [ALMediaPlayer sharedInstance];
    
    if( [mediaPlayer isPlayingCurrentKey:self.mMessage.key ] )
    {
        if(!mediaPlayer.audioPlayer.isPlaying)
        {
            [mediaPlayer resumeAudio];
            [self.playPauseStop setImage:[ALUtilityClass getImageFromFramworkBundle:@"PAUSE.png"] forState: UIControlStateNormal];
        }
        else
        {
            [self.playPauseStop setImage:[ALUtilityClass getImageFromFramworkBundle:@"PLAY.png"] forState: UIControlStateNormal];
            [mediaPlayer pauseAudio];
        }
    }else{

        if(mediaPlayer.audioPlayer.isPlaying) {
            [mediaPlayer stopPlaying];
        }
        mediaPlayer.delegate = self;
        mediaPlayer.key = self.mMessage.key;
        [mediaPlayer playAudio:self.mMessage.imageFilePath];
        [self.playPauseStop setImage:[ALUtilityClass getImageFromFramworkBundle:@"PAUSE.png"] forState: UIControlStateNormal];

    }
}

-(NSString*) getAudioLength:(NSString*)path
{

    NSString * duration = [ALMediaPlayer getTotalDuration:path];

    NSString *audioLength = [NSString stringWithFormat:@"0:00 / %@", duration];

    return audioLength;
}

-(void) getProgressOfTrack
{
    ALMediaPlayer * mediaPlayer =  [ALMediaPlayer sharedInstance];

    NSInteger durationMinutes = [mediaPlayer.audioPlayer duration] / 60;
    NSInteger durationSeconds = [mediaPlayer.audioPlayer duration] - durationMinutes * 60;
    
    NSInteger currentTimeMinutes = [mediaPlayer.audioPlayer currentTime] / 60;
    NSInteger currentTimeSeconds = [mediaPlayer.audioPlayer currentTime] - currentTimeMinutes * 60;
    
    NSString *progressString = [NSString stringWithFormat:@"%ld:%02ld / %ld:%02ld", (long)currentTimeMinutes, (long)currentTimeSeconds, (long)durationMinutes, (long)durationSeconds];
    
    [self.mediaTrackProgress setProgress: [mediaPlayer.audioPlayer currentTime] / [mediaPlayer.audioPlayer duration]];
    [self.mediaTrackLength setText: progressString];
    
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.playPauseStop setImage:[ALUtilityClass getImageFromFramworkBundle:@"PLAY.png"] forState: UIControlStateNormal];
    self.mediaTrackLength.text = [self getAudioLength:self.mMessage.imageFilePath];
    [self.mediaTrackProgress setProgress: 0.0];
    ALMediaPlayer * mediaPlayer =  [ALMediaPlayer sharedInstance];
    [mediaPlayer.audioPlayer stop];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    ALFileMetaInfo *metaInfo = (ALFileMetaInfo *)object;
    [self setNeedsDisplay];
    self.progresLabel.startDegree = 0;
    self.progresLabel.endDegree = metaInfo.progressValue;
     NSLog(@"##observer is called....%f",self.progresLabel.endDegree);
}

-(void) hidePlayButtonOnUploading
{
    [self.playPauseStop setHidden:YES];
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
