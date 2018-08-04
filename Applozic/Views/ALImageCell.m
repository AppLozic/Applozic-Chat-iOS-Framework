//
//  ALImageCell.m
//  ChatApp
//
//  Created by shaik riyaz on 22/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#define DATE_LABEL_SIZE 12

#import "ALImageCell.h"
#import "UIImageView+WebCache.h"
#import "ALDBHandler.h"
#import "ALContact.h"
#import "ALContactDBService.h"
#import "ALApplozicSettings.h"
#import "ALMessageService.h"
#import "ALMessageDBService.h"
#import "ALUtilityClass.h"
#import "ALColorUtility.h"
#import "ALMessage.h"
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"
#import "ALDataNetworkConnection.h"
#import "UIImage+MultiFormat.h"
#import "ALShowImageViewController.h"

// Constants
#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"

#define DOWNLOAD_RETRY_PADDING_X 45
#define DOWNLOAD_RETRY_PADDING_Y 20

#define MAX_WIDTH 150
#define MAX_WIDTH_DATE 130

#define IMAGE_VIEW_PADDING_X 5
#define IMAGE_VIEW_PADDING_Y 5
#define IMAGE_VIEW_PADDING_WIDTH 10
#define IMAGE_VIEW_PADDING_HEIGHT 10
#define IMAGE_VIEW_PADDING_HEIGHT_GRP 15

#define DATE_HEIGHT 20
#define DATE_PADDING_X 20

#define MSG_STATUS_WIDTH 20
#define MSG_STATUS_HEIGHT 20

#define IMAGE_VIEW_WITHTEXT_PADDING_Y 10

#define BUBBLE_PADDING_X 13
#define BUBBLE_PADDING_Y 120
#define BUBBLE_PADDING_WIDTH 120
#define BUBBLE_PADDING_HEIGHT 120
#define BUBBLE_PADDING_HEIGHT_GRP 100
#define BUBBLE_PADDING_X_OUTBOX 60
#define BUBBLE_PADDING_HEIGHT_TEXT 20

#define CHANNEL_PADDING_X 5
#define CHANNEL_PADDING_Y 5
#define CHANNEL_PADDING_WIDTH 30
#define CHANNEL_PADDING_HEIGHT 20
#define CHANNEL_PADDING_GRP 3

@implementation ALImageCell
{
    CGFloat msgFrameHeight;
    NSURL * theUrl;
}

UIViewController * modalCon;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if(self)
    {

        self.mDowloadRetryButton.frame = CGRectMake(self.mBubleImageView.frame.origin.x
                                                    + self.mBubleImageView.frame.size.width/2.0 - 50,
                                                    self.mBubleImageView.frame.origin.y +
                                                    self.mBubleImageView.frame.size.height/2.0 - 50 ,
                                                    100, 40);

        UITapGestureRecognizer * tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageFullScreen:)];
        tapper.numberOfTapsRequired = 1;
        [self.mImageView addGestureRecognizer:tapper];
        [self.contentView addSubview:self.mImageView];

        [self.mDowloadRetryButton addTarget:self action:@selector(dowloadRetryButtonAction) forControlEvents:UIControlEventTouchUpInside];
        if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
            self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mImageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }

        UITapGestureRecognizer * menuTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(proccessTapForMenu:)];
        [self.contentView addGestureRecognizer:menuTapGesture];

    }

    return self;
}

-(instancetype)populateCell:(ALMessage *)alMessage viewSize:(CGSize)viewSize
{
    [super populateCell:alMessage viewSize:viewSize];

    self.mUserProfileImageView.alpha = 1;
    self.progresLabel.alpha = 0;
    [self.replyParentView setHidden:YES];

    [self.mDowloadRetryButton setHidden:NO];
    [self.contentView bringSubviewToFront:self.mDowloadRetryButton];

    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];

    ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
    ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];

    NSString *receiverName = [alContact getDisplayName];

    self.mMessage = alMessage;

    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:MAX_WIDTH
                                                   font:self.mDateLabel.font.fontName
                                               fontSize:self.mDateLabel.font.pointSize];

    CGSize theTextSize = [ALUtilityClass getSizeForText:alMessage.message
                                               maxWidth:viewSize.width - MAX_WIDTH_DATE
                                                   font:self.imageWithText.font.fontName
                                               fontSize:self.imageWithText.font.pointSize];
