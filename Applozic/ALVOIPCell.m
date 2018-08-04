//
//  ALVOIPCell.m
//  Applozic
//
//  Created by Abhishek Thapliyal on 2/14/17.
//  Copyright © 2017 applozic Inc. All rights reserved.
//

#import "ALVOIPCell.h"
#import "ALUtilityClass.h"
#import "ALApplozicSettings.h"
#import "ALAudioVideoBaseVC.h"

@implementation ALVOIPCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize
{
    [super populateCell:alMessage viewSize:viewSize];
    
    [self.mMessageLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [self.mMessageLabel setTextAlignment:NSTextAlignmentCenter];
    [self.mMessageLabel setBackgroundColor:[UIColor clearColor]];
    [self.mMessageLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.mMessageLabel setTextColor:[UIColor whiteColor]];
    [self.mMessageLabel setUserInteractionEnabled:NO];
    NSString *textMsg = [alMessage getVOIPMessageText];
   
    textMsg = [NSString stringWithFormat:@"%@ at %@",textMsg, self.mDateLabel.text];
   
    [self.mDateLabel setHidden:YES];
    self.mUserProfileImageView.alpha = 0;
    self.mNameLabel.hidden = YES;
    self.mChannelMemberName.hidden = YES;
    self.mMessageStatusImageView.hidden = YES;
    
    NSTimeInterval duration = [[alMessage.metadata objectForKey:@"CALL_DURATION"] integerValue];
    if (duration){
        NSString *callDuration = [ALUtilityClass stringFromTimeInterval:duration/1000];
        textMsg = [NSString stringWithFormat:@"%@ %@",textMsg, callDuration];
    }
    [self.mMessageLabel setText:textMsg];
    
    CGSize theTextSize = [ALUtilityClass getSizeForText:textMsg maxWidth:viewSize.width - 115
                                                   font:self.mMessageLabel.font.fontName
                                               fontSize:self.mMessageLabel.font.pointSize];
    int padding = 10;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat bubbleWidth = screenSize.width - (6 * padding);
    
    CGPoint theTextPoint = CGPointMake((screenSize.width - bubbleWidth)/2, 0);
    
    CGRect frame = CGRectMake(theTextPoint.x, theTextPoint.y,
                              bubbleWidth, theTextSize.height + (2 * padding));
    
    self.mBubleImageView.backgroundColor = [UIColor lightGrayColor];
    [self.mBubleImageView setFrame:frame];
    [self.mBubleImageView setHidden:NO];
    
    [self.mMessageLabel setFrame: CGRectMake(self.mBubleImageView.frame.origin.x + padding ,padding,
                                             bubbleWidth - (2 * padding),
                                             theTextSize.height)];
    
    return self;
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
  
    return (action == @selector(delete:));

}



@end
