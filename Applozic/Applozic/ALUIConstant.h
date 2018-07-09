//
//  ALUIConstant.h
//  Applozic
//
//  Created by devashish on 03/05/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALMessage.h"

@interface ALUIConstant : NSObject

+ (CGSize) getFrameSize;
+ (CGSize) textSize:(ALMessage *)theMessage andCellFrame:(CGRect)cellFrame;

+ (CGFloat) getLocationCellHeight:(CGRect)cellFrame;
+ (CGFloat) getDateCellHeight;
+ (CGFloat) getAudioCellHeight;
+ (CGFloat) getContactCellHeight;
+ (CGFloat) getDocumentCellHeight;

+ (CGFloat) getVideoCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame;
+ (CGFloat) getImageCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame;
+ (CGFloat) getChatCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame;

+ (CGFloat) getCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame;

@end
