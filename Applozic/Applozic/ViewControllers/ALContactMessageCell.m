//
//  ALContactMessageCell.m
//  Applozic
//
//  Created by devashish on 12/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

// Constants
#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"

#define DATE_LABEL_SIZE 12

#import "ALContactMessageCell.h"
#import "ALUtilityClass.h"
#import "UIImageView+WebCache.h"
#import "ALApplozicSettings.h"
#import "ALConstant.h"
#import "ALContact.h"
#import "ALColorUtility.h"
#import "ALContactDBService.h"
#import "ALMessageService.h"
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"
#import "ALVCFClass.h"
#import "ALVCardClass.h"

#define BUBBLE_PADDING_X 13
#define BUBBLE_PADDING_X_OUTBOX 60
#define BUBBLE_PADDING_WIDTH 120
#define BUBBLE_PADDING_HEIGHT 160
#define BUBBLE_PADDING_HEIGHT_OUTBOX 180

#define DATE_PADDING_X 20
#define DATE_PADDING_WIDTH 20
#define DATE_HEIGHT 20
#define DATE_WIDTH 80

#define MSG_STATUS_WIDTH 20
#define MSG_STATUS_HEIGHT 20

#define CNT_PROFILE_X 10
#define CNT_PROFILE_Y 10
#define CNT_PROFILE_HEIGHT 50
#define CNT_PROFILE_WIDTH 50

#define CNT_PERSON_X 10
#define CNT_PERSON_HEIGHT 20

#define USER_CNT_Y 5
#define USER_CNT_HEIGHT 50

#define EMAIL_Y 5
#define EMAIL_HEIGHT 50

#define BUTTON_Y 50
#define BUTTON_WIDTH 20
#define BUTTON_HEIGHT 40

#define CHANNEL_PADDING_X 5
#define CHANNEL_PADDING_Y 2
#define CHANNEL_PADDING_WIDTH 5
#define CHANNEL_HEIGHT 20
#define CHANNEL_PADDING_HEIGHT 20



@interface ALContactMessageCell ()

@end

