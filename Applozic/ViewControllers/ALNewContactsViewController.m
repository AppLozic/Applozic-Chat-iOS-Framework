//
//  ALNewContactsViewController.m
//  ChatApp
//
//  Created by Gaurav Nigam on 16/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALNewContactsViewController.h"
#import "ALNewContactCell.h"
#import "ALDBHandler.h"
#import "DB_CONTACT.h"
#import "ALContact.h"
#import "ALChatViewController.h"
#import "ALUtilityClass.h"
#import "ALConstant.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessagesViewController.h"
#import "ALColorUtility.h"
#import "UIImageView+WebCache.h"
#import "ALGroupCreationViewController.h"
#import "ALGroupDetailViewController.h"
#import "ALContactDBService.h"
#import "TSMessage.h"
#import "ALDataNetworkConnection.h"
#import "ALNotificationView.h"
#import "ALUserService.h"
#import "ALContactService.h"
#import "ALPushAssist.h"
#import "ALSubViewController.h"
#import "ALApplozicSettings.h"

#define DEFAULT_TOP_LANDSCAPE_CONSTANT -34
#define DEFAULT_TOP_PORTRAIT_CONSTANT -64



@interface ALNewContactsViewController ()

@property (strong, nonatomic) NSMutableArray *contactList;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *filteredContactList;

@property (strong, nonatomic) NSString *stopSearchText;

@property  NSUInteger lastSearchLength;

@property (strong,nonatomic)NSMutableSet* groupMembers;
@property (strong,nonatomic)ALChannelService * creatingChannel;

@property (strong,nonatomic) NSNumber* groupOrContacts;
@property (strong, nonatomic) NSMutableArray *alChannelsList;
@property (nonatomic)NSInteger selectedSegment;
@property (strong, nonatomic) UILabel *emptyConversationText;
@end

@implementation ALNewContactsViewController
{
    UIBarButtonItem *barButtonItem;
}
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self activityIndicator] startAnimating];
    self.selectedSegment = 0;
    [ALUserDefaultsHandler setContactServerCallIsDone:NO];
    
    [self.segmentControl setTitle:  NSLocalizedStringWithDefaultValue(@"contactsTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Contacts" , @"") forSegmentAtIndex:0];
    
    [self.segmentControl setTitle:  NSLocalizedStringWithDefaultValue(@"groupsTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Groups" , @"") forSegmentAtIndex:1];
    
    self.contactList = [NSMutableArray new];
    [self handleFrameForOrientation];
    
    //    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"< Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    //    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    //    if(![ALUserDefaultsHandler getContactViewLoaded] && [ALApplozicSettings getFilterContactsStatus]) // COMMENTED for INTERNAL PURPOSE
    //    {
    
    float y = self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height;
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,y, self.view.frame.size.width, 40)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder =  NSLocalizedStringWithDefaultValue(@"searchInfo", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Email, userid, number" , @"") ;
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        UITextField *searchTextField = [((UITextField *)[self.searchBar.subviews objectAtIndex:0]).subviews lastObject];
        searchTextField.layer.cornerRadius = 15.0f;
        searchTextField.textAlignment = NSTextAlignmentRight;
    }
    [self.view addSubview:self.searchBar];
    
    [self.searchBar setUserInteractionEnabled:NO];
    if(self.parentChannel)
    {
        [self launchProcessForSubgroups];
        [self.searchBar setUserInteractionEnabled:YES];
    }
    else if([ALApplozicSettings getFilterContactsStatus] && ![ALApplozicSettings isContactsGroupEnabled])
    {
        [self proccessRegisteredContactsCall:NO];
    }
    else if([ALApplozicSettings getOnlineContactLimit] && ![ALApplozicSettings isContactsGroupEnabled])
    {
        [self processFilterListWithLastSeen];
        [self onlyGroupFetch];
        [self.searchBar setUserInteractionEnabled:YES];
    }else if( [ALApplozicSettings isContactsGroupEnabled] && [ALApplozicSettings getContactsGroupId] && ![ALApplozicSettings getFilterContactsStatus]){
        [self proccessContactsGroupCall];
    }else if( [ALApplozicSettings isContactsGroupEnabled] && [ALApplozicSettings getContactGroupIdList] && ![ALApplozicSettings getFilterContactsStatus]){
        [self proccessContactsGroupList];
    }else{
        NSLog(@"isContactsGroupEnabled:%d", [ALApplozicSettings isContactsGroupEnabled] );
        NSLog(@"isContactsGroupEnabled:%@", [ALApplozicSettings getContactGroupIdList] );
        NSLog(@"isContactsGroupEnabled:%d", [ALApplozicSettings getFilterContactsStatus] );

        
        [self subProcessContactFetch];
        [self.searchBar setUserInteractionEnabled:YES];
    }

    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self setCustomBackButton: NSLocalizedStringWithDefaultValue(@"back", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Back" , @"")]];
    
    self.colors = [[NSArray alloc] initWithObjects:@"#617D8A",@"#628B70",@"#8C8863",@"8B627D",@"8B6F62", nil];
    
    self.groupMembers=[[NSMutableSet alloc] init];
    
    [self emptyConversationAlertLabel];
}

-(void)subProcessContactFetch
{
    ALChannelDBService * alChannelDBService = [[ALChannelDBService alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchConversationsGroupByContactId];
        self.alChannelsList = [NSMutableArray arrayWithArray:[alChannelDBService getAllChannelKeyAndName]];
    });
}

-(void)onlyGroupFetch
{
    ALChannelDBService * alChannelDBService = [[ALChannelDBService alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.alChannelsList = [NSMutableArray arrayWithArray:[alChannelDBService getAllChannelKeyAndName]];
    });
}

- (void) dismissKeyboard
{
    // add self
    [self.searchBar resignFirstResponder];
}

