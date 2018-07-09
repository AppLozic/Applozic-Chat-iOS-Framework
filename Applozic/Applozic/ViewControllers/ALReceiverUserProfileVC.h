//
//  ALReceiverUserProfileVC.h
//  Applozic
//
//  Created by devashish on 01/08/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALContactService.h"

@interface ALReceiverUserProfileVC : UITableViewController

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *displayName;
@property (strong, nonatomic) IBOutlet UILabel *lastSeen;
@property (strong, nonatomic) IBOutlet UILabel *userStatus;
@property (strong, nonatomic) IBOutlet UILabel *emailId;
@property (strong, nonatomic) IBOutlet UILabel *phoneNo;
@property (strong, nonatomic) IBOutlet UIButton *callButton;

@property (strong, nonatomic) ALContact *alContact;

- (IBAction)callButtonAction:(id)sender;


@end
