//
//  NSString+Encode.h
//  Applozic
//
//  Created by Divjyot Singh on 21/04/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encode)

-(NSString *)urlEncodeUsingNSUTF8StringEncoding; // Direct UTF8 encoding
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding; // Currently used...

@end
