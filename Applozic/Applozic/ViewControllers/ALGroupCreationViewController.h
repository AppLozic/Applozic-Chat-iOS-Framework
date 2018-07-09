//
//  ALGroupCreationViewController.h
//  Applozic
//
//  Created by Divjyot Singh on 13/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALGroupInfoDelegate <NSObject>

@optional

-(void)updateGroupInformation;

@end

@interface ALGroupCreationViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *groupNameInput;
@property (weak, nonatomic) IBOutlet UIImageView *groupIconView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (strong,nonatomic) NSString * groupImageUploadURL;
@property (nonatomic,strong) NSString * groupImageURL;

/**************************************
 CASE IF UPDATING GROUP INFORMATION
 UPDATING GROUP NAME/IMAGE
 **************************************/

@property (nonatomic) BOOL isViewForUpdatingGroup;
@property (nonatomic, strong) NSNumber * channelKey;
@property (nonatomic, strong) NSString * channelName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) id <ALGroupInfoDelegate> grpInfoDelegate;

/**************************************
 CASE SUB GROUP
 **************************************/

@property (nonatomic, strong) NSNumber * parentChannelKey;

@end
