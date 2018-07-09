//
//  ALJson.h
//  LearnApp
//
//  Created by devashish on 24/07/2015.
//  Copyright (c) 2015 devashish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALJson : NSObject

-(instancetype)initWithJSONString:(NSString *)JSONString;

-(NSDictionary *)dictionary;

-(NSString *) getStringFromJsonValue:(id) jsonValue;

-(BOOL ) getBoolFromJsonValue:(id) jsonValue;

-(BOOL) validateJsonClass:(NSDictionary *) jsonClass;

-(BOOL) validateJsonArrayClass:(NSArray *) jsonClass;

-(short)getShortFromJsonValue:(id) jsonValue;

-(NSNumber *) getNSNumberFromJsonValue:(id) jsonValue;

-(int)getIntFromJsonValue:(id) jsonValue;

-(long)getLongFromJsonValue:(id) jsonValue;

@end