-(void)viewWillLayoutSubviews
{
    float y = self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height;
    self.searchBar.frame = CGRectMake(0,y, self.view.frame.size.width, 40);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Due to changes in top layout guide in iOS 11, top constraint was behaving differently and tableview would not be visible properly.
    if(!TS_SYSTEM_VERSION_LESS_THAN(@"11.0")) {
        self.tableViewTopSegmentConstraint.constant = 0;
    }
    self.groupOrContacts = [NSNumber numberWithInt:SHOW_CONTACTS]; //default
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"contactsTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Contacts" , @"");
    [self.tabBarController.tabBar setHidden: [ALUserDefaultsHandler isBottomTabBarHidden]];
    
    if([ALApplozicSettings getColorForNavigation] && [ALApplozicSettings getColorForNavigationItem])
    {
        //        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setTitleTextAttributes: @{
                                                                           NSForegroundColorAttributeName:[ALApplozicSettings getColorForNavigationItem],
                                                                           NSFontAttributeName:[UIFont fontWithName:[ALApplozicSettings getFontFace]
                                                                                                               size:18]
                                                                           }];
        
        [self.navigationController.navigationBar addSubview:[ALUtilityClass setStatusBarStyle]];
        [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
        [self.navigationController.navigationBar setTintColor: [ALApplozicSettings getColorForNavigationItem]];
        
    }
    
    BOOL groupRegular = [self.forGroup isEqualToNumber:[NSNumber numberWithInt:REGULAR_CONTACTS]];
    BOOL subGroupContacts = [self.forGroup isEqualToNumber:[NSNumber numberWithInt:LAUNCH_GROUP_OF_TWO]];
    
    if(groupRegular)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showMQTTNotification:)
                                                     name:@"MQTT_APPLOZIC_01"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleAPNS:)
                                                     name:@"pushNotification"
                                                   object:nil];
    }
    
    if((!groupRegular && self.forGroup != NULL && !subGroupContacts)){
        [self updateView];
    }
    
    if(![ALApplozicSettings getGroupOption]){
        [self.navigationItem setTitle:NSLocalizedStringWithDefaultValue(@"contactsTitile", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Contacts" , @"")];
        [self.segmentControl setSelectedSegmentIndex:0];
        [self.segmentControl setHidden:YES];
    }
    
    [self.navigationItem setLeftBarButtonItem: barButtonItem];
    float y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    self.searchBar.frame = CGRectMake(0,y, self.view.frame.size.width, 40);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUser:) name:@"USER_DETAIL_OTHER_VC" object:nil];
}

-(void)showMQTTNotification:(NSNotification *)notifyObject
{
    ALMessage * alMessage = (ALMessage *)notifyObject.object;
    
    BOOL flag = (alMessage.groupId && [ALChannelService isChannelMuted:alMessage.groupId]);
    
    if (![alMessage.type isEqualToString:@"5"] && !flag && ![alMessage isMsgHidden])
    {
        ALNotificationView * alNotification = [[ALNotificationView alloc] initWithAlMessage:alMessage
                                                                           withAlertMessage:alMessage.message];
        [alNotification nativeNotification:self];
    }
}

-(void)handleAPNS:(NSNotification *)notification
{
    NSString * contactId = notification.object;
    NSLog(@"CONTACT_VC_NOTIFICATION_OBJECT : %@",contactId);
    NSDictionary *dict = notification.userInfo;
    NSNumber * updateUI = [dict valueForKey:@"updateUI"];
    NSString * alertValue = [dict valueForKey:@"alertValue"];
    
    NSArray * myArray = [contactId componentsSeparatedByString:@":"];
    NSNumber * channelKey = nil;
    if(myArray.count > 2)
    {
        channelKey = @([myArray[1] intValue]);
    }
    ALPushAssist *pushAssist = [ALPushAssist new];
    if([updateUI isEqualToNumber:[NSNumber numberWithInt:APP_STATE_ACTIVE]] && pushAssist.isContactVCOnTop)
    {
        NSLog(@"######## CONTACT VC : APP_STATE_ACTIVE #########");
        
        ALMessage *alMessage = [[ALMessage alloc] init];
        alMessage.message = alertValue;
        NSArray *myArray = [alMessage.message componentsSeparatedByString:@":"];
        
        if(myArray.count > 1)
        {
            alertValue = [NSString stringWithFormat:@"%@", myArray[1]];
        }
        else
        {
            alertValue = myArray[0];
        }
        
        alMessage.message = alertValue;
        alMessage.contactIds = contactId;
        alMessage.groupId = channelKey;
        
        if ((channelKey && [ALChannelService isChannelMuted:alMessage.groupId]) || ([alMessage isMsgHidden]))
        {
            return;
        }
        
        ALNotificationView * alNotification = [[ALNotificationView alloc] initWithAlMessage:alMessage
                                                                           withAlertMessage:alMessage.message];
        [alNotification nativeNotification:self];
    }
    else if([updateUI isEqualToNumber:[NSNumber numberWithInt:APP_STATE_INACTIVE]])
    {
        NSLog(@"######## CONTACT VC : APP_STATE_INACTIVE #########");
        ALNewContactsViewController * contactVC = self;
        ALMessagesViewController *msgVC = (ALMessagesViewController *)[self.navigationController.viewControllers objectAtIndex:0];
        
        if(channelKey)
        {
            msgVC.channelKey = channelKey;
        }
        else
        {
            msgVC.channelKey = nil;
        }
        
        [msgVC createDetailChatViewController:contactId];
        
        NSMutableArray * viewsArray = [NSMutableArray arrayWithArray:msgVC.navigationController.viewControllers];
        if ([viewsArray containsObject:contactVC])
        {
            [viewsArray removeObject:contactVC];
        }
        msgVC.navigationController.viewControllers = viewsArray;
    }
}

- (void)updateView
{
    [self.tabBarController.tabBar setHidden:YES];
    [self.segmentControl setSelectedSegmentIndex:0];
    [self.segmentControl setHidden:YES];
    
    BOOL groupCreation = ([self.forGroup isEqualToNumber:[NSNumber numberWithInt:GROUP_CREATION]]
                          || [self.forGroup isEqualToNumber:[NSNumber numberWithInt:BROADCAST_GROUP_CREATION]] );
    if (groupCreation)
    {
        self.contactsTableView.editing=YES;
        self.contactsTableView.allowsMultipleSelectionDuringEditing = YES;
        self.done = [[UIBarButtonItem alloc]
                     initWithTitle:NSLocalizedStringWithDefaultValue(@"doneText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Done" , @"")
                     style:UIBarButtonItemStylePlain
                     target:self
                     action:@selector(createNewGroup:)];
        
        self.navigationItem.rightBarButtonItem = self.done;
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden: NO];
    self.forGroup = [NSNumber numberWithInt:0];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"USER_DETAIL_OTHER_VC" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MQTT_APPLOZIC_01" object:nil];
}

-(void)updateUser:(NSNotification *)notifyObj
{
    ALUserDetail *userDetail = (ALUserDetail *)notifyObj.object;
    ALNewContactCell *newContactCell = [self getCell:userDetail.userId];
    if(newContactCell && self.selectedSegment == 0)
    {
        [newContactCell.contactPersonImageView sd_setImageWithURL:[NSURL URLWithString:userDetail.imageLink] placeholderImage:nil options:SDWebImageRefreshCached];
        newContactCell.contactPersonName.text = [userDetail getDisplayName];
    }
}

