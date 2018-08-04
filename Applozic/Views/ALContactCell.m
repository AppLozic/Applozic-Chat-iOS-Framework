//
//  ALContactCell.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALContactCell.h"

@implementation ALContactCell

- (void)awakeFromNib {
    [[self mUserNameLabel] setTextAlignment:NSTextAlignmentRight];
    [[self mMessageLabel] setTextAlignment:NSTextAlignmentRight];
    [[self imageNameLabel] setTextAlignment:NSTextAlignmentRight];
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  
    [super setSelected:selected animated:animated];

}

@end
