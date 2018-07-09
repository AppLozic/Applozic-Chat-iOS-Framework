//
//  ALPushAssist.m
//  Applozic
//
//  Created by Divjyot Singh on 07/01/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALPushAssist.h"

#import "ALPushNotificationService.h"
#import "ALMessageDBService.h"
#import "ALUserDetail.h"
#import "ALUserDefaultsHandler.h"
#import "ALChatViewController.h"
#import "ALMessagesViewController.h"
#import "ALAppLocalNotifications.h"
#import "ALGroupDetailViewController.h"
#import "ALNewContactsViewController.h"
#import "ALUserProfileVC.h"
#import "ALGroupCreationViewController.h"

@implementation ALPushAssist
// WHEN NON-APPLOZIC VIEWs OPENED
-(void)assist:(NSString*)notiMsg and :(NSMutableDictionary*)dict ofUser:(NSString*)userId{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showNotificationAndLaunchChat"
                                                             object:notiMsg
                                                           userInfo:dict];

}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:@"showNotificationAndLaunchChat"];
}


-(BOOL) isOurViewOnTop
{
    NSArray * VCList = [ALApplozicSettings getListOfViewControllers];
    if(VCList)
    {
        for (NSString * className in VCList)
        {
            if([self.topViewController isKindOfClass:NSClassFromString(className)])
            {
                return YES;
            }
        }
    }
    
    return ( [self isMessageViewOnTop]
            ||[self.topViewController isKindOfClass:[ALChatViewController class]]
            ||[self.topViewController isKindOfClass:[ALGroupDetailViewController class]]
            ||[self.topViewController isKindOfClass:[ALNewContactsViewController class]]
            ||[self.topViewController isKindOfClass:[ALUserProfileVC class]]
            ||[self isVOIPViewOnTop]
            ||[self isGroupUpdateVCOnTop]);
}

-(BOOL)isGroupUpdateVCOnTop{
    return ([self.topViewController isKindOfClass:[ALGroupCreationViewController class]]);
}

-(BOOL)isUserProfileVCOnTop{
    return ([self.topViewController isKindOfClass:[ALUserProfileVC class]]);
}

-(BOOL)isContactVCOnTop{
    return ([self.topViewController isKindOfClass:[ALNewContactsViewController class]]);
}

-(BOOL)isMessageViewOnTop{
    return ([self.topViewController isKindOfClass:[ALMessagesViewController class]] || [self isMessageContainerOnTop]);
}

-(BOOL)isMessageContainerOnTop
{
    return ([self.topViewController isKindOfClass:NSClassFromString([ALApplozicSettings getMsgContainerVC])]);
}

-(BOOL)isChatViewOnTop{
    return ([self.topViewController isKindOfClass:[ALChatViewController class]]);
}

-(BOOL)isGroupDetailViewOnTop{
    return ([self.topViewController isKindOfClass:[ALGroupDetailViewController class]]);
}

-(BOOL)isVOIPViewOnTop
{
    NSLog(@"VOIP_VIEW : %@",self.topViewController);
    return ([self.topViewController isKindOfClass:NSClassFromString([ALApplozicSettings getAudioVideoClassName])]);
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
        
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
        
    } else if (rootViewController.presentedViewController) {
        
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
        
    } else {
        return rootViewController;
    }
}

+ (BOOL)isViewObjIsMsgVC:(UIViewController *)viewObj
{
    return ([viewObj isKindOfClass:[ALMessagesViewController class]]);
}

+ (BOOL)isViewObjIsMsgContainerVC:(UIViewController *)viewObj
{
    return ([viewObj isKindOfClass:NSClassFromString([ALApplozicSettings getMsgContainerVC])]);
}

@end