-(ALNewContactCell *)getCell:(NSString *)key
{
    int index = (int)[self.filteredContactList indexOfObjectPassingTest:^BOOL(id element, NSUInteger idx, BOOL *stop) {
        
        ALContact *contact = (ALContact *)element;
        if([contact.userId isEqualToString:key])
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    ALNewContactCell *contactCell = (ALNewContactCell *)[self.contactsTableView cellForRowAtIndexPath:path];
    
    return contactCell;
}

-(void)emptyConversationAlertLabel
{
    if(self.filteredContactList.count)
    {
        return;
    }
    
    self.emptyConversationText = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                           self.view.frame.origin.y + self.view.frame.size.height/2,
                                                                           self.view.frame.size.width, 30)];
    [self.view addSubview:self.emptyConversationText];
    
    [self setTextForEmpty];
    [self.emptyConversationText setTextAlignment:NSTextAlignmentCenter];
    [self.emptyConversationText setHidden:YES];
}

-(void)setTextForEmpty
{
    
    NSString *msgText = NSLocalizedStringWithDefaultValue(@"noContactFoundText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"No contact found" , @"");
    if(self.selectedSegment == 1)
    {
        msgText = NSLocalizedStringWithDefaultValue(@"noContactFoundText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"No group found" , @"");
    }
    [self.emptyConversationText setText:msgText];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.contactsTableView?1:0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = self.filteredContactList.count;
    if(self.selectedSegment == 1)
    {
        count = self.filteredContactList.count;
    }
    if(count == 0)
    {
        if(![self.activityIndicator isAnimating]){
            [self.emptyConversationText setHidden:NO];
            [self setTextForEmpty];
        }
    }
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *individualCellIdentifier = @"NewContactCell";
    ALNewContactCell *newContactCell = (ALNewContactCell *)[tableView dequeueReusableCellWithIdentifier:individualCellIdentifier];
    NSUInteger randomIndex = random()% [self.colors count];
    UILabel* nameIcon = (UILabel*)[newContactCell viewWithTag:101];
    [nameIcon setTextColor:[UIColor whiteColor]];
    [nameIcon setHidden:YES];
    [newContactCell.contactPersonImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil options:SDWebImageRefreshCached];
    newContactCell.contactPersonName.text = @"";
    [newContactCell.contactPersonImageView setHidden:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        newContactCell.contactPersonImageView.layer.cornerRadius = newContactCell.contactPersonImageView.frame.size.width/2;
        newContactCell.contactPersonImageView.layer.masksToBounds = YES;
    });
    
    [self.emptyConversationText setHidden:YES];
    [self.contactsTableView setHidden:NO];
    
    @try {
        
        switch (self.groupOrContacts.intValue)
        {
            case SHOW_CONTACTS:
            {
                ALContact *contact = (ALContact *)[self.filteredContactList objectAtIndex:indexPath.row];
                newContactCell.contactPersonName.text = [contact getDisplayName];
                
                
                if (contact)
                {
                    if (contact.contactImageUrl)
                    {
                        [newContactCell.contactPersonImageView sd_setImageWithURL:[NSURL URLWithString:contact.contactImageUrl] placeholderImage:[ALUtilityClass getImageFromFramworkBundle:@"ic_contact_picture_holo_light.png"] options:SDWebImageRefreshCached];
                        
                    }
                    else
                    {
                        [nameIcon setHidden:NO];
                        [newContactCell.contactPersonImageView setImage:[ALColorUtility imageWithSize:CGRectMake(0, 0, 55, 55)
                                                                                        WithHexString:self.colors[randomIndex]]];
                        [newContactCell.contactPersonImageView addSubview:nameIcon];
                        [nameIcon  setText:[ALColorUtility getAlphabetForProfileImage:[contact getDisplayName]]];
                    }
                    
                    if(self.forGroup.intValue == GROUP_ADDITION && [self.contactsInGroup containsObject:contact.userId])
                    {
                        newContactCell.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
                        newContactCell.selectionStyle = UITableViewCellSelectionStyleNone ;
                    }
                    else if((self.forGroup.intValue == GROUP_CREATION || self.forGroup.intValue == BROADCAST_GROUP_CREATION) && [contact.userId isEqualToString:[ALUserDefaultsHandler getUserId]]){
                        [self disableOrRemoveCell:newContactCell];
                    }
                    else
                    {
                        newContactCell.backgroundColor = [UIColor whiteColor];
                        newContactCell.selectionStyle = UITableViewCellSelectionStyleGray ;
                    }
                    
                    for (NSString * userID in  self.groupMembers) {
                        if([userID isEqualToString:contact.userId]){
                            
                            
                            [self.contactsTableView selectRowAtIndexPath:indexPath
                                                                animated:YES
                                                          scrollPosition:UITableViewScrollPositionNone];
                            [self tableView:self.contactsTableView didSelectRowAtIndexPath:indexPath];
                            
                            NSLog(@"SELECTED:%@",contact.userId);
                            
                        }else{
                            NSLog(@"NOT SELECTED :%@",contact.userId);
                        }
                    }
                }
            }break;
            case SHOW_GROUP:
            {
                if(self.filteredContactList.count)
                {
                    ALChannel * channel = (ALChannel *)[self.filteredContactList objectAtIndex:indexPath.row];
                    newContactCell.contactPersonName.text = [channel name];
                    [newContactCell.contactPersonImageView setImage:[UIImage imageNamed:@"applozic_group_icon.png"]];
                    NSURL * imageUrl = [NSURL URLWithString:channel.channelImageURL];
                    if(imageUrl.path.length)
                    {
                        [newContactCell.contactPersonImageView sd_setImageWithURL:imageUrl placeholderImage:nil options:SDWebImageRefreshCached];
                    }
                    [nameIcon setHidden:YES];
                }
                else
                {
                    [self.contactsTableView setHidden:YES];
                    [self.emptyConversationText setHidden:NO];
                    [self setTextForEmpty];
                }
            }break;
            default:
                break;
        }
        
    } @catch (NSException *exception) {
        
        NSLog(@"RAISED_EXP :: %@",exception.description);
    }
    
    
    
    return newContactCell;
}
-(void)disableOrRemoveCell:(ALNewContactCell*)contactCell{
    contactCell.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
    [contactCell setUserInteractionEnabled:NO];
    
}

-(void)maskOutCell:(ALNewContactCell*)contactCell{
    contactCell.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
    contactCell.selectionStyle = UITableViewCellSelectionStyleNone ;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.forGroup.intValue)
    {
        case GROUP_CREATION:
        {
            ALContact *contact = [self.filteredContactList objectAtIndex:indexPath.row];
            [self.groupMembers addObject:contact.userId];
        }break;
        case BROADCAST_GROUP_CREATION:
        {
            ALContact *contact = [self.filteredContactList objectAtIndex:indexPath.row];
            [self.groupMembers addObject:contact.userId];
        }break;
        case GROUP_ADDITION:
        {
            if(![self checkInternetConnectivity:tableView andIndexPath:indexPath])
            {
                return;
            }
            
            ALContact * contact = self.filteredContactList[indexPath.row];
            
            if([self.contactsInGroup containsObject:contact.userId])
            {
                return;
            }
            
            [self turnUserInteractivityForNavigationAndTableView:NO];
            [delegate addNewMembertoGroup:contact withCompletion:^(NSError *error, ALAPIResponse *response) {
                
                if(error)
                {
                    [TSMessage showNotificationWithTitle:NSLocalizedStringWithDefaultValue(@"unableToAddMemberText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unable to add new member" , @"") type:TSMessageNotificationTypeError];

                    [self setUserInteraction:YES];
                }
                else
                {
                    
                    [self backToDetailView];
                    [self turnUserInteractivityForNavigationAndTableView:YES];
                    [self setUserInteraction:YES];
                }
                
            }];
        }break;
        case IMAGE_SHARE:{
            // TODO : Send Image
            /* ALContact * contact = self.filteredContactList[indexPath.row];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_IMAGE" object:contact];
             */
        }break;
        case LAUNCH_GROUP_OF_TWO:
        {
            if(self.selectedSegment == 0)
            {
                ALContact *contact = [self.filteredContactList objectAtIndex:indexPath.row];
                [self initiateGroupOfTwoChat:self.parentChannel andUser:contact];
            }
            else
            {
                ALChannel *channel = [self.filteredContactList objectAtIndex:indexPath.row];
                [self launchChatForContact:nil withChannelKey:channel.key];
            }
        }break;
        default:
        { //DEFAULT : Launch contact!
            NSNumber * key = nil;
            NSString * userId = @"";
            if(self.selectedSegment == 0)
            {
                ALContact * selectedContact = self.filteredContactList[indexPath.row];
                userId = selectedContact.userId;
            }
            else
            {
                ALChannel * selectedChannel = self.filteredContactList[indexPath.row];
                key = selectedChannel.key;
                userId = nil;
            }
            [self launchChatForContact:userId withChannelKey:key];
        }
            
    }
}

