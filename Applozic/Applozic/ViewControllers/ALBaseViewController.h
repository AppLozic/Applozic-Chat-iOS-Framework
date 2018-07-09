//
//  ALBaseViewController.h
//  ChatApp
//
//  Created by Kumar, Sawant (US - Bengaluru) on 9/23/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALBaseViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) NSString * placeHolderTxt;
@property (nonatomic, retain) UIColor * placeHolderColor;
@property (nonatomic, retain) UIColor *navColor;
@property (nonatomic,retain) UIView * mTableHeaderView;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *mTapGesture;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *sendMessageTextView;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *attachmentOutlet;
@property (strong, nonatomic) UILabel * label;
//@property (strong, nonatomic) UILabel * typingLabel;
@property (nonatomic) BOOL  individualLaunch;
@property (weak, nonatomic) IBOutlet UIView * typingMessageView;
@property (nonatomic, strong) NSArray * wordArray;
@property (strong, nonatomic) UIBarButtonItem * callButton;
@property (strong, nonatomic) UIBarButtonItem * closeButton;

@property (strong, nonatomic) NSMutableArray <UIBarButtonItem *> * navRightBarButtonItems;

- (IBAction)sendAction:(id)sender;
-(void) scrollTableViewToBottomWithAnimation:(BOOL) animated;
- (IBAction)attachmentActionMethod:(id)sender;
-(UIView *)setCustomBackButton;

@property (strong, nonatomic) IBOutlet UIImageView *typeMsgBG;

// ===Message Text View Constaints===
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textMessageViewHeightConstaint;

@property (strong, nonatomic) UILabel *noConversationLabel;
@property (weak, nonatomic) IBOutlet UILabel *noConLabel;
@property (weak, nonatomic) IBOutlet UILabel *typingLabel;

-(void)setHeightOfTextViewDynamically;
-(void)setHeightOfTextViewDynamically:(BOOL)scroll;

@property (weak, nonatomic) IBOutlet UIImageView *beakImageView;
-(void)subProcessSetHeightOfTextViewDynamically;

@end
