//
//  ALDataNetworkConnection.h
//  Applozic
//
//  Created by devashish on 02/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALDataNetworkConnection : UIViewController

+(BOOL)checkDataNetworkAvailable;
+(BOOL)noInternetConnectionNotification;

@end
