//
//  ALMessageInfoViewController.h
//  Applozic
//
//  Created by devashish on 17/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALContactCell.h"
#import "ALMessage.h"
#import "ALMessageService.h"
#import "ALMessageInfo.h"
#import "ALContactDBService.h"
#import "ALUtilityClass.h"
#import "ALColorUtility.h"
#import "ALVCFClass.h"
#import "ALVCardClass.h"

@interface ALMessageInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;

@property (nonatomic, strong) UILabel * userName;
@property (nonatomic, strong) UILabel * firstAlphabet;
@property (nonatomic, strong) UIImageView * userImage;
@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic, strong) UILabel * timeLabel;

@property (strong, nonatomic) IBOutlet UITableView * alTableView;
@property (strong, nonatomic) ALVCFClass * VCFObject;
@property (strong, nonatomic) ALVCardClass * VCardClass;
@property (nonatomic, weak) ALMessage *almessage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

-(void)setMessage:(ALMessage *)almessage andHeaderHeight:(CGFloat)headerHeight withCompletionHandler:(void(^)(NSError * error))completion;
-(void)setTableCellView:(ALContactCell *)contactCell;
-(UIView *)viewForMessageSection:(UITableView *)tableView;

//=============================================================================================
#pragma HEADER VIEW
//=============================================================================================

@property (nonatomic, strong) NSURL * contentURL;
@property (nonatomic, strong) UIImageView * tickImageView;
@property (nonatomic, strong) UILabel * headerTitle;
@property (nonatomic) CGFloat msgHeaderHeight;


@end
