//
//  ALChatCell.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//
/*********************************************************************
 TABLE CELL CUSTOM CLASS : THIS CLASS IS OF PURE TEXT MESSSAGE
 **********************************************************************/

#import <UIKit/UIKit.h>
#import "ALHyperLabel.h"
#import "MessageReplyView.h"
#import "ALTappableView.h"
#import <ApplozicCore/ApplozicCore.h>

@protocol ALChatCellDelegate <NSObject>

- (void) deleteMessasgeforAll:(ALMessage *) message;
- (void) deleteMessageFromView:(ALMessage *) message;
- (void) loadView:(UIViewController *)launch;
- (void) showAnimation:(BOOL)flag;
- (void) processALMessage:(ALMessage *) message;
- (void) processForwardMessage:(ALMessage *) message;
- (void)messageReport:(ALMessage *)alMessage;

@optional

- (void)openUserChat:(ALMessage *)alMessage;
- (void)processMessageReply:(ALMessage *) message;
- (void)scrollToReplyMessage:(ALMessage *)message;
- (void)handleTapGestureForKeyBoard;

@end

@interface ALChatCell : UITableViewCell

@property (retain, nonatomic) ALHyperLabel *mMessageLabel;

@property (strong, nonatomic) NSMutableArray * hyperLinkArray;

@property (retain, nonatomic) UILabel *mDateLabel;

@property (nonatomic,retain) UIImageView *mBubleImageView;

@property (nonatomic,retain) UIImageView *mUserProfileImageView;

@property (nonatomic, retain) ALMessage *mMessage;

@property (nonatomic, retain) UIImageView *mMessageStatusImageView;

- (instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize;

@property (nonatomic, assign) id<ALChatCellDelegate> delegate;

@property (retain, nonatomic) UILabel *mChannelMemberName;

@property (retain, nonatomic) UILabel *mNameLabel;

@property (retain, nonatomic) MessageReplyView *replyUIView;

@property (retain, nonatomic) UIView *replyParentView;

@property (nonatomic, strong) ALChannel *channel;

@property (strong, nonatomic)  NSMutableDictionary *colourDictionary;

@property (nonatomic,retain) ALTappableView * frontView;

@end
