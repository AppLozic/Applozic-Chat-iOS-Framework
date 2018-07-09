//
//  ALChatLauncher.m
//  Applozic
//
//  Created by devashish on 21/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//


#import "ALChatLauncher.h"
#import "ALUserDefaultsHandler.h"
#import "ALApplozicSettings.h"
#import "ALChatViewController.h"
#import "ALUser.h"
#import "ALRegisterUserClientService.h"
#import "ALMessageClientService.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessagesViewController.h"
#import "ALUserService.h"

@interface ALChatLauncher ()<ALChatViewControllerDelegate, ALMessagesViewDelegate>

@end

@implementation ALChatLauncher


- (instancetype)initWithApplicationId:(NSString *) applicationId;
{
    self = [super init];
    if (self)
    {
        self.applicationId = applicationId;
    }
    return self;
}

/**
 * Get navigation controller to launch depend on settings.
 **/

- (UINavigationController *)createNavigationControllerForVC:(UIViewController *)vc
{
    NSString * className = [ALApplozicSettings getCustomNavigationControllerClassName];
    if (![className isKindOfClass:[NSString class]]) className = @"UINavigationController";
    UINavigationController * navC = [(UINavigationController *)[NSClassFromString(className) alloc] initWithRootViewController:vc];
    return navC;
}

-(void)launchIndividualChat:(NSString *)userId withGroupId:(NSNumber*)groupID
    andViewControllerObject:(UIViewController *)viewController andWithText:(NSString *)text
{
    self.chatLauncherFLAG = [NSNumber numberWithInt:1];
    
    if(groupID){
        [self launchIndividualChatForGroup:userId withGroupId:groupID withDisplayName:nil andViewControllerObject:viewController andWithText:text];
    }else{
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
        
        ALChatViewController * chatView = (ALChatViewController *) [storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
        
        chatView.channelKey = groupID;
        chatView.contactIds = userId;
        chatView.text = text;
        chatView.individualLaunch = YES;
        chatView.chatViewDelegate = self;
        NSLog(@"CALLED_VIA_NOTIFICATION");
        
        UINavigationController * conversationViewNavController = [self createNavigationControllerForVC:chatView];
        conversationViewNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [viewController presentViewController:conversationViewNavController animated:YES completion:nil];
    }
}


-(void)launchIndividualChat:(NSString *)userId withGroupId:(NSNumber*)groupID
            withDisplayName:(NSString*)displayName
    andViewControllerObject:(UIViewController *)viewController andWithText:(NSString *)text
{
    
    if( groupID){
        [self launchIndividualChatForGroup:userId withGroupId:groupID withDisplayName:displayName andViewControllerObject:viewController andWithText:text];
    }else{
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                    
                                                             bundle:[NSBundle bundleForClass:ALChatViewController.class]];
        ALChatViewController *chatView = (ALChatViewController *) [storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
        chatView.channelKey = groupID;
        chatView.contactIds = userId;
        chatView.text = text;
        chatView.individualLaunch = YES;
        chatView.displayName = displayName;
        chatView.chatViewDelegate = self;
        
        UINavigationController *conversationViewNavController = [self createNavigationControllerForVC:chatView];;
        conversationViewNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve ;
        [viewController presentViewController:conversationViewNavController animated:YES completion:nil];
    }
}

-(void)launchIndividualChatForGroup:(NSString *)userId withGroupId:(NSNumber*)groupID
                    withDisplayName:(NSString*)displayName
            andViewControllerObject:(UIViewController *)viewController andWithText:(NSString *)text
{
    
    ALChannelService * channelService  =  [ALChannelService new];
    [channelService getChannelInformation:groupID orClientChannelKey:nil withCompletion:^(ALChannel *alChannel) {
                               //Channel information
                               
                               
       NSLog(@" alChannel ###%@ ", alChannel.name);
       UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                   
                                                            bundle:[NSBundle bundleForClass:ALChatViewController.class]];
       
       ALChatViewController *chatView = (ALChatViewController *) [storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
       
       chatView.channelKey = groupID;
       chatView.text = text;
       chatView.contactIds = userId;
       chatView.individualLaunch = YES;
       chatView.displayName = displayName;
       chatView.chatViewDelegate = self;
       
       UINavigationController *conversationViewNavController = [self createNavigationControllerForVC:chatView];;
       conversationViewNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve ;
       [viewController presentViewController:conversationViewNavController animated:YES completion:nil];
       
   }];
}


-(void)launchChatList:(NSString *)title andViewControllerObject:(UIViewController *)viewController
{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    UIViewController *theTabBar = [storyboard instantiateViewControllerWithIdentifier:@"messageTabBar"];
    
    //              To Lunch with different Animation...
    //theTabBar.modalTransitionStyle=UIModalTransitionStyleCrossDissolve ;
    
    UITabBarController * tabBAR = ((UITabBarController *)theTabBar);
    [self setCustomTabBarIcon:tabBAR];
    UINavigationController * navBAR = (UINavigationController *)[[tabBAR viewControllers] objectAtIndex:0];
    ALMessagesViewController * msgVC = (ALMessagesViewController *)[[navBAR viewControllers] objectAtIndex:0];
    msgVC.messagesViewDelegate = self;
    [viewController presentViewController:theTabBar animated:YES completion:nil];
    
}

-(void)registerForNotification
{
//    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:
//                                                                         (UIUserNotificationTypeSound |
//                                                                          UIUserNotificationTypeAlert |
//                                                                          UIUserNotificationTypeBadge) categories:nil]];
//    
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    UIUserNotificationSettings * APNSetting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:APNSetting];
}