-(void)setUserInteraction:(BOOL)flag
{
    [self.contactsTableView setUserInteractionEnabled:flag];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.forGroup isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        ALContact * contact = [self.filteredContactList objectAtIndex:indexPath.row];
        [self.groupMembers removeObject:contact.userId];
    }
}

-(BOOL)checkInternetConnectivity:(UITableView*)tableView andIndexPath:(NSIndexPath *)indexPath
{
    if(![ALDataNetworkConnection checkDataNetworkAvailable])
    {
        [[self activityIndicator] stopAnimating];
        ALNotificationView * notification = [ALNotificationView new];
        [notification noDataConnectionNotificationView];
        if(tableView)
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        return NO;
    }
    return YES;
}

-(void) fetchConversationsGroupByContactId
{
    
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    
    // get all unique contacts
    
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CONTACT"];
    
    [theRequest setReturnsDistinctResults:YES];
    NSPredicate * contactFilterPredicate;
    NSMutableArray * filterArray =  [ALApplozicSettings getContactTypeToFilter];
    
    if(filterArray){
        contactFilterPredicate = [NSPredicate predicateWithFormat:@"contactType IN %@", filterArray];
    }
    
    if(![ALUserDefaultsHandler getLoginUserConatactVisibility]){
        NSPredicate* predicate=  [NSPredicate predicateWithFormat:@"userId!=%@ AND deletedAtTime == nil",[ALUserDefaultsHandler getUserId]];
        if(contactFilterPredicate){
            contactFilterPredicate =[NSCompoundPredicate andPredicateWithSubpredicates:@[contactFilterPredicate, predicate]];
        }else{
            contactFilterPredicate =predicate;
        }
    }
    
    if(contactFilterPredicate){
        [theRequest setPredicate:contactFilterPredicate];
    }
    
    NSArray * theArray = [theDbHandler.managedObjectContext executeFetchRequest:theRequest error:nil];
    
    for (DB_CONTACT *dbContact in theArray)
    {
        
        ALContact *contact = [[ALContact alloc] init];
        
        contact.userId = dbContact.userId;
        contact.fullName = dbContact.fullName;
        contact.contactNumber = dbContact.contactNumber;
        contact.displayName = dbContact.displayName;
        contact.contactImageUrl = dbContact.contactImageUrl;
        contact.email = dbContact.email;
        contact.localImageResourceName = dbContact.localImageResourceName;
        contact.contactType = dbContact.contactType;
        
        
        [self.contactList addObject:contact];
    }
    
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
    self.filteredContactList = [NSMutableArray arrayWithArray:[self.contactList sortedArrayUsingDescriptors:descriptors]];
    [self.contactList removeAllObjects];
    self.contactList = [NSMutableArray arrayWithArray:self.filteredContactList];
    
    [[self activityIndicator] stopAnimating];
    [self.contactsTableView reloadData];
    
}

#pragma mark orientation method
//=============================
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self handleFrameForOrientation];
    
}

-(void)handleFrameForOrientation
{
    UIInterfaceOrientation toOrientation   = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone &&
        (toOrientation == UIInterfaceOrientationLandscapeLeft || toOrientation == UIInterfaceOrientationLandscapeRight))
    {
        self.mTableViewTopConstraint.constant = DEFAULT_TOP_LANDSCAPE_CONSTANT;
    }
    else
    {
        self.mTableViewTopConstraint.constant = DEFAULT_TOP_PORTRAIT_CONSTANT;
    }
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // Do the search...
    ALChatViewController * theVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    theVC.contactIds = searchBar.text;
}

#pragma mark - Search Bar Delegate Methods -
//========================================
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.stopSearchText = searchText;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getSerachResult:searchText];
    });
    
}

