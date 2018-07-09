//
//  ALReceiverUserProfileVC.m
//  Applozic
//
//  Created by devashish on 01/08/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALReceiverUserProfileVC.h"
#import "ALUtilityClass.h"
#import "UIImageView+WebCache.h"
#import "ALApplozicSettings.h"

@interface ALReceiverUserProfileVC ()

@end

@implementation ALReceiverUserProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setUpProfileItems];
}

-(void)setUpProfileItems
{
    [self.displayName setText:[self.alContact getDisplayName]];
    NSString * lastSeenString = @"";
    if(self.alContact.lastSeenAt)
    {
        lastSeenString = self.alContact.connected ? @"Online" : [self getLastSeenString:self.alContact.lastSeenAt];
    }
    [self.lastSeen setText:lastSeenString];
    
    [self.userStatus setText:self.alContact.userStatus];
    [self.emailId setText:self.alContact.email ? self.alContact.email : @"Not Available"];
    [self.phoneNo setText:self.alContact.contactNumber ? self.alContact.contactNumber : @"Not Available"];
    
    [self.profileImageView setImage:[ALUtilityClass getImageFromFramworkBundle:@"ic_contact_picture_holo_light.png"]];
    if(self.alContact.contactImageUrl)
    {
        NSURL * theUrl = [NSURL URLWithString:self.alContact.contactImageUrl];
        [self.profileImageView sd_setImageWithURL:theUrl placeholderImage:nil options:SDWebImageRefreshCached];
    }
    
    [self.callButton setEnabled:NO];
    if(self.alContact.contactNumber)
    {
        [self.callButton setEnabled:YES];
    }
    
    if([ALApplozicSettings getColorForNavigation] && [ALApplozicSettings getColorForNavigationItem])
    {
        [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
        [self.navigationController.navigationBar setTintColor:[ALApplozicSettings getColorForNavigationItem]];
        [self.navigationController.navigationBar addSubview:[ALUtilityClass setStatusBarStyle]];
    }
}

-(NSString *)getLastSeenString:(NSNumber *)lastSeen
{
    ALUtilityClass * utility = [ALUtilityClass new];
    [utility getExactDate:lastSeen];
    NSString * text = [NSString stringWithFormat:@"Last seen %@ %@", utility.msgdate, utility.msgtime];
    return text;
}


//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)callButtonAction:(id)sender {
    
    NSURL * phoneNumber = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", self.alContact.contactNumber]];
    [[UIApplication sharedApplication] openURL:phoneNumber];
}
@end