<<<<<<< HEAD
    self.mChannelMemberName.font = [UIFont fontWithName:[ALApplozicSettings getFontFace] size:14];// [UIFont fontWithName:@"Helvetica-Bold" size:15];
=======
>>>>>>> upstream/master

    [self.mChannelMemberName setHidden:YES];
    [self.mNameLabel setHidden:YES];
    [self.imageWithText setHidden:YES];
    [self.mMessageStatusImageView setHidden:YES];
<<<<<<< HEAD
    
=======

    UITapGestureRecognizer *tapForOpenChat = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processOpenChat)];
    tapForOpenChat.numberOfTapsRequired = 1;
    [self.mUserProfileImageView setUserInteractionEnabled:YES];
    [self.mUserProfileImageView addGestureRecognizer:tapForOpenChat];

>>>>>>> upstream/master
    if ([alMessage.type isEqualToString:@MT_INBOX_CONSTANT]) { //@"4" //Recieved Message

        [self.contentView bringSubviewToFront:self.mChannelMemberName];

        if([ALApplozicSettings isUserProfileHidden])
        {
            self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_PADDING_X, 0, 0,
                                                          45);
        }
        else
        {
            self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_PADDING_X, 0,
                                                          45,45);
        }

        self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];

        self.mNameLabel.frame = self.mUserProfileImageView.frame;

        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:receiverName]];

        //Shift for message reply and channel name..

        CGFloat requiredHeight = viewSize.width - BUBBLE_PADDING_HEIGHT;
        CGFloat imageViewHeight = requiredHeight -IMAGE_VIEW_PADDING_HEIGHT;

        CGFloat imageViewY = self.mBubleImageView.frame.origin.y + IMAGE_VIEW_PADDING_Y;

        self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                0, viewSize.width - BUBBLE_PADDING_WIDTH, requiredHeight);

        self.mBubleImageView.layer.shadowOpacity = 0.3;
        self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
        self.mBubleImageView.layer.shadowRadius = 1;
        self.mBubleImageView.layer.masksToBounds = NO;


        if(alMessage.getGroupId)
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
        self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                0, viewSize.width - BUBBLE_PADDING_WIDTH, requiredHeight);
        self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + IMAGE_VIEW_PADDING_X,
                                           imageViewY,
                                           self.mBubleImageView.frame.size.width - IMAGE_VIEW_PADDING_WIDTH ,
                                           imageViewHeight);


        [self setupProgress];

        self.mDateLabel.textAlignment = NSTextAlignmentLeft;

        if(alMessage.message.length > 0)
        {
            self.imageWithText.textColor = [ALApplozicSettings getReceiveMsgTextColor];

            self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                    0, viewSize.width - BUBBLE_PADDING_Y,
                                                    (viewSize.width - BUBBLE_PADDING_HEIGHT)
                                                    + theTextSize.height + BUBBLE_PADDING_HEIGHT_TEXT);

            self.imageWithText.frame = CGRectMake(self.mImageView.frame.origin.x,
                                                  self.mImageView.frame.origin.y + self.mImageView.frame.size.height + 5,
                                                  self.mImageView.frame.size.width, theTextSize.height);

            [self.imageWithText setHidden:NO];

            [self.contentView bringSubviewToFront:self.mDateLabel];
            [self.contentView bringSubviewToFront:self.mMessageStatusImageView];
        }
        else
        {
            self.mDowloadRetryButton.alpha = 1;
            [self.imageWithText setHidden:YES];
        }

        self.mDateLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x,
                                           self.mBubleImageView.frame.origin.y +
                                           self.mBubleImageView.frame.size.height,
                                           theDateSize.width,
                                           DATE_HEIGHT);

        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width,
                                                        self.mDateLabel.frame.origin.y,
                                                        MSG_STATUS_WIDTH, MSG_STATUS_HEIGHT);

        if (alMessage.imageFilePath == NULL)
        {
            NSLog(@" file path not found making download button visible ....ALImageCell");
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];

        }
        else
        {
            self.mDowloadRetryButton.alpha = 0;
        }
        if (alMessage.inProgress == YES)
        {
            NSLog(@" In progress making download button invisible ....");
            self.progresLabel.alpha = 1;
            self.mDowloadRetryButton.alpha = 0;
        }
        else
        {
            self.progresLabel.alpha = 0;
        }

        if(alContact.contactImageUrl)
        {
            NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
            [self.mUserProfileImageView sd_setImageWithURL:theUrl1 placeholderImage: [ALUtilityClass getImageFromFramworkBundle:@"ic_contact_picture_holo_light.png"] options:SDWebImageRefreshCached];
        }
        else
        {
            [self.mUserProfileImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil options:SDWebImageRefreshCached];
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:receiverName];
        }


    }
    else
    { //Sent Message

        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];

        self.mUserProfileImageView.frame = CGRectMake(viewSize.width - USER_PROFILE_PADDING_X_OUTBOX,
                                                      0, 0, USER_PROFILE_HEIGHT);

        self.mBubleImageView.frame = CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + BUBBLE_PADDING_X_OUTBOX),
                                                0, viewSize.width - BUBBLE_PADDING_WIDTH, viewSize.width - BUBBLE_PADDING_HEIGHT);

        self.mBubleImageView.layer.shadowOpacity = 0.3;
        self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
        self.mBubleImageView.layer.shadowRadius = 1;
        self.mBubleImageView.layer.masksToBounds = NO;

        CGFloat requiredHeight = viewSize.width - BUBBLE_PADDING_HEIGHT;
        CGFloat imageViewHeight = requiredHeight -IMAGE_VIEW_PADDING_HEIGHT;

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



        self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + IMAGE_VIEW_PADDING_X,
                                           imageViewY,
                                           self.mBubleImageView.frame.size.width - IMAGE_VIEW_PADDING_WIDTH,
                                           imageViewHeight);

        [self.mMessageStatusImageView setHidden:NO];

        if(alMessage.message.length > 0)
        {
            [self.imageWithText setHidden:NO];
            self.imageWithText.backgroundColor = [UIColor clearColor];
            self.imageWithText.textColor = [ALApplozicSettings getSendMsgTextColor];;
            self.mBubleImageView.frame = CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + BUBBLE_PADDING_X_OUTBOX),
                                                    0, viewSize.width - BUBBLE_PADDING_WIDTH,
                                                    viewSize.width - BUBBLE_PADDING_HEIGHT
                                                    + theTextSize.height + BUBBLE_PADDING_HEIGHT_TEXT);

            self.imageWithText.frame = CGRectMake(self.mBubleImageView.frame.origin.x + IMAGE_VIEW_PADDING_X,
                                                  self.mImageView.frame.origin.y + self.mImageView.frame.size.height + IMAGE_VIEW_WITHTEXT_PADDING_Y,
                                                  self.mImageView.frame.size.width, theTextSize.height);

            [self.contentView bringSubviewToFront:self.mDateLabel];
            [self.contentView bringSubviewToFront:self.mMessageStatusImageView];

        }
        else
        {
            [self.imageWithText setHidden:YES];
        }

        msgFrameHeight = self.mBubleImageView.frame.size.height;

        self.mDateLabel.textAlignment = NSTextAlignmentLeft;

        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x +
                                            self.mBubleImageView.frame.size.width) - theDateSize.width - DATE_PADDING_X,
                                           self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height,
                                           theDateSize.width, DATE_HEIGHT);

        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width,
                                                        self.mDateLabel.frame.origin.y,
                                                        MSG_STATUS_WIDTH, MSG_STATUS_HEIGHT);

        [self setupProgress];

        self.progresLabel.alpha = 0;
        self.mDowloadRetryButton.alpha = 0;

        if (alMessage.inProgress == YES)
        {
            self.progresLabel.alpha = 1;
            NSLog(@"calling you progress label....");
        }
        else if( !alMessage.imageFilePath && alMessage.fileMeta.blobKey)
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

    }

    self.mDowloadRetryButton.frame = CGRectMake(self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2.0 - DOWNLOAD_RETRY_PADDING_X,
                                                self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2.0 - DOWNLOAD_RETRY_PADDING_Y,
                                                90, 40);

    if ([alMessage.type isEqualToString:@MT_OUTBOX_CONSTANT])
    {

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

    self.imageWithText.text = alMessage.message;
    self.mDateLabel.text = theDate;

    theUrl = nil;

    if (alMessage.imageFilePath != NULL)
    {
        NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * filePath = [docDir stringByAppendingPathComponent:alMessage.imageFilePath];
        theUrl = [NSURL fileURLWithPath:filePath];
    }
    else
    {
<<<<<<< HEAD
        theUrl = [NSURL URLWithString:alMessage.fileMeta.thumbnailUrl];
    }
    
    [self.mImageView sd_setImageWithURL:theUrl];
    
=======
        if(alMessage.fileMeta.thumbnailFilePath == nil){
            ALMessageClientService * messageClientService = [[ALMessageClientService alloc]init];
            [messageClientService downloadImageThumbnailUrl:alMessage withCompletion:^(NSString *fileURL, NSError *error) {

                NSLog(@"ATTACHMENT DOWNLOAD URL : %@", fileURL);
                if(error == nil){
                    [self.delegate thumbnailDownload:alMessage.key withThumbnailUrl:fileURL];
                }

            }];
        }else{

            NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString * filePath = [docDir stringByAppendingPathComponent:alMessage.fileMeta.thumbnailFilePath];
            [self setInImageView:[NSURL fileURLWithPath:filePath]];
        }

    }

