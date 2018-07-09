//
//  ALMessageInfoResponse.m
//  Applozic
//
//  Created by devashish on 17/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALMessageInfoResponse.h"

@implementation ALMessageInfoResponse

-(instancetype)initWithJSONString:(NSString *)JSONString
{
    self = [super initWithJSONString:JSONString];
    
    self.msgInfoList = [NSMutableArray new];
    
    if([super.status isEqualToString: RESPONSE_SUCCESS])
    {
        NSMutableArray *responseArray = [JSONString valueForKey:@"response"];
        
        for(NSDictionary *JSONDictionaryObject in responseArray)
        {
            ALMessageInfo *msgObject = [[ALMessageInfo alloc] initWithDictonary:JSONDictionaryObject];
            [self.msgInfoList addObject:msgObject];
        }
        
        return self;
    }
    else
    {
        return nil;
    }

}

@end
