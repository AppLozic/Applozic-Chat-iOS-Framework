//
//  ALConversationClientService.h
//  Applozic
//
//  Created by Divjyot Singh on 04/03/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALConstant.h"
#import "ALConversationCreateResponse.h"
#import "ALConversationProxy.h"

@interface ALConversationClientService : NSObject
+(void)createConversation:(ALConversationProxy*)alConversationProxy
           withCompletion:(void(^)(NSError *error, ALConversationCreateResponse *response))completion;
+(void)fetchTopicDetails:(NSNumber *)alConversationProxyID andCompletion:(void (^)(NSError *, ALAPIResponse *))completion;
@end
