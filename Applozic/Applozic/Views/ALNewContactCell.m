//
//  ALNewContactCell.m
//  ChatApp
//
//  Created by Gaurav Nigam on 16/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALNewContactCell.h"

@implementation ALNewContactCell

- (void)awakeFromNib {
    // Initialization code
    [[self contactPersonName] setTextAlignment:NSTextAlignmentNatural];
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
