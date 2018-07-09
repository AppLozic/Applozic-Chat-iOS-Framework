//
//  ALContactMessageCell.h
//  Applozic
//
//  Created by devashish on 12/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//
/*********************************************************************
 TABLE CELL CUSTOM CLASS : THIS CLASS IS FOR CONTACT MESSSAGE 
 i.e SHARE CONTACT FROM PHONE CONTACTS
 **********************************************************************/

#import <UIKit/UIKit.h>
#import "ALMessage.h"
#import "ALMediaBaseCell.h"

@interface ALContactMessageCell : ALMediaBaseCell

@property (nonatomic, strong) UIImageView * contactProfileImage;
@property (nonatomic, strong) UILabel * userContact;
@property (nonatomic, strong) UILabel * contactPerson;
@property (nonatomic, strong) UILabel * emailId;
@property (nonatomic, strong) UIButton * addContactButton;

-(instancetype)populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize;

@end