-(void)launchContactList:(UIViewController *)uiViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    
    ALNewContactsViewController *contcatVC = (ALNewContactsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ALNewContactsViewController"];
    contcatVC.directContactVCLaunch = YES;
    UINavigationController *conversationViewNavController = [[UINavigationController alloc] initWithRootViewController:contcatVC];
    [uiViewController presentViewController:conversationViewNavController animated:YES completion:nil];
}

-(void)launchIndividualContextChat:(ALConversationProxy *)alConversationProxy andViewControllerObject:(UIViewController *)viewController
                   userDisplayName:(NSString *)displayName andWithText:(NSString *)text
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                         bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    
    ALChatViewController * contextChatView = (ALChatViewController*) [storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    
    contextChatView.displayName      = displayName;
    contextChatView.conversationId   = alConversationProxy.Id;
    
    if(alConversationProxy.userId != nil)
    {
        contextChatView.contactIds  = alConversationProxy.userId;
        contextChatView.channelKey   = nil;
    }
    else
    {
        contextChatView.channelKey   = alConversationProxy.groupId;
        contextChatView.contactIds  = nil;
    }
    contextChatView.text             = text;
    contextChatView.individualLaunch = YES;
    
    UINavigationController *conversationViewNavController = [self createNavigationControllerForVC:contextChatView];
    conversationViewNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [viewController presentViewController:conversationViewNavController animated:YES completion:nil];
}

-(void)launchChatListWithUserOrGroup:(NSString *)userId withChannel:(NSNumber*)channelKey andViewControllerObject:(UIViewController *)viewController
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALMessagesViewController *chatListView = (ALMessagesViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ALViewController"];
    UINavigationController *conversationViewNavController = [self createNavigationControllerForVC:chatListView];
    
    chatListView.userIdToLaunch = userId;
    chatListView.channelKey = channelKey;
    chatListView.messagesViewDelegate = self;
    
    [viewController presentViewController:conversationViewNavController animated:YES completion:nil];
    
}

//  WHEN FLOW IS FROM MESSAGEVIEW TO CHATVIEW
-(void)handleCustomActionFromMsgVC:(UIViewController *)chatView andWithMessage:(ALMessage *)alMessage
{
    id launcherDelegate = NSClassFromString([ALApplozicSettings getCustomClassName]);
    [launcherDelegate handleCustomAction:chatView andWithMessage:alMessage];
}

//  WHEN FLOW IS FROM DIRECT CHATVIEW
-(void)handleCustomActionFromChatVC:(UIViewController *)chatViewController andWithMessage:(ALMessage *)alMessage
{
    id launcherDelegate = NSClassFromString([ALApplozicSettings getCustomClassName]);
    [launcherDelegate handleCustomAction:chatViewController andWithMessage:alMessage];
}


-(void)launchChatListWithCustomNavigationBar:(UIViewController *)viewController
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    
    ALMessagesViewController *chatListView = (ALMessagesViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ALViewController"];
    
    NSString * className = [ALApplozicSettings getCustomNavigationControllerClassName];
    if (![className isKindOfClass:[NSString class]]) className = @"UINavigationController";
    
    UINavigationController * navC = [(UINavigationController *)[NSClassFromString(className) alloc] initWithRootViewController:chatListView];
    [viewController presentViewController:navC animated:YES completion:nil];
    
}

//==========================================================================================================================================
#pragma mark : ALMSGVC LAUNCH FOR SUB GROUPS
//==========================================================================================================================================

-(void)launchChatListWithParentKey:(NSNumber *)parentKey andViewControllerObject:(UIViewController *)viewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    UIViewController *theTabBar = [storyboard instantiateViewControllerWithIdentifier:@"messageTabBar"];
    
    UITabBarController * tabBAR = ((UITabBarController *)theTabBar);
    UINavigationController * navBAR = (UINavigationController *)[[tabBAR viewControllers] objectAtIndex:0];
    ALMessagesViewController * msgVC = (ALMessagesViewController *)[[navBAR viewControllers] objectAtIndex:0];
    msgVC.messagesViewDelegate = self;
    
    ALChannelService * channelService = [ALChannelService new];
    [channelService getChannelInformation:parentKey orClientChannelKey:nil withCompletion:^(ALChannel *alChannel3) {
        
        msgVC.parentGroupKey = parentKey;
        [msgVC intializeSubgroupMessages];
        [viewController presentViewController:theTabBar animated:YES completion:nil];
    }];
}

//==========================================================================================================================================
#pragma mark : CUSTOM TAB BAR ICON METHOD
//==========================================================================================================================================

-(void)setCustomTabBarIcon:(UITabBarController *)tabBAR
{
    UITabBarItem *item1 = [tabBAR.tabBar.items objectAtIndex:0];
    [item1 setTitle:[ALApplozicSettings getChatListTabTitle]];
    [item1 setImage:[ALApplozicSettings getChatListTabIcon]];
    
    UITabBarItem *item2 = [tabBAR.tabBar.items objectAtIndex:1];
    [item2 setTitle:[ALApplozicSettings getProfileTabTitle]];
    [item2 setImage:[ALApplozicSettings getProfileTabIcon]];
}

//============================================
// launching contact screen with message
//============================================

-(void)launchContactScreenWithMessage:(ALMessage *)alMessage andFromViewController:(UIViewController *)viewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALNewContactsViewController *contactVC = (ALNewContactsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ALNewContactsViewController"];
    contactVC.directContactVCLaunch = YES;
    contactVC.alMessage = alMessage;
    UINavigationController *conversationViewNavController = [[UINavigationController alloc] initWithRootViewController:contactVC];
    [viewController presentViewController:conversationViewNavController animated:YES completion:nil];
}

@end

