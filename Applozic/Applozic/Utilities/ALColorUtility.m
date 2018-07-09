//
//  ALColorUtility.m
//  Applozic
//
//  Created by Divjyot Singh on 23/11/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALColorUtility.h"

@implementation ALColorUtility

+ (UIImage *)imageWithSize:(CGRect)rect WithHexString:(NSString*)stringToConvert {
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[[self colorWithHexString:stringToConvert] CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $
    
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    UIColor *colorFromHex = [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
    
    return colorFromHex;
}

+ (UIColor *)getColorForAlphabet:(NSString *)alphabet
{
    
    NSMutableDictionary *colourDictionary = [[NSMutableDictionary alloc] init];
    
    [colourDictionary setObject:@"#4FC3F7" forKey:@"A"];
    [colourDictionary setObject:@"#F06292" forKey:@"B"];
    [colourDictionary setObject:@"#BA68C8" forKey:@"C"];
    [colourDictionary setObject:@"#9575CD" forKey:@"D"];
    [colourDictionary setObject:@"#7986CB" forKey:@"E"];
    [colourDictionary setObject:@"#4FC3F7" forKey:@"F"];
    [colourDictionary setObject:@"#E06055" forKey:@"G"];
    [colourDictionary setObject:@"#4DD0E1" forKey:@"H"];
    [colourDictionary setObject:@"#4DB6AC" forKey:@"I"];
    [colourDictionary setObject:@"#57BB8A" forKey:@"J"];
    [colourDictionary setObject:@"#9CCC65" forKey:@"K"];
    [colourDictionary setObject:@"#D4E157" forKey:@"L"];
    [colourDictionary setObject:@"#FDD835" forKey:@"M"];
    [colourDictionary setObject:@"#F6BF26" forKey:@"N"];
    [colourDictionary setObject:@"#FFA726" forKey:@"O"];
    [colourDictionary setObject:@"#FF8A65" forKey:@"P"];
    [colourDictionary setObject:@"#C2C2C2" forKey:@"Q"];
    [colourDictionary setObject:@"#90A4AE" forKey:@"R"];
    [colourDictionary setObject:@"#A1887F" forKey:@"S"];
    [colourDictionary setObject:@"#A3A3A3" forKey:@"T"];
    [colourDictionary setObject:@"#AFB6E0" forKey:@"U"];
    [colourDictionary setObject:@"#B39DDB" forKey:@"V"];
    [colourDictionary setObject:@"#C2C2C2" forKey:@"W"];
    [colourDictionary setObject:@"#80DEEA" forKey:@"X"];
    [colourDictionary setObject:@"#BCAAA4" forKey:@"Y"];
    [colourDictionary setObject:@"#AED581" forKey:@"Z"];
    
    if(!alphabet || [alphabet isEqualToString:@""])
    {
        return [UIColor lightGrayColor];
    }
   
    UIColor * colour;
    @try
    {
        NSString * firstLetter = [[alphabet substringToIndex:1] uppercaseString];
        colour = [self colorWithHexString:[colourDictionary valueForKey:firstLetter]];
        
        if(!colour)
        {
            NSArray * keyArray = [colourDictionary allKeys];
            NSUInteger randomIndex = random()% [keyArray count];
            NSString * colorKey = [keyArray objectAtIndex:randomIndex];
            colour = [self colorWithHexString:[colourDictionary valueForKey:colorKey]];
        }
    }
    @catch(NSException *ex)
    {
        NSLog(@"ALPHABET = ' %@ ' && EXPCEPTION :: %@", alphabet, ex);
        colour = [UIColor lightGrayColor];
    }
    
    return colour;
}

+(NSString *)getAlphabetForProfileImage:(NSString *)actualName
{
    NSString * iconAlphabet = @"";
    NSString * trimmed = [actualName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(trimmed.length == 0)
    {
        return actualName;
    }
    
    NSString *firstLetter = [trimmed substringToIndex:1];
    NSRange whiteSpaceRange = [trimmed rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *listNames = [trimmed componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (whiteSpaceRange.location != NSNotFound)
    {
        NSString *firstLetter = [[listNames[0] substringToIndex:1] uppercaseString];
        iconAlphabet = firstLetter;
        NSString *lastLetter = listNames[1];
        if (lastLetter.length)
        {
            lastLetter = [[listNames[1] substringToIndex:1] uppercaseString];
            iconAlphabet = [[firstLetter stringByAppendingString:lastLetter] uppercaseString];
        }
    }
    else
    {
         iconAlphabet = [firstLetter uppercaseString];
    }

    return iconAlphabet;
}

@end
