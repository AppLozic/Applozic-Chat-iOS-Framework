//
//  AlApplicationInfoFeed.h
//  Applozic
//
//  Created by Nitin on 13/06/17.
//  Copyright © 2017 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALJson.h"

@interface AlApplicationInfoFeed : ALJson

@property NSString *applicationKey;
@property NSString *packageName;
@property NSString *bundleIdentifier;
@property NSString *webInfo;


@end
