//
//  ALConversationCreateResponse.m
//  Applozic
//
//  Created by Divjyot Singh on 04/03/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALConversationCreateResponse.h"

@implementation ALConversationCreateResponse


-(instancetype)initWithJSONString :(NSString *)JSONString{
    
    self = [super initWithJSONString:JSONString];
    
    if([super.status isEqualToString: RESPONSE_SUCCESS])
    {
        NSDictionary *JSONDictionary = [[JSONString valueForKey:@"response"] valueForKey:@"conversationPxy"];
        self.alConversationProxy = [[ALConversationProxy alloc] initWithDictonary:JSONDictionary];
        
        return self;
    }
    else
    {
        return nil;
    }
    
}




@end
