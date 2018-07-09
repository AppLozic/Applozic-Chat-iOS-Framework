//
//  ALUserProfileVC.h
//  Applozic
//
//  Created by devashish on 30/06/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ALUserProfileVC : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *uploadImageButton;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
- (IBAction)uploadImageAction:(id)sender;
- (IBAction)notificationToggle:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userDesignationLabel;

@property (weak, nonatomic) IBOutlet UIView *userView;


@end
