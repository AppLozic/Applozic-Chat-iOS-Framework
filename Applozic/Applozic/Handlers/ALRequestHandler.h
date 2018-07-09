//
//  ALRequestHandler.h
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+Utility.h"

@interface ALRequestHandler : NSObject

+(NSMutableURLRequest *) createGETRequestWithUrlString:(NSString *) urlString paramString:(NSString *) paramString;

+(NSMutableURLRequest *) createPOSTRequestWithUrlString:(NSString *) urlString paramString:(NSString *) paramString;

+(NSMutableURLRequest *) createGETRequestWithUrlStringWithoutHeader:(NSString *) urlString paramString:(NSString *) paramString;
@end