-(void)getSerachResult:(NSString*)searchText
{
    
    if (searchText.length != 0)
    {
        NSPredicate * searchPredicate;
        
        if(self.selectedSegment == 0)
        {
            searchPredicate = [NSPredicate predicateWithFormat:@"email CONTAINS[cd] %@ OR userId CONTAINS[cd] %@ OR contactNumber CONTAINS[cd] %@ OR fullName CONTAINS[cd] %@ OR displayName CONTAINS[cd] %@", searchText, searchText, searchText, searchText,searchText];
        }
        else
        {
            searchPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
        }
        
        if(self.lastSearchLength > searchText.length)
        {
            NSArray * searchResults;
            if(self.selectedSegment == 0)
            {
                searchResults = [self.contactList filteredArrayUsingPredicate:searchPredicate];
            }
            else
            {
                searchResults = [self.alChannelsList filteredArrayUsingPredicate:searchPredicate];
            }
            [self.filteredContactList removeAllObjects];
            [self.filteredContactList addObjectsFromArray:searchResults];
        }
        else
        {
            NSArray *searchResults;
            if(self.selectedSegment == 0)
            {
                searchResults = [self.contactList filteredArrayUsingPredicate:searchPredicate];
            }
            else
            {
                searchResults = [self.alChannelsList filteredArrayUsingPredicate:searchPredicate];
            }
            [self.filteredContactList removeAllObjects];
            [self.filteredContactList addObjectsFromArray:searchResults];
        }
    }
    else
    {
        [self.filteredContactList removeAllObjects];
        if(self.selectedSegment == 0)
        {
            [self.filteredContactList addObjectsFromArray:self.contactList];
        }
        else
        {
            [self.filteredContactList addObjectsFromArray:self.alChannelsList];
        }
        
    }
    
    self.lastSearchLength = searchText.length;
    [self.contactsTableView reloadData];
}


-(void)back:(id)sender
{
    if(self.directContactVCLaunch || self.directContactVCLaunchForForward)
    {
        [self  dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        UIViewController * viewControllersFromStack = [self.navigationController popViewControllerAnimated:YES];
        if(!viewControllersFromStack){
            self.tabBarController.selectedIndex = 0;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

-(void)launchChatForContact:(NSString *)contactId  withChannelKey:(NSNumber*)channelKey
{
    
    
    if(self.directContactVCLaunchForForward)  // IF DIRECT CONTACT VIEW LAUNCH FROM ALCHATLAUNCHER
    {
        
        switch (self.selectedSegment)
        {
            case 0:
            {
                ALContactService * contactService = [ALContactService new];
                if(![contactService isUserDeleted:contactId]){
                    self.alMessage.contactIds = contactId;
                    self.alMessage.to = contactId;
                    self.alMessage.groupId = nil;
                    [self.forwardDelegate proccessReloadAndForwardMessage:self.alMessage];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    NSLog(@"User is deleted !!");
                    
                }
                
            }
                break;
            case 1:
            {
                ALChannelService * channelService = [ALChannelService new];
                if(![channelService isChannelLeft:channelKey] && ![ALChannelService isChannelDeleted:channelKey]){
                    self.alMessage.contactIds = nil;
                    self.alMessage.groupId = channelKey;
                    [self.forwardDelegate proccessReloadAndForwardMessage:self.alMessage];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    NSLog(@"Group is deleted or your not in this group !!");
                }
                
            }
                break;
            default:
                break;
        }
        
        return;
    }else if(self.directContactVCLaunch)  // IF DIRECT CONTACT VIEW LAUNCH FROM ALCHATLAUNCHER
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                             bundle:[NSBundle bundleForClass:ALChatViewController.class]];
        
        ALChatViewController *chatView = (ALChatViewController *) [storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
        chatView.alMessage = self.alMessage;
        chatView.individualLaunch = YES;
        
        switch (self.selectedSegment)
        {
                
            case 0:
            {
                chatView.channelKey = nil;
                chatView.contactIds = contactId;
                [self.navigationController pushViewController:chatView animated:YES];
                [self removeFromParentViewController];
            }
                break;
            case 1:
            {
                chatView.channelKey = channelKey;
                chatView.contactIds = contactId;
                [self.navigationController pushViewController:chatView animated:YES];
                [self removeFromParentViewController];
                
            }
                break;
            default:
                break;
        }
        return;
    }
    
    BOOL isFoundInBackStack = false;
    NSMutableArray *viewControllersFromStack = [self.navigationController.viewControllers mutableCopy];
    for (UIViewController *currentVC in viewControllersFromStack)
    {
        NSLog(@"IN_NAVIGATION-BAR ::VCs : %@",currentVC.description);
        if ([currentVC isKindOfClass:[ALMessagesViewController class]])
        {
            [(ALMessagesViewController*)currentVC setChannelKey:channelKey];
            NSLog(@"IN_NAVIGATION-BAR :: found in backStack .....launching from current vc");
            [(ALMessagesViewController*) currentVC createDetailChatViewController:contactId];
            isFoundInBackStack = true;
        }
    }
    
    if(!isFoundInBackStack)
    {
        NSLog(@"NOT_FOUND_IN_BACKSTACK_OF_NAVIAGTION");
        self.tabBarController.selectedIndex=0;
        UINavigationController * uicontroller =  self.tabBarController.selectedViewController;
        NSMutableArray *viewControllersFromStack = [uicontroller.childViewControllers mutableCopy];
        
        for (UIViewController *currentVC in viewControllersFromStack)
        {
            if ([currentVC isKindOfClass:[ALMessagesViewController class]])
            {
                [(ALMessagesViewController*)currentVC setChannelKey:channelKey];
                NSLog(@"IN_TAB-BAR :: found in backStack .....launching from current vc");
                [(ALMessagesViewController*) currentVC createDetailChatViewController:contactId];
                isFoundInBackStack = true;
            }
        }
    }
    else
    {
        //remove ALNewContactsViewController from back stack...
        
        viewControllersFromStack = [self.navigationController.viewControllers mutableCopy];
        if(viewControllersFromStack.count >=2 &&
           [[viewControllersFromStack objectAtIndex:viewControllersFromStack.count -2] isKindOfClass:[ALNewContactsViewController class]])
        {
            [viewControllersFromStack removeObjectAtIndex:viewControllersFromStack.count -2];
            self.navigationController.viewControllers = viewControllersFromStack;
        }
    }
}

-(UIView *)setCustomBackButton:(NSString *)text
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [ALUtilityClass getImageFromFramworkBundle:@"bbb.png"]];
    [imageView setFrame:CGRectMake(-10, 0, 30, 30)];
    [imageView setTintColor:[UIColor whiteColor]];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width - 5, imageView.frame.origin.y + 5 , @"back".length, 15)];
    [label setTextColor: [ALApplozicSettings getColorForNavigationItem]];
    [label setText:text];
    [label sizeToFit];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width + label.frame.size.width, imageView.frame.size.height)];
    view.bounds=CGRectMake(view.bounds.origin.x+8, view.bounds.origin.y-1, view.bounds.size.width, view.bounds.size.height);
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        view.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        label.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }
    [view addSubview:imageView];
    [view addSubview:label];
    
    UIButton *button=[[UIButton alloc] initWithFrame:view.frame];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    return view;
    
}

