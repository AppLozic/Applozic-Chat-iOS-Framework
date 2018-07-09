//
//  ALResponseHandler.h
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALResponseHandler : NSObject

+(void) processRequest:(NSMutableURLRequest *) theRequest andTag:(NSString *)tag WithCompletionHandler:(void(^)(id theJson , NSError * theError))reponseCompletion;

@end
