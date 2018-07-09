//
//  ALColorUtility.h
//  Applozic
//
//  Created by Divjyot Singh on 23/11/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ALColorUtility : NSObject

+ (UIImage *)imageWithSize:(CGRect)rect WithHexString:(NSString*)stringToConvert;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
+ (UIColor *)getColorForAlphabet:(NSString *)alphabet;
+ (NSString *)getAlphabetForProfileImage:(NSString *)actualName;

@end