#pragma mark- Segment Control
//===========================
- (IBAction)segmentControlAction:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    self.selectedSegment = segmentedControl.selectedSegmentIndex;
    [self.filteredContactList removeAllObjects];
    
    if (self.selectedSegment == 0)
    {
        //toggle the Contacts view to be visible
        self.groupOrContacts = [NSNumber numberWithInt:SHOW_CONTACTS];
        self.filteredContactList = [NSMutableArray arrayWithArray: self.contactList];
    }
    else
    {
        //toggle the Group view to be visible
        self.groupOrContacts = [NSNumber numberWithInt:SHOW_GROUP];
        self.filteredContactList = [NSMutableArray arrayWithArray: self.alChannelsList];
    }
    [self.contactsTableView reloadData];
}

#pragma mark - Create group method
//================================
-(void)createNewGroup:(id)sender
{
    if(![self checkInternetConnectivity:nil andIndexPath:nil]) {
        return;
    }
    
    BOOL isForBroadCast = [self.forGroup isEqualToNumber:[NSNumber numberWithInt:BROADCAST_GROUP_CREATION]];
    
    [self turnUserInteractivityForNavigationAndTableView:NO];
    //check whether at least two memebers selected
    if(self.groupMembers.count < 2 && !isForBroadCast)
    {
        
        [self turnUserInteractivityForNavigationAndTableView:YES];
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedStringWithDefaultValue(@"groupMembersTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Group Members" , @"")
                                              message:NSLocalizedStringWithDefaultValue(@"selectMembersText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Please select minimum two members" , @"")
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [ALUtilityClass setAlertControllerFrame:alertController andViewController:self];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringWithDefaultValue(@"okText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"OK", @"")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
        
    }
    
    //Server Call
    self.creatingChannel = [[ALChannelService alloc] init];
    NSMutableArray * memberList = [NSMutableArray arrayWithArray:self.groupMembers.allObjects];
    if([ALApplozicSettings getSubGroupLaunchFlag])
    {
        [self.creatingChannel createChannel:self.groupName andParentChannelKey:self.parentChannel.key orClientChannelKey:nil
                             andMembersList:memberList andImageLink:self.groupImageURL channelType:PUBLIC
                                andMetaData:nil withCompletion:^(ALChannel *alChannel, NSError *error) {
                                    
                                    if(alChannel)
                                    {
                                        //Updating view, popping to MessageList View
                                        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                                        
                                        for (UIViewController *aViewController in allViewControllers)
                                        {
                                            if ([aViewController isKindOfClass:[ALMessagesViewController class]])
                                            {
                                                ALMessagesViewController * messageVC = (ALMessagesViewController *)aViewController;
                                                [messageVC insertChannelMessage:alChannel.key];
                                                [self.navigationController popToViewController:aViewController animated:YES];
                                            }
                                        }
                                    }
                                    else
                                    {
                                        
                                        [TSMessage showNotificationWithTitle: NSLocalizedStringWithDefaultValue(@"unableToCreateGroupText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unable to create group. Please try again", @"") type:TSMessageNotificationTypeError];
                                        [self turnUserInteractivityForNavigationAndTableView:YES];
                                    }
                                    
                                    [[self activityIndicator] stopAnimating];
                                }];
    }
    else if (isForBroadCast)
    {
        [self.creatingChannel createBroadcastChannelWithMembersList:memberList
                                                        andMetaData:nil
                                                     withCompletion:^(ALChannel *alChannel, NSError *error) {
                                                         if(alChannel)
                                                         {
                                                             NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                                                             
                                                             for (UIViewController *aViewController in allViewControllers)
                                                             {
                                                                 if ([ALPushAssist isViewObjIsMsgVC:aViewController])
                                                                 {
                                                                     ALMessagesViewController * messageVC = (ALMessagesViewController *)aViewController;
                                                                     [messageVC insertChannelMessage:alChannel.key];
                                                                     [self.navigationController popToViewController:aViewController animated:YES];
                                                                 }
                                                                 else if ([ALPushAssist isViewObjIsMsgContainerVC:aViewController])
                                                                 {
                                                                     ALSubViewController * msgSubView = aViewController;
                                                                     [msgSubView.msgView insertChannelMessage:alChannel.key];
                                                                     [self.navigationController popToViewController:aViewController animated:YES];
                                                                 }
                                                             }
                                                         }
                                                         else
                                                         {
                                                             [TSMessage showNotificationWithTitle: NSLocalizedStringWithDefaultValue(@"unableToCreateGroupText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unable to create group. Please try again", @"")  type:TSMessageNotificationTypeError];
                                                             [self turnUserInteractivityForNavigationAndTableView:YES];
                                                         }
                                                         
                                                         [[self activityIndicator] stopAnimating];
                                                     }];
    }
    else
    {
        NSInteger channelType = PUBLIC;
        if([ALApplozicSettings getDefaultGroupType]) {
            channelType = [ALApplozicSettings getDefaultGroupType];
        }
        [self.creatingChannel createChannel:self.groupName orClientChannelKey:nil andMembersList:memberList andImageLink:self.groupImageURL channelType:channelType
                andMetaData:nil withCompletion:^(ALChannel *alChannel, NSError *error) {
                                 if(alChannel)
                                 {
                                     //Updating view, popping to MessageList View
                                     NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                                     
                                     for (UIViewController *aViewController in allViewControllers)
                                     {
                                         if ([ALPushAssist isViewObjIsMsgVC:aViewController])
                                         {
                                             ALMessagesViewController * messageVC = (ALMessagesViewController *)aViewController;
                                             [messageVC insertChannelMessage:alChannel.key];
                                             [self.navigationController popToViewController:aViewController animated:YES];
                                         }
                                         else if ([ALPushAssist isViewObjIsMsgContainerVC:aViewController])
                                         {
                                             ALSubViewController * msgSubView = aViewController;
                                             [msgSubView.msgView insertChannelMessage:alChannel.key];
                                             [self.navigationController popToViewController:aViewController animated:YES];
                                         }
                                     }
                                 }
                                 else
                                 {
                                     [TSMessage showNotificationWithTitle: NSLocalizedStringWithDefaultValue(@"unableToCreateGroupText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unable to create group. Please try again", @"") type:TSMessageNotificationTypeError];
                                     [self turnUserInteractivityForNavigationAndTableView:YES];
                                 }
                                 
                                 [[self activityIndicator] stopAnimating];
                                 
                             }];
    }
    if(![ALDataNetworkConnection checkDataNetworkAvailable])
    {
        [self turnUserInteractivityForNavigationAndTableView:YES];
    }
}


-(void)turnUserInteractivityForNavigationAndTableView:(BOOL)option
{
    [self.contactsTableView setUserInteractionEnabled:option];
    [[[self navigationController] navigationBar] setUserInteractionEnabled:option];
    [[self searchBar] setUserInteractionEnabled:option];
    [[self searchBar] resignFirstResponder];
    if(option == YES){
        [[self activityIndicator] stopAnimating];
    }
    else{
        [[self activityIndicator] startAnimating];
    }
    
}


# pragma mark - Dummy group message method
//========================================
-(void) addDummyMessage:(NSNumber *)channelKey
{
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc]init];
    
    ALMessage * theMessage = [ALMessage new];
    theMessage.createdAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
    theMessage.deviceKey = [ALUserDefaultsHandler getDeviceKeyString];
    theMessage.sendToDevice = NO;
    theMessage.shared = NO;
    theMessage.fileMeta = nil;
    theMessage.key = @"welcome-message-temp-key-string";
    theMessage.fileMetaKey = @"";//4
    theMessage.contentType = ALMESSAGE_CONTENT_DEFAULT;
    theMessage.type = @"101";
    theMessage.message = @"You have created a new group, Say Hi to members :)";
    theMessage.groupId = channelKey;
    theMessage.status = [NSNumber numberWithInt:DELIVERED_AND_READ];
    theMessage.sentToServer = TRUE;
    
    //UI update...
    NSMutableArray* updateArr=[[NSMutableArray alloc] initWithObjects:theMessage, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:updateArr];
    
    //db insertion..
    [messageDBService createMessageEntityForDBInsertionWithMessage:theMessage];
    [theDBHandler.managedObjectContext save:nil];
    
}

