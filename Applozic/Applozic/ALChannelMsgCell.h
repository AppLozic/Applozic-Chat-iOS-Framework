//
//  ALChannelMsgCell.h
//  Applozic
//
//  Created by Abhishek Thapliyal on 2/20/17.
//  Copyright © 2017 applozic Inc. All rights reserved.
//

#define CH_MESSAGE_TEXT_SIZE 14

#import <Applozic/Applozic.h>

@interface ALChannelMsgCell : ALChatCell

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize;

@end
