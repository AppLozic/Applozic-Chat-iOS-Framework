//
//  ALCustomCell.m
//  Applozic
//
//  Created by Divjyot Singh on 05/05/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALCustomCell.h"
#import "ALUtilityClass.h"
#import "ALApplozicSettings.h"

@implementation ALCustomCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize
{
    [super populateCell:alMessage viewSize:viewSize];

    [self.mMessageLabel setFont:[UIFont fontWithName:[ALApplozicSettings getCustomMessageFont]
                                                size:[ALApplozicSettings getCustomMessageFontSize]]];
    
    [self.mMessageLabel setTextAlignment:NSTextAlignmentCenter];
    [self.mMessageLabel setText:alMessage.message];
    [self.mMessageLabel setBackgroundColor:[UIColor clearColor]];
    [self.mMessageLabel setTextColor:[UIColor blackColor]];
    [self.mMessageLabel setUserInteractionEnabled:NO];
    
    [self.mDateLabel setHidden:YES];
    self.mUserProfileImageView.alpha = 0;
    self.mNameLabel.hidden = YES;
    self.mChannelMemberName.hidden = YES;
    self.mMessageStatusImageView.hidden = YES;
    
    CGSize theTextSize = [ALUtilityClass getSizeForText:alMessage.message maxWidth:viewSize.width - 115
                                                   font:self.mMessageLabel.font.fontName
                                               fontSize:self.mMessageLabel.font.pointSize];
    
    int padding  =  10;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat bubbleWidth = theTextSize.width + (2 * padding);
    
    CGPoint theTextPoint = CGPointMake((screenSize.width - bubbleWidth)/2, 0);
    
    CGRect frame = CGRectMake(theTextPoint.x, theTextPoint.y,
                              bubbleWidth, theTextSize.height + (2 * padding));

    self.mBubleImageView.backgroundColor = [ALApplozicSettings getCustomMessageBackgroundColor];
    [self.mBubleImageView setFrame:frame];
    [self.mBubleImageView setHidden:NO];
    
    [self.mMessageLabel setFrame: CGRectMake(self.mBubleImageView.frame.origin.x + padding ,padding,
                                             theTextSize.width,
                                             theTextSize.height)];

    return self;
}

@end