#pragma mar - Member Addition to group
//====================================
-(void)backToDetailView{
    
    self.forGroup = [NSNumber numberWithInt:0];
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[ALGroupDetailViewController class]]) {
            [self.navigationController popToViewController:aViewController animated:YES];
        }
    }
}

-(void)processFilterListWithLastSeen
{
    ALUserService * userService = [ALUserService new];
    [userService fetchOnlineContactFromServer:^(NSMutableArray * array, NSError * error) {
        
        if(error)
        {
            [self.activityIndicator stopAnimating];
            [self.emptyConversationText setHidden:NO];
            [self.emptyConversationText setText: NSLocalizedStringWithDefaultValue(@"unableToFetachContacts", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unable to fetch contacts", @"") ];
            return;
        }
        
        NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastSeenAt" ascending:NO];
        NSArray * descriptors = [NSArray arrayWithObject:sortDescriptor];
        self.filteredContactList = [NSMutableArray arrayWithArray:[array sortedArrayUsingDescriptors:descriptors]];
        NSLog(@"ARRAY_COUNT : %lu",(unsigned long)self.filteredContactList.count);
        [[self activityIndicator] stopAnimating];
        [self.contactsTableView reloadData];
        [self emptyConversationAlertLabel];
        
    }];
}

-(void)launchProcessForSubgroups
{
    ALContactService *contactService = [ALContactService new];
    ALChannelService *channelService = [ALChannelService new];
    NSMutableSet * allMemberSet = [NSMutableSet new];
    NSMutableArray * allMemberArray = [NSMutableArray new];
    [self.childChannels addObject:self.parentChannel];
    self.alChannelsList = [NSMutableArray new];
    
    for(ALChannel *childChannel in self.childChannels)
    {
        if(childChannel.type != GROUP_OF_TWO)
        {
            NSMutableArray *childArray = [channelService getListOfAllUsersInChannel:childChannel.key];
            [allMemberArray addObjectsFromArray:childArray];
            if([childArray containsObject:[ALUserDefaultsHandler getUserId]])
            {
                [self.alChannelsList addObject:childChannel];
            }
        }
    }
    
    [self.alChannelsList removeObject:self.parentChannel];
    
    allMemberSet = [NSMutableSet setWithArray:[allMemberArray mutableCopy]];
    
    NSMutableArray * contactList = [NSMutableArray new];
    
    for(NSString * userId in allMemberSet)
    {
        ALContact *contact = [contactService loadContactByKey:@"userId" value:userId];
        if(![contact.userId isEqualToString:[ALUserDefaultsHandler getUserId]])
        {
            [contactList addObject:contact];
        }
    }
    
    self.contactList = [NSMutableArray arrayWithArray:contactList];
    
    self.filteredContactList = [NSMutableArray arrayWithArray:self.contactList];
    [[self activityIndicator] stopAnimating];
    [self.contactsTableView reloadData];
    
}

-(void)initiateGroupOfTwoChat:(ALChannel *)parentChannel andUser:(ALContact *)alContact
{
    ALChannelService * channelService = [ALChannelService new];
    ALContactService *contactService = [ALContactService new];
    ALContact *loginContact = [contactService loadContactByKey:@"userId" value:[ALUserDefaultsHandler getUserId]];
    NSMutableArray * userList = [NSMutableArray arrayWithObjects:alContact.userId, loginContact.userId, nil];
    
    // ALSO SORT USERS
    NSString *clientChannelKey = [NSString stringWithFormat:@"%@:%@:%@",parentChannel.key, loginContact.userId, alContact.userId];
    NSString *channelName = [NSString stringWithFormat:@"GROUP:%@:%@",[loginContact getDisplayName],[alContact getDisplayName]];
    NSComparisonResult result = [loginContact.userId compare:alContact.userId];
    
    if(result == NSOrderedDescending)
    {
        channelName = [NSString stringWithFormat:@"GROUP:%@:%@",[alContact getDisplayName],[loginContact getDisplayName]];
        clientChannelKey = [NSString stringWithFormat:@"%@:%@:%@",parentChannel.key, alContact.userId, loginContact.userId];
    }
    
    //CHECK IF CONVERSATION ALREADY THERE
    ALChannel * previousChannel = [channelService fetchChannelWithClientChannelKey:clientChannelKey];
    if(!previousChannel)
    {
        [channelService createChannel:channelName andParentChannelKey:parentChannel.key orClientChannelKey:clientChannelKey andMembersList:userList
                         andImageLink:nil channelType:GROUP_OF_TWO andMetaData:nil withCompletion:^(ALChannel *alChannel, NSError *error) {
                             
                             NSLog(@"CHANNEL RESPONSE GET :: %@",alChannel.name);
                             if(alChannel)
                             {
                                 [self chatLaunchForGroupOfTwo:alChannel andUser:alContact];
                             }
                         }];
    }
    else
    {
        NSLog(@"GROUP FOUND : %@",previousChannel.clientChannelKey);
        [self chatLaunchForGroupOfTwo:previousChannel andUser:alContact];
    }
}

-(void)chatLaunchForGroupOfTwo:(ALChannel *)channel andUser:(ALContact *)alContact
{
    NSMutableArray *viewControllersFromStack = [self.navigationController.viewControllers mutableCopy];
    for (UIViewController *currentVC in viewControllersFromStack)
    {
        NSLog(@"CLASS NAME : %@",currentVC.description);
        if ([currentVC isKindOfClass:[ALMessagesViewController class]])
        {
            // LAUNCH VIA BACK STACK FROM MSG VC
            ALMessagesViewController * msgViewObject = (ALMessagesViewController *)currentVC;
            msgViewObject.channelKey = channel.key;
            [msgViewObject createDetailChatViewController:alContact.userId];
        }
    }
    viewControllersFromStack = [self.navigationController.viewControllers mutableCopy];
    if(viewControllersFromStack.count >=2 &&
       [[viewControllersFromStack objectAtIndex:viewControllersFromStack.count -2] isKindOfClass:[ALNewContactsViewController class]])
    {
        [viewControllersFromStack removeObjectAtIndex:viewControllersFromStack.count -2];
        self.navigationController.viewControllers = viewControllersFromStack;
    }
}

//==============================================================================================================================================
#pragma mark - TABLE SCROLL DELEGATE METHOD
//==============================================================================================================================================

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(![ALUserDefaultsHandler isContactScrollingIsInProgress] && self.groupOrContacts.intValue == SHOW_CONTACTS && ![ALApplozicSettings isContactsGroupEnabled] ){
        NSLog(@"Contact scrolling ");
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.bounds;
        CGSize size = scrollView.contentSize;
        UIEdgeInsets inset = scrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        float reload_distance = 10;
        if(y > (h - reload_distance))
        {
            if([ALApplozicSettings getFilterContactsStatus])
            {
                [[self activityIndicator] startAnimating];
                [self proccessRegisteredContactsCall:YES];
            }
        }
    }
    
}


-(void)proccessRegisteredContactsCall:(BOOL)isRemoveobject{
    
    ALUserService * userService = [ALUserService new];
    [userService getListOfRegisteredUsersWithCompletion:^(NSError *error) {
        
        [self.searchBar setUserInteractionEnabled:YES];
        if(error)
        {
            [self.activityIndicator stopAnimating];
            [self.emptyConversationText setHidden:NO];
            [self.emptyConversationText setText: NSLocalizedStringWithDefaultValue(@"unableToFetachContacts", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unable to fetch contacts" , @"")];
            [self onlyGroupFetch];
            return;
        }
        
        if(_stopSearchText != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getSerachResult:_stopSearchText];
            });
            [[self activityIndicator] stopAnimating];
        }else{
            if(isRemoveobject){
                [ALUserDefaultsHandler setContactServerCallIsDone:YES];
                [self.filteredContactList removeAllObjects];
                [self.contactList removeAllObjects];
            }
            [self subProcessContactFetch];
            [[self activityIndicator] stopAnimating];
        }
        
        [ALUserDefaultsHandler setContactScrollingIsInProgress:NO];
        
    }];
}


