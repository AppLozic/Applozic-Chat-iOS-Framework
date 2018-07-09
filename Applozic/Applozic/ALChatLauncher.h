//
//  ALChatLauncher.h
//  Applozic
//
//  Created by devashish on 21/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ALConversationProxy.h"
#import "ALMessage.h"

@protocol ALChatLauncherDelegate <NSObject>

+(void)handleCustomAction:(UIViewController *)chatView andWithMessage:(ALMessage *)alMessage;

@end

@interface ALChatLauncher : NSObject

@property (nonatomic, strong) id <ALChatLauncherDelegate> chatLauncherDelegate;
@property (nonatomic, assign) NSString * applicationId;
@property (nonatomic, strong) NSNumber * chatLauncherFLAG;

-(instancetype)initWithApplicationId:(NSString *) applicationId;

-(void)launchIndividualChat:(NSString *)userId withGroupId:(NSNumber*)groupID andViewControllerObject:(UIViewController *)viewController andWithText:(NSString *)text;

-(void)launchChatList:(NSString *)title andViewControllerObject:(UIViewController *)viewController;

-(void) launchContactList: (UIViewController *)uiViewController ;
-(void)registerForNotification;

-(void)launchIndividualChat:(NSString *)userId withGroupId:(NSNumber *)groupID withDisplayName:(NSString*)displayName andViewControllerObject:(UIViewController *)viewController andWithText:(NSString *)text;

-(void)launchIndividualContextChat:(ALConversationProxy *)alConversationProxy andViewControllerObject:(UIViewController *)viewController
                   userDisplayName:(NSString *)displayName andWithText:(NSString *)text;

-(void)launchChatListWithUserOrGroup:(NSString *)userId withChannel:(NSNumber*)channelKey andViewControllerObject:(UIViewController *)viewController;

-(void)launchChatListWithCustomNavigationBar:(UIViewController *)viewController;

-(void)launchChatListWithParentKey:(NSNumber *)parentKey andViewControllerObject:(UIViewController *)viewController;

-(void) launchContactScreenWithMessage:(ALMessage *)alMessage andFromViewController:(UIViewController*)viewController;

@end
