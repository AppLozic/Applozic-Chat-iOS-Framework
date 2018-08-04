//
//  ALUIConstant.m
//  Applozic
//
//  Created by devashish on 23/04/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

@import UIKit;
#import "ALUIConstant.h"
#import "ALUtilityClass.h"
#import "ALApplozicSettings.h"
#import "ALAudioVideoBaseVC.h"
#import "ALChannelMsgCell.h"

@implementation ALUIConstant


+(CGSize) getFrameSize
{
    CGSize PHONE_SIZE = [UIScreen mainScreen].bounds.size;
    return PHONE_SIZE;
}

+(CGSize)textSize:(ALMessage *)theMessage andCellFrame:(CGRect)cellFrame
{
    CGSize theTextSize = [ALUtilityClass getSizeForText:theMessage.message
                                               maxWidth:cellFrame.size.width - 115
                                                   font:[ALApplozicSettings getFontFace]
                                               fontSize:MESSAGE_TEXT_SIZE];
    
    return theTextSize;
}

//=========================================================================================================
#pragma ChatViewController TABLE CELL HEIGHT CONSTANTS
//=========================================================================================================

+(CGFloat)getLocationCellHeight:(CGRect)cellFrame
{
    CGFloat HEIGHT = cellFrame.size.width - 140;
    return HEIGHT;
}

+(CGFloat)getDateCellHeight
{
    CGFloat HEIGHT = 30;
    return HEIGHT;
}

+(CGFloat)getAudioCellHeight
{
    CGFloat HEIGHT = 130;
    return HEIGHT;
}

+(CGFloat)getContactCellHeight
{
    CGFloat HEIGHT = 265;
    return HEIGHT;
}

+(CGFloat)getDocumentCellHeight
{
    CGFloat HEIGHT = 130;
    return HEIGHT;
}

+(CGFloat)getVideoCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame
{
    CGFloat HEIGHT = cellFrame.size.width - 60;
    if(alMessage.message.length > 0)
    {
        CGSize theTextSize = [self textSize:alMessage andCellFrame:cellFrame];
        HEIGHT = theTextSize.height + HEIGHT;
    }
    
    return HEIGHT;
}

+(CGFloat)getImageCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame  // NEED CHECK AGAIN image & image with text
{
    CGFloat HEIGHT = cellFrame.size.width - 70;
    if(alMessage.message.length > 0)
    {
        CGSize theTextSize = [self textSize:alMessage andCellFrame:cellFrame];
        HEIGHT = theTextSize.height + HEIGHT;
    }
    
    return HEIGHT;
}

+(CGFloat)getChatCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame  // NEED CHECK AGAIN TEXT CELL
{
    CGSize theTextSize = [self textSize:alMessage andCellFrame:cellFrame];
    CGFloat HEIGHT = theTextSize.height + 70;
    
    return HEIGHT;
}

+(CGFloat)getCustomChatCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame
{
    CGSize theTextSize = [ALUtilityClass getSizeForText:alMessage.message
                                               maxWidth:cellFrame.size.width - 115
                                                   font:[ALApplozicSettings getCustomMessageFont]
                                               fontSize:[ALApplozicSettings getCustomMessageFontSize]];
    
    CGFloat HEIGHT = theTextSize.height + 40;
    
    return HEIGHT;
}

+(CGFloat)getVOIPCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame
{
    CGSize theTextSize = [ALUtilityClass getSizeForText:[alMessage getVOIPMessageText]
                                               maxWidth:cellFrame.size.width - 115
                                                   font:[ALApplozicSettings getCustomMessageFont]
                                               fontSize:[ALApplozicSettings getCustomMessageFontSize]];
                                            // WORKING FOR NOW BUT NEED TO CHANGE FONT & FONT-SIZE FOR VOIP TEXT BEFORE RELEASE
    
    CGFloat HEIGHT = theTextSize.height + 40;
    return HEIGHT;
}

+(CGFloat)getChannelMsgCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame
{
    CGSize theTextSize = [ALUtilityClass getSizeForText:alMessage.message
                                               maxWidth:cellFrame.size.width - 115
                                                   font:@"Helvetica"
                                               fontSize:CH_MESSAGE_TEXT_SIZE];
    
    CGFloat HEIGHT = theTextSize.height + 30;    
    return HEIGHT;
}

+ (CGFloat) getCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame
{
    
    CGFloat replyViewHeight = 70;
    CGFloat heightOfCell;
    
    if(alMessage.contentType == ALMESSAGE_CONTENT_LOCATION)
    {
        heightOfCell = [self getLocationCellHeight:cellFrame];
    }
    else if([alMessage.type isEqualToString:@"100"])
    {
        heightOfCell=  [self getDateCellHeight];
    }
    else if(alMessage.contentType == ALMESSAGE_CHANNEL_NOTIFICATION)
    {
        if ([alMessage isMsgHidden]){
            heightOfCell= 0;
        }
        heightOfCell = [self getChannelMsgCellHeight:alMessage andCellFrame:cellFrame];
    }
    else if ([alMessage.fileMeta.contentType hasPrefix:@"video"])
    {
        heightOfCell= [self getVideoCellHeight:alMessage andCellFrame:cellFrame];
    }
    else if ([alMessage.fileMeta.contentType hasPrefix:@"audio"])
    {
        heightOfCell = [self getAudioCellHeight] ;
    }
    else if ([alMessage.fileMeta.contentType hasPrefix:@"image"])
    {
        heightOfCell = [self getImageCellHeight:alMessage andCellFrame:cellFrame] ;
    }
    else if (alMessage.contentType == AV_CALL_CONTENT_THREE)
    {
        return [self getVOIPCellHeight:alMessage andCellFrame:cellFrame];
    }
    else if (alMessage.contentType == ALMESSAGE_CONTENT_CUSTOM)
    {
        heightOfCell = [self getCustomChatCellHeight:alMessage andCellFrame:cellFrame];
    }
    else if (alMessage.contentType == ALMESSAGE_CONTENT_DEFAULT)
    {
        heightOfCell =[self getChatCellHeight:alMessage andCellFrame:cellFrame];
    }
    else if (alMessage.contentType == (short)ALMESSAGE_CONTENT_VCARD)
    {
        heightOfCell = [self getContactCellHeight];
    }
    else
    {
        heightOfCell= [self getDocumentCellHeight];
    }
    
    if(alMessage.isAReplyMessage)
    {
        heightOfCell = heightOfCell + replyViewHeight;
    }
    return heightOfCell;
}

@end
