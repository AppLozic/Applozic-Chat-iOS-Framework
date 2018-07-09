//
//  ALUser.m
//  ChatApp
//
//  Created by devashish on 18/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALUser.h"
#import "ALUserDefaultsHandler.h"

@implementation ALUser

-(instancetype)initWithUserId:(NSString *)userId
                     password:(NSString *)password
                        email:(NSString *)email
               andDisplayName:(NSString *)displayName {

    self = [super init];
    
    if (self) {
    
        self.userId = userId;
        self.password = password;
        self.displayName = displayName;
        self.email = email;
    }
    
    return self;
}

@end

