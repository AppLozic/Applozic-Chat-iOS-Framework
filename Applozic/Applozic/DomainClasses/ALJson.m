//
//  ALJson.m
//  LearnApp
//
//  Created by devashish on 24/07/2015.
//  Copyright (c) 2015 devashish. All rights reserved.
//

#import "ALJson.h"
#import <objc/runtime.h>
#import "ALFileMetaInfo.h"

@implementation ALJson

-(instancetype) init {
    self = [super init];
    return self;
}

- (instancetype)initWithJSONString:(NSString *)JSONString
{
    self = [super init];
    if (self) {
        
        NSError *error = nil;
        NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
        
        if (!error && JSONDictionary) {
            
            //Loop method
            for (NSString* key in JSONDictionary) {
                [self setValue:[JSONDictionary valueForKey:key] forKey:key];
            }
            // Instead of Loop method you can also use:
            // thanks @sapi for good catch and warning.
            // [self setValuesForKeysWithDictionary:JSONDictionary];
        }
    }
    return self;
}

- (NSDictionary *)dictionary {
    unsigned int count = 0;
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    objc_property_t *properties = class_copyPropertyList([self class], &count);
@try {
   
    for (int i = 0; i < count; i++) {
        
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        id value = [self valueForKey:key];
        
        if (value == nil) {
            // nothing todo
        }
        else if ([value isKindOfClass:[NSNumber class]]
                 || [value isKindOfClass:[NSString class]]
                 || [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableArray class]] || [value isKindOfClass:[NSArray class]]) {
            // TODO: extend to other types
            [dictionary setObject:value forKey:key];
        }
        else if ([value isKindOfClass:[NSObject class]]) {
            if ([value isKindOfClass:[ALFileMetaInfo class]]) {
                [dictionary setObject:[value dictionary] forKey:key];
            }
            
        }
        else {
            NSLog(@"Invalid type for %@ (%@)", NSStringFromClass([self class]), key);
        }
    }
    free(properties);
}
    @catch (NSException *exception) {
        NSLog(@"Exception in ALJson %@",exception);
    }
    return dictionary;
}


-(BOOL) validateJsonClass:(NSDictionary *) jsonClass
{
    
    if ([NSStringFromClass([jsonClass class]) isEqual:@"NSNUll"] || jsonClass == nil) {
        
        return NO;
    }
    
    return YES;
    
}

-(BOOL) validateJsonArrayClass:(NSArray *) jsonClass
{
    
    if ([NSStringFromClass([jsonClass class]) isEqual:@"NSNUll"] || jsonClass == nil) {
        
        return NO;
    }
    
    return YES;
    
}
-(NSString *) getStringFromJsonValue:(id) jsonValue
{
    if (jsonValue != [NSNull null] && jsonValue != nil)
    {
        return [NSString stringWithFormat:@"%@",jsonValue];
    }
    
    return nil;
}


-(BOOL ) getBoolFromJsonValue:(id) jsonValue
{
    if (jsonValue != [NSNull null] && jsonValue != nil)
    {
        return [jsonValue boolValue];
    }
    
    return NO;
}

-(short)getShortFromJsonValue:(id) jsonValue
{

    if(jsonValue != [NSNull null] && jsonValue != nil)
    {
        return [jsonValue shortValue];
    }
    return 0;
}

-(NSNumber *)getNSNumberFromJsonValue:(id) jsonValue
{
    
    if(jsonValue != [NSNull null] && jsonValue != nil)
    {
        return [NSNumber numberWithDouble:[jsonValue doubleValue]];
    }
    return 0;
}

-(long)getLongFromJsonValue:(id) jsonValue
{
    
    if(jsonValue != [NSNull null] && jsonValue != nil)
    {
        return [jsonValue longValue];
    }
    return 0;
}

-(int)getIntFromJsonValue:(id) jsonValue
{
    
    if(jsonValue != [NSNull null] && jsonValue != nil)
    {
        return [jsonValue intValue];
    }
    return 0;
}

@end
