//
//  ALShowImageViewController.h
//  Applozic
//
//  Created by Divjyot Singh on 26/07/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALChatViewController.h"
#import "ALImageActivity.h"
#import "ALNewContactsViewController.h"

@interface ALShowImageViewController : UIViewController <ALImageActivityDelegate>

@property (strong,nonatomic) UIImage * image;
@property (strong,nonatomic) ALMessage * alMessage;
@property (strong,nonatomic) ALImageActivity * alImageActivity;
@property (strong,nonatomic) ALNewContactsViewController * contactsViewController;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
