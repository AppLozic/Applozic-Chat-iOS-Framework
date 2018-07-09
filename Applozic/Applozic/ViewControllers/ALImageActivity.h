//
//  ALImageActivity.h
//  Applozic
//
//  Created by Divjyot Singh on 26/07/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALImageActivityDelegate <NSObject>
-(void)showContactsToShareImage;
@end

@interface ALImageActivity : UIActivity
@property (weak,nonatomic) id <ALImageActivityDelegate> imageActivityDelegate;
@end
