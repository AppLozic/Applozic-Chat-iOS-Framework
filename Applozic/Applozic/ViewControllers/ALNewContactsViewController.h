//
//  ALNewContactsViewController.h
//  ChatApp
//
//  Created by Gaurav Nigam on 16/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#define REGULAR_CONTACTS 0
#define GROUP_CREATION 1
#define GROUP_ADDITION 2
#define IMAGE_SHARE 3
#define LAUNCH_GROUP_OF_TWO 4
#define BROADCAST_GROUP_CREATION 5
#define SHOW_CONTACTS 101
#define SHOW_GROUP 102

#import <UIKit/UIKit.h>
#import "ALChannelService.h"
#import "ALMessageDBService.h"

@protocol ALContactDelegate <NSObject>

@optional

-(void)addNewMembertoGroup:(ALContact *)alcontact withCompletion:(void(^)(NSError *error,ALAPIResponse *response))completion;

@end

@protocol ALForwardMessageDelegate <NSObject>

@optional

-(void)proccessReloadAndForwardMessage:(ALMessage *)alMessage;

@end

@interface ALNewContactsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mTableViewTopConstraint;
@property (nonatomic,strong) NSArray* colors;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, strong) NSNumber* forGroup;
@property (nonatomic, strong) UIBarButtonItem *done;
@property (nonatomic, strong) NSString* groupName;
@property (nonatomic, strong) NSString * groupImageURL;
@property (nonatomic, strong) NSNumber * forGroupAddition;
@property (nonatomic, strong) NSMutableArray * contactsInGroup;
@property (nonatomic, assign) id <ALContactDelegate> delegate;
@property (nonatomic) BOOL directContactVCLaunch;
@property (nonatomic) BOOL directContactVCLaunchForForward;
@property(nonatomic,strong) ALMessage *alMessage;
@property (nonatomic, weak)id<ALForwardMessageDelegate>forwardDelegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopSegmentConstraint;

- (IBAction)segmentControlAction:(id)sender;
-(UIView *)setCustomBackButton:(NSString *)text;

/********************
LAUNCH FOR SUB GROUP
*********************/

@property (nonatomic, strong) ALChannel * parentChannel;
@property (nonatomic, strong) NSMutableArray * childChannels;

-(void)launchProcessForSubgroups;
-(void)proccessContactsGroupList;

@end
