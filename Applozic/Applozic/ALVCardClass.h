//
//  ALVCardClass.h
//  Applozic
//
//  Created by Abhishek Thapliyal on 9/21/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Contacts;
@import ContactsUI;

@interface ALVCardClass : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) UIImage * contactImage;
@property (nonatomic, strong) NSString * fullName;
@property (nonatomic, strong) NSString * userPHONE_NO;
@property (nonatomic, strong) NSString * userEMAIL_ID;

@property (nonatomic, strong) CNContact * alCNContact;

-(NSString *)saveContactToDocDirectory:(CNContact *)contact;
-(void)vCardParser:(NSString *)filePath;
-(void)addContact:(ALVCardClass *)alVcard;


@end