>>>>>>> upstream/master
    return self;

}

<<<<<<< HEAD
=======
-(void) setInImageView:(NSURL*)url{
   [self.mImageView sd_setImageWithPreviousCachedImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}
>>>>>>> upstream/master

#pragma mark - Menu option tap Method -

-(void) proccessTapForMenu:(id)tap{
<<<<<<< HEAD
    
//    UIMenuItem * messageForward = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"forwardOptionTitle", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Forward", @"") action:@selector(messageForward:)];
=======

    [self processKeyBoardHideTap];

    UIMenuItem * messageForward = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"forwardOptionTitle", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Forward", @"") action:@selector(messageForward:)];
>>>>>>> upstream/master
    UIMenuItem * messageReply = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"replyOptionTitle", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Reply", @"") action:@selector(messageReply:)];

    if ([self.mMessage.type isEqualToString:@MT_INBOX_CONSTANT]){
<<<<<<< HEAD
        
        [[UIMenuController sharedMenuController] setMenuItems: @[messageReply]];
        
    }else if ([self.mMessage.type isEqualToString:@MT_OUTBOX_CONSTANT]){

        
//        UIMenuItem * msgInfo = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"infoOptionTitle", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Info", @"") action:@selector(msgInfo:)];
        
        [[UIMenuController sharedMenuController] setMenuItems: @[messageReply]];
=======

        [[UIMenuController sharedMenuController] setMenuItems: @[messageForward,messageReply]];

    }else if ([self.mMessage.type isEqualToString:@MT_OUTBOX_CONSTANT]){


        UIMenuItem * msgInfo = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"infoOptionTitle", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Info", @"") action:@selector(msgInfo:)];

        [[UIMenuController sharedMenuController] setMenuItems: @[msgInfo,messageReply,messageForward]];
>>>>>>> upstream/master
    }
    [[UIMenuController sharedMenuController] update];

}



#pragma mark - KAProgressLabel Delegate Methods -

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

-(void) dowloadRetryButtonAction
{
    [super.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
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
    //TODO: error ...observer shoud be there...
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
    // NSLog(@"##observer is called....%f",self.progresLabel.endDegree );
}

-(void)imageFullScreen:(UITapGestureRecognizer*)sender
{
    UIStoryboard * applozicStoryboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];

    ALShowImageViewController * alShowImageViewController = [applozicStoryboard instantiateViewControllerWithIdentifier:@"showImageViewController"];
    alShowImageViewController.view.backgroundColor = [UIColor whiteColor];
    alShowImageViewController.view.userInteractionEnabled = YES;

    [alShowImageViewController setImage:self.mImageView.image];
    [alShowImageViewController setAlMessage:self.mMessage];
<<<<<<< HEAD
    
    //[self.delegate showFullScreen:alShowImageViewController];
    
    [self.delegate loadViewForMedia:alShowImageViewController];
=======

    [self.delegate showFullScreen:alShowImageViewController];

>>>>>>> upstream/master
    return;
}

-(void)setupProgress
{
    self.progresLabel = [[KAProgressLabel alloc] initWithFrame:CGRectMake(self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2.0 - 25, self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2.0 - 25, 50, 50)];
    self.progresLabel.delegate = self;
    [self.progresLabel setTrackWidth: 4.0];
    [self.progresLabel setProgressWidth: 4];
    [self.progresLabel setStartDegree:0];
    [self.progresLabel setEndDegree:0];
    [self.progresLabel setRoundedCornersWidth:1];
    self.progresLabel.fillColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.3];
    self.progresLabel.trackColor = [UIColor colorWithRed:104.0/255 green:95.0/255 blue:250.0/255 alpha:1];
    self.progresLabel.progressColor = [UIColor whiteColor];
    [self.contentView addSubview:self.progresLabel];

}