@implementation ALContactMessageCell
{
    NSURL *theUrl;
    CGFloat msgFrameHeight;
    ALVCFClass *vcfClass;
    ALVCardClass *vCardClass;
}
-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if(self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
//        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0  blue:242/255.0 alpha:1];
        self.contentView.userInteractionEnabled = YES;

        self.contactProfileImage = [[UIImageView alloc] init];
        [self.contactProfileImage setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.contactProfileImage];

        self.userContact = [[UILabel alloc] init];
        [self.userContact setBackgroundColor:[UIColor clearColor]];
        [self.userContact setTextColor:[UIColor blackColor]];
        [self.userContact setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
        [self.userContact setNumberOfLines:2];
        [self.contentView addSubview:self.userContact];

        self.emailId = [[UILabel alloc] init];
        [self.emailId setBackgroundColor:[UIColor clearColor]];
        [self.emailId setTextColor:[UIColor blackColor]];
        [self.emailId setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
        [self.emailId setNumberOfLines:2];
        [self.contentView addSubview:self.emailId];

        self.contactPerson = [[UILabel alloc] init];
        [self.contactPerson setBackgroundColor:[UIColor clearColor]];
        [self.contactPerson setTextColor:[UIColor blackColor]];
        [self.contactPerson setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
        [self.contentView addSubview:self.contactPerson];

        self.addContactButton = [[UIButton alloc] init];
     [self.addContactButton setTitle: NSLocalizedStringWithDefaultValue(@"addContactButtonText", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"ADD CONTACT", @"") forState:UIControlStateNormal];
        [self.addContactButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.addContactButton.titleLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
        [self.addContactButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.addContactButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.contentView addSubview:self.addContactButton];
        if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
            self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.userContact.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.emailId.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.addContactButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.contactPerson.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }

        UITapGestureRecognizer * menuTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(proccessTapForMenu:)];
        [self.contentView addGestureRecognizer:menuTapGesture];

    }
    return self;
}

-(instancetype)populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize
{
    self.mUserProfileImageView.alpha = 1;
    self.progresLabel.alpha = 0;
    self.mDowloadRetryButton.alpha = 0;

    [self.addContactButton setEnabled:NO];

    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];

    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];

    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150 font:self.mDateLabel.font.fontName fontSize:self.mDateLabel.font.pointSize];

    self.mMessage = alMessage;

    [self.mChannelMemberName setHidden:YES];
    [self.mNameLabel setHidden:YES];
    [self.mMessageStatusImageView setHidden:YES];
    [self.replyParentView setHidden:YES];

    [self.contactProfileImage setImage:[ALUtilityClass getImageFromFramworkBundle:@"ic_contact_picture_holo_light.png"]];
    [self.userContact setText:@"PHONE NO"];
    [self.emailId setText:@"EMAIL ID"];
    [self.contactPerson setText:@"CONTACT NAME"];
     [self.replyUIView removeFromSuperview];
    if ([alMessage.type isEqualToString:@MT_INBOX_CONSTANT])
    {
        if([ALApplozicSettings isUserProfileHidden])
        {
            self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_PADDING_X, 0, 0, USER_PROFILE_HEIGHT);
        }
        else
        {
            self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_PADDING_X, 0,
                                                          USER_PROFILE_WIDTH, USER_PROFILE_HEIGHT);
        }

        self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];

        self.mNameLabel.frame = self.mUserProfileImageView.frame;

        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:alMessage.to]];
        ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
        ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
        NSString * receiverName = [alContact getDisplayName];
        if(alContact.contactImageUrl)
        {
            NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
            
            [self.mUserProfileImageView sd_setImageWithURL:theUrl1 placeholderImage: [ALUtilityClass getImageFromFramworkBundle:@"ic_contact_picture_holo_light.png"] options:SDWebImageRefreshCached];
            
        }
        else
        {
            [self.mUserProfileImageView sd_setImageWithURL:[NSURL URLWithString:@""]];
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:alMessage.to];
        }

        //Shift for message reply and channel name..

        CGFloat requiredHeight = viewSize.width - BUBBLE_PADDING_HEIGHT;

        CGFloat imageViewY =  self.mBubleImageView.frame.origin.y + CNT_PROFILE_Y;

        [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X , 0,
                                                  viewSize.width - BUBBLE_PADDING_WIDTH, requiredHeight)];
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


        [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X , 0,
                                                  viewSize.width - BUBBLE_PADDING_WIDTH, requiredHeight)];

        [self.contactProfileImage setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + CNT_PROFILE_X,
                                                      self.mBubleImageView.frame.origin.y + CNT_PROFILE_Y,
                                                      CNT_PROFILE_WIDTH, CNT_PROFILE_HEIGHT)];

        CGFloat widthName = self.mBubleImageView.frame.size.width - (self.contactProfileImage.frame.size.width + 25);

        [self.contactPerson setFrame:CGRectMake(self.contactProfileImage.frame.origin.x + self.contactProfileImage.frame.size.width + CNT_PERSON_X,
                                                self.contactProfileImage.frame.origin.y, widthName, CNT_PERSON_HEIGHT)];

        [self.userContact setFrame:CGRectMake(self.contactPerson.frame.origin.x,
                                              self.contactPerson.frame.origin.y + self.contactPerson.frame.size.height + USER_CNT_Y,
                                              widthName, USER_CNT_HEIGHT)];

        [self.emailId setFrame:CGRectMake(self.userContact.frame.origin.x,
                                          self.userContact.frame.origin.y + self.userContact.frame.size.height + EMAIL_Y,
                                          widthName, EMAIL_HEIGHT)];

        [self.addContactButton setFrame:CGRectMake(self.contactProfileImage.frame.origin.x,
                                                   self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height - BUTTON_Y,
                                                   self.mBubleImageView.frame.size.width - BUTTON_WIDTH, BUTTON_HEIGHT)];

        self.mDateLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x ,
                                           self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height,
                                           theDateSize.width , DATE_HEIGHT);

        self.mDateLabel.textAlignment = NSTextAlignmentLeft;

        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width,
                                                        self.mDateLabel.frame.origin.y, 20, 20);

        [self.addContactButton setBackgroundColor:[UIColor grayColor]];



    }
    else
    {
        self.mUserProfileImageView.frame = CGRectMake(viewSize.width - USER_PROFILE_PADDING_X_OUTBOX, 0, 0, USER_PROFILE_HEIGHT);

        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];


        //Shift for message reply and channel name..

        CGFloat requiredHeight = viewSize.width - BUBBLE_PADDING_HEIGHT_OUTBOX;

        CGFloat imageViewY =  self.mBubleImageView.frame.origin.y + CNT_PROFILE_Y;

        self.mBubleImageView.frame = CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + BUBBLE_PADDING_X_OUTBOX), 0,
                                                viewSize.width - BUBBLE_PADDING_WIDTH, viewSize.width - BUBBLE_PADDING_HEIGHT_OUTBOX);

        if(alMessage.isAReplyMessage)
        {
            [self processReplyOfChat:alMessage andViewSize:viewSize];

            requiredHeight = requiredHeight + self.replyParentView.frame.size.height;
            imageViewY = imageViewY +  self.replyParentView.frame.size.height;

        }


        self.mBubleImageView.frame = CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + BUBBLE_PADDING_X_OUTBOX), 0,
                                                viewSize.width - BUBBLE_PADDING_WIDTH, requiredHeight);

        [self.contactProfileImage setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + CNT_PROFILE_X,
                                                      self.mBubleImageView.frame.origin.y + CNT_PROFILE_Y,
                                                      CNT_PROFILE_WIDTH, CNT_PROFILE_HEIGHT)];

        CGFloat widthName = self.mBubleImageView.frame.size.width - (self.contactProfileImage.frame.size.width + 25);

        [self.contactPerson setFrame:CGRectMake(self.contactProfileImage.frame.origin.x +
                                                self.contactProfileImage.frame.size.width + CNT_PERSON_X,
                                                self.contactProfileImage.frame.origin.y, widthName, CNT_PERSON_HEIGHT)];

        [self.userContact setFrame:CGRectMake(self.contactPerson.frame.origin.x,
                                              self.contactPerson.frame.origin.y + self.contactPerson.frame.size.height + USER_CNT_Y,
                                              widthName, USER_CNT_HEIGHT)];

        [self.emailId setFrame:CGRectMake(self.userContact.frame.origin.x, self.userContact.frame.origin.y +
                                          self.userContact.frame.size.height + EMAIL_Y,
                                          widthName, EMAIL_HEIGHT)];

        [self.addContactButton setFrame:CGRectMake(self.contactProfileImage.frame.origin.x,
                                                   self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height - BUTTON_Y,
                                                   self.mBubleImageView.frame.size.width - BUTTON_WIDTH, BUTTON_HEIGHT)];

        [self.mMessageStatusImageView setHidden:NO];

        msgFrameHeight = self.mBubleImageView.frame.size.height - (self.addContactButton.frame.size.height + self.addContactButton.frame.size.height/2);

        self.mDateLabel.textAlignment = NSTextAlignmentLeft;

        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width)
                                           - theDateSize.width - DATE_PADDING_X,
                                           self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height,
                                           theDateSize.width, DATE_HEIGHT);

        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width,
                                                        self.mDateLabel.frame.origin.y,
                                                        MSG_STATUS_WIDTH, MSG_STATUS_HEIGHT);

        [self.addContactButton setBackgroundColor:[UIColor whiteColor]];

    }

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

    self.mDateLabel.text = theDate;

    theUrl = nil;

    if (alMessage.imageFilePath != NULL)
    {
        NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * filePath = [docDir stringByAppendingPathComponent:alMessage.imageFilePath];
        theUrl = [NSURL fileURLWithPath:filePath];

        if(IS_OS_EARLIER_THAN_10)
        {
            vcfClass = [[ALVCFClass alloc] init];
            [vcfClass parseVCFData:filePath];

            [self.contactPerson setText:vcfClass.fullName];
            if(vcfClass.retrievedImage)
            {
                [self.contactProfileImage setImage:vcfClass.retrievedImage];
            }
            [self.emailId setText:vcfClass.emailID];
            [self.userContact setText:vcfClass.phoneNumber];
        }
        else
        {
            vCardClass = [[ALVCardClass alloc] init];
            [vCardClass vCardParser:filePath];

            [self.contactPerson setText:vCardClass.fullName];
            if(vCardClass.contactImage)
            {
                [self.contactProfileImage setImage:vCardClass.contactImage];
            }
            [self.emailId setText:vCardClass.userEMAIL_ID];
            [self.userContact setText:vCardClass.userPHONE_NO];

        }

        [self.addContactButton setEnabled:YES];

    }
    else if((!alMessage.imageFilePath && alMessage.fileMeta.blobKey) || (alMessage.imageFilePath && !alMessage.fileMeta.blobKey))
    {
        [super.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
    }

    self.contactProfileImage.layer.cornerRadius = self.contactProfileImage.frame.size.width/2;
    self.contactProfileImage.layer.masksToBounds = YES;

    self.mBubleImageView.layer.shadowOpacity = 0.3;
    self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
    self.mBubleImageView.layer.shadowRadius = 1;
    self.mBubleImageView.layer.masksToBounds = NO;

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

-(void)addButtonAction
{
    @try
    {
        if(IS_OS_EARLIER_THAN_10)
        {
            [vcfClass showOptionForContact];
        }
        else
        {
            [vCardClass addContact:vCardClass];
        }
    } @catch (NSException *exception) {

        NSLog(@"CONTACT_EXCEPTION :: %@", exception.description);
    }
}

//==================================================================================================
#pragma mark - KAProgressLabel Delegate Methods
//==================================================================================================

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

-(void)dowloadRetryActionButton
{
    [super.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    ALFileMetaInfo *metaInfo = (ALFileMetaInfo *)object;
    [self setNeedsDisplay];
    self.progresLabel.startDegree = 0;
    self.progresLabel.endDegree = metaInfo.progressValue;
}

//==================================================================================================
//==================================================================================================


-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if([self.mMessage.type isEqualToString:@MT_OUTBOX_CONSTANT] && self.mMessage.groupId)
    {
        return (self.mMessage.isDownloadRequired? (action == @selector(delete:) || action == @selector(msgInfo:)):(action == @selector(delete:)|| action == @selector(msgInfo:)||  [self isForwardMenuEnabled:action]  ||  [self isMessageReplyMenuEnabled:action]));
    }

    return (self.mMessage.isDownloadRequired? (action == @selector(delete:)):
            (action == @selector(delete:) ||  [self isForwardMenuEnabled:action]  || [self isMessageReplyMenuEnabled:action]));
}


-(void) delete:(id)sender
{
    [self.delegate deleteMessageFromView:self.mMessage];
    [ALMessageService deleteMessage:self.mMessage.key andContactId:self.mMessage.contactIds withCompletion:^(NSString *string, NSError *error) {

        NSLog(@"DELETE MESSAGE ERROR :: %@", error.description);
    }];
}

-(void)openUserChatVC
{
    [self.delegate processUserChatView:self.mMessage];
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
- (void)msgInfo:(id)sender
{
    [self.delegate showAnimationForMsgInfo:YES];
    UIStoryboard *storyboardM = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALMessageInfoViewController *msgInfoVC = (ALMessageInfoViewController *)[storyboardM instantiateViewControllerWithIdentifier:@"ALMessageInfoView"];

    msgInfoVC.VCFObject = vcfClass;
    msgInfoVC.VCardClass = vCardClass;

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
