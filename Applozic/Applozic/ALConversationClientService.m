//
//  ALConversationClientService.m
//  Applozic
//
//  Created by Divjyot Singh on 04/03/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALConversationClientService.h"
#import "ALConversationDBService.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"

#define CREATE_CONVERSATION_URL @"/rest/ws/conversation/id"
#define FETCH_CONVERSATION_DETAILS @"/rest/ws/conversation/topicId"

@implementation ALConversationClientService


+(void)createConversation:(ALConversationProxy*)alConversationProxy
           withCompletion:(void(^)(NSError *error, ALConversationCreateResponse *response))completion {

    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, CREATE_CONVERSATION_URL];
    
    NSDictionary * dictionaryToSend = [NSDictionary dictionaryWithDictionary:[ALConversationProxy getDictionaryForCreate:alConversationProxy]];
                                       
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:dictionaryToSend options:0 error:&error];
    NSString *theParamString = [[NSString alloc] initWithData:postdata encoding: NSUTF8StringEncoding];
    NSMutableURLRequest * theRequest = [ALRequestHandler createPOSTRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"CREATE_CONVERSATION" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        ALConversationCreateResponse *response = nil;
        
        if (theError)
        {
            NSLog(@"ERROR IN CREATE_CONVERSATION %@", theError);
        }
        else
        {
            response = [[ALConversationCreateResponse alloc] initWithJSONString:theJson];
        }
        NSLog(@"SEVER RESPONSE FROM JSON CREATE_CONVERSATION : %@", theJson);
        completion(theError, response);
        
    }];
    
}

+(void)fetchTopicDetails:(NSNumber *)alConversationProxyID andCompletion:(void (^)(NSError *, ALAPIResponse *))completion{
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@",KBASE_URL, FETCH_CONVERSATION_DETAILS];
    NSString * theParamString = [NSString stringWithFormat:@"id=%@",alConversationProxyID];
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"FETCH_TOPIC_DETAILS" WithCompletionHandler:^(id theJson, NSError *theError) {
       
        ALAPIResponse *response = nil;
        if(theError)
        {
            NSLog(@"ERROR IN FETCH_TOPIC_DETAILS SERVER CALL REQUEST %@", theError);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        
        completion(theError, response);

    }];
}

@end