-(void)dismissModalView:(UITapGestureRecognizer*)gesture
{
    [modalCon dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    NSLog(@"Action: %@", NSStringFromSelector(action));

    if(self.mMessage.groupId){
        ALChannelService *channelService = [[ALChannelService alloc] init];
        ALChannel *channel =  [channelService getChannelByKey:self.mMessage.groupId];
        if(channel && channel.type == OPEN){
            return NO;
        }
    }

    if([self.mMessage.type isEqualToString:@MT_OUTBOX_CONSTANT] && self.mMessage.groupId)
    {
        return (self.mMessage.isDownloadRequired? (action == @selector(delete:) || action == @selector(msgInfo:)):(action == @selector(delete:)|| action == @selector(msgInfo:)|| action == @selector(messageForward:) || [self isMessageReplyMenuEnabled:action]));
    }

    return (self.mMessage.isDownloadRequired? (action == @selector(delete:)):(action == @selector(delete:)|| [self isForwardMenuEnabled:action]|| [self isMessageReplyMenuEnabled:action]));
}


-(void) delete:(id)sender
{
    //UI
    NSLog(@"message to deleteUI %@",self.mMessage.message);
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


-(void) messageReply:(id)sender
{
    NSLog(@"Message forward option is pressed");
    [self.delegate processMessageReply:self.mMessage];

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

    msgInfoVC.contentURL = theUrl;

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

-(BOOL)isMessageReplyMenuEnabled:(SEL) action
{

    return ([ALApplozicSettings isReplyOptionEnabled] && action == @selector(messageReply:));

}

@end
