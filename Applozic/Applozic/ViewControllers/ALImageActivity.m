//
//  ALImageActivity.m
//  Applozic
//
//  Created by Divjyot Singh on 26/07/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALImageActivity.h"
#import "ALUtilityClass.h"

@implementation ALImageActivity


- (NSString *)activityType
{
    return @"com.applozic.framework";
}

- (NSString *)activityTitle
{
    return @"Forward Image";
}

- (UIImage *)activityImage
{
    // Note: These images need to have a transparent background and I recommend these sizes:
    // iPadShare@2x should be 126 px, iPadShare should be 53 px, iPhoneShare@2x should be 100
    // px, and iPhoneShare should be 50 px. I found these sizes to work for what I was making.
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        return [ALUtilityClass getImageFromFramworkBundle:@"forwardActivity.png"];
//    }
//    else
//    {
//        return [ALUtilityClass getImageFromFramworkBundle:@""];
//    }
    return [ALUtilityClass getImageFromFramworkBundle:@"forwardActivity.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"%s", __FUNCTION__);
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"%s",__FUNCTION__);
}

- (UIViewController *)activityViewController
{
    NSLog(@"%s",__FUNCTION__);
    return nil;
}

- (void)performActivity{
    //TODO: Open Recent Chats...
    NSLog(@"TODO: Open Recent Chats");

    [self.imageActivityDelegate showContactsToShareImage];
}

@end