-(void)proccessContactsGroupCall{
    
    [ALChannelService getMembersFromContactGroupOfType:[ALApplozicSettings getContactsGroupId] withGroupType:CONTACT_GROUP withCompletion:^(NSError *error, ALChannel *channel) {
        [self.searchBar setUserInteractionEnabled:YES];
        
        NSMutableArray * contactList = [NSMutableArray new];
        ALContactService *contactService = [ALContactService new];
        
        if(!error && channel != nil){
            for(NSString * userId in channel.membersId)
            {
                if(![userId isEqualToString:[ALUserDefaultsHandler getUserId]])
                {
                    ALContact *contact = [contactService loadContactByKey:@"userId" value:userId];
                    [contactList addObject:contact];
                }
            }
            [self.contactList removeAllObjects];
            self.contactList = [NSMutableArray arrayWithArray:contactList];
            self.filteredContactList = [NSMutableArray arrayWithArray:self.contactList];
            
            [[self activityIndicator] stopAnimating];
            [self.contactsTableView reloadData];
            
        }else{
            ALChannelService *channelService = [ALChannelService new];
            NSMutableArray * membersArray = [NSMutableArray new];
            
            membersArray = [channelService getListOfAllUsersInChannelByNameForContactsGroup:[ALApplozicSettings getContactsGroupId]];
            
            if(membersArray && membersArray.count >0){
                for(NSString * userId in membersArray)
                {
                    ALContact *contact = [contactService loadContactByKey:@"userId" value:userId];
                    [contactList addObject:contact];
                }
                
                [self.contactList removeAllObjects];
                self.contactList = [NSMutableArray arrayWithArray:contactList];
                self.filteredContactList = [NSMutableArray arrayWithArray:self.contactList];
                
                [[self activityIndicator] stopAnimating];
                [self.contactsTableView reloadData];
            }
        }
        [self onlyGroupFetch];
    }];
}

-(void)proccessContactsGroupList{
    
    [ALChannelService getMembersIdsForContactGroups:[ALApplozicSettings getContactGroupIdList] withCompletion:^(NSError *error, NSArray *membersArray) {
      [self.searchBar setUserInteractionEnabled:YES];
        
        NSMutableArray * contactList = [NSMutableArray new];
        ALContactService *contactService = [ALContactService new];
        
        if(!error && membersArray != nil){
            membersArray = [membersArray valueForKeyPath:@"@distinctUnionOfObjects.self"];
            for(NSString * userId in membersArray)
            {
                if(![userId isEqualToString:[ALUserDefaultsHandler getUserId]])
                {
                    ALContact *contact = [contactService loadContactByKey:@"userId" value:userId];
                    [contactList addObject:contact];
                }
            }
            [self.contactList removeAllObjects];
            self.contactList = [NSMutableArray arrayWithArray:contactList];
            self.filteredContactList = [NSMutableArray arrayWithArray:self.contactList];
            
            [[self activityIndicator] stopAnimating];
            [self.contactsTableView reloadData];
            
        }else{
            ALChannelService *channelService = [ALChannelService new];
            NSMutableArray * membersArray = [NSMutableArray new];

            for(NSString* channelId in [ALApplozicSettings getContactGroupIdList]) {
                NSMutableArray* members = [channelService getListOfAllUsersInChannelByNameForContactsGroup:channelId];
                [membersArray addObjectsFromArray: members];

            }
            if(membersArray && membersArray.count >0){
                membersArray = [membersArray valueForKeyPath:@"@distinctUnionOfObjects.self"];
                for(NSString * userId in membersArray)
                {
                    if(![userId isEqualToString:[ALUserDefaultsHandler getUserId] ]) {
                        ALContact *contact = [contactService loadContactByKey:@"userId" value:userId];
                        [contactList addObject:contact];
                    }
                }

                [self.contactList removeAllObjects];
                self.contactList = [NSMutableArray arrayWithArray:contactList];
                self.filteredContactList = [NSMutableArray arrayWithArray:self.contactList];

            }
            [[self activityIndicator] stopAnimating];
            [self.contactsTableView reloadData];
        }
        [self onlyGroupFetch];
        
    }];
}


@end
