//
//  ALVCFClass.h
//  Applozic
//
//  Created by devashish on 09/04/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AddressBookUI;

@interface ALVCFClass : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * phoneNumber;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * emailID;
@property (nonatomic, strong) NSString * fullName;
@property (nonatomic, strong) UIImage * retrievedImage;

-(NSString *)saveContactToDocumentDirectory:(ABRecordRef)person;
-(void)parseVCFData:(NSString *)vcfFilePath;
-(void)showOptionForContact;

@end
