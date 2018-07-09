//
//  ALUserBlockResponse.m
//  Applozic
//
//  Created by devashish on 07/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALUserBlockResponse.h"

@implementation ALUserBlockResponse

-(instancetype)initWithJSONString:(NSString *)JSONString
{
    self = [super initWithJSONString:JSONString];
    self.blockedUserList = [NSMutableArray new];
    NSDictionary *JSONDictionary = [JSONString valueForKey:@"response"];
    self.blockedToUserList = [[NSMutableArray alloc] initWithArray: [JSONDictionary valueForKey:@"blockedToUserList"]];
    
    for (NSDictionary *dict in self.blockedToUserList)
    {
        ALUserBlocked *userBlockedObject = [[ALUserBlocked alloc] init];
        userBlockedObject.blockedTo = [dict valueForKey:@"blockedTo"];
        userBlockedObject.applicationKey = [dict valueForKey:@"applicationKey"];
        userBlockedObject.createdAtTime = [dict valueForKey:@"createdAtTime"];
        userBlockedObject.updatedAtTime = [dict valueForKey:@"updatedAtTime"];
        userBlockedObject.userBlocked = [[dict valueForKey:@"userBlocked"] boolValue];

        [self.blockedUserList addObject:userBlockedObject];
    }
    
    self.blockByUserList = [NSMutableArray new];
    self.blockedByList = [[NSMutableArray alloc] initWithArray: [JSONDictionary valueForKey:@"blockedByUserList"]];
    
    for (NSDictionary *dict in self.blockedByList)
    {
        ALUserBlocked *userBlockedByObject = [[ALUserBlocked alloc] init];
        userBlockedByObject.blockedBy = [dict valueForKey:@"blockedBy"];
        userBlockedByObject.userblockedBy = [[dict valueForKey:@"userBlocked"] boolValue];
        
        [self.blockByUserList addObject: userBlockedByObject];
    }
    
    return self;
}

@end
