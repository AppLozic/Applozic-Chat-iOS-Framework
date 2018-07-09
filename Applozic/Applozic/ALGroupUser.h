//
//  ALGroupUser.h
//  Applozic
//
//  Created by Sunil on 14/02/18.
//  Copyright © 2018 applozic Inc. All rights reserved.
//
#import "ALJson.h"
#import <Foundation/Foundation.h>

@interface ALGroupUser : ALJson

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSNumber *groupRole;
    
-(id)initWithDictonary:(NSDictionary *)messageDictonary;

@end
