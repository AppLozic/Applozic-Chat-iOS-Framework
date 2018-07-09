//
//  ALPushAssist.h
//  Applozic
//
//  Created by Divjyot Singh on 07/01/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALChatLauncher.h"


@interface ALPushAssist : NSObject

@property(nonatomic, readonly, strong) UIViewController *topViewController;

@property(nonatomic,strong) ALChatLauncher * chatLauncher;

-(void)assist:(NSString*)notiMsg and :(NSMutableDictionary*)dict ofUser:(NSString*)userId;
- (UIViewController*)topViewController ;
-(BOOL)isOurViewOnTop;
-(BOOL)isMessageViewOnTop;
-(BOOL)isChatViewOnTop;
-(BOOL)isGroupDetailViewOnTop;
-(BOOL)isContactVCOnTop;
-(BOOL)isMessageContainerOnTop;
-(BOOL)isUserProfileVCOnTop;
-(BOOL)isVOIPViewOnTop;
-(BOOL)isGroupUpdateVCOnTop;

+ (BOOL)isViewObjIsMsgContainerVC:(UIViewController *)viewObj;
+ (BOOL)isViewObjIsMsgVC:(UIViewController *)viewObj;

@end
