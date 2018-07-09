//
//  ALUserBlocked.h
//  Applozic
//
//  Created by devashish on 10/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALUserBlocked : NSObject

@property (nonatomic, strong) NSString * id;
@property (nonatomic, strong) NSString * blockedTo;
@property (nonatomic, strong) NSString * blockedBy;
@property (nonatomic, strong) NSString * applicationKey;
@property (nonatomic, strong) NSNumber * createdAtTime;
@property (nonatomic, strong) NSNumber * updatedAtTime;
@property (nonatomic) BOOL userBlocked;
@property (nonatomic) BOOL userblockedBy;

@end
