//
//  ALContactsResponse.m
//  Applozic
//
//  Created by devashish on 25/04/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALContactsResponse.h"
#import "ALUserDetail.h"
#import "ALApplozicSettings.h"

@implementation ALContactsResponse

-(id)initWithJSONString:(NSString *)JSONString
{
    [self parseJsonString:JSONString];
    return self;
}

-(void)parseJsonString:(NSString *)JSONString
{
    NSMutableArray * userDetailArray = [[NSMutableArray alloc] initWithArray:[JSONString valueForKey:@"users"]];
    self.userDetailList = [NSMutableArray new];
    
    for(NSDictionary * userDictionary in userDetailArray)
    {
        ALUserDetail * userDetail = [[ALUserDetail alloc] initWithDictonary:userDictionary];
        [self.userDetailList addObject:userDetail];
    }
    
    self.lastFetchTime =  [JSONString valueForKey:@"lastFetchTime"];
    [ALApplozicSettings setStartTime:self.lastFetchTime];
    
    self.totalUnreadCount = [JSONString valueForKey:@"totalUnreadCount"];
    
}

@end
