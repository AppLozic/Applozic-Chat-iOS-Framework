//
//  ALGroupDetailViewController.h
//  Applozic
//
//  Created by Divjyot Singh on 23/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALNewContactsViewController.h"

@interface ALGroupDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate ,UIAlertViewDelegate,ALContactDelegate>

@property (nonatomic) NSInteger memberCount;
@property (strong, nonatomic) NSNumber * channelKeyID;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSString * memberIdToAdd;
@property (strong,nonatomic) NSMutableArray * lastSeenMembersArray;

@property (strong,nonatomic)UIViewController * alChatViewController;

@end
