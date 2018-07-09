//
//  ALImagePickerHandler.h
//  ChatApp
//
//  Created by Kumar, Sawant (US - Bengaluru) on 9/23/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ALImagePickerHandler : NSObject

+(NSString *) saveImageToDocDirectory:(UIImage *) image;
+(void) saveVideoToDocDirectory:(NSURL *)videoURL handler:(void (^)(NSString *))handler;

@end
