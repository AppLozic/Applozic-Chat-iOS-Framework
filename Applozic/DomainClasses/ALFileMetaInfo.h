//
//  ALFileMetaInfo.h
//  ChatApp
//
//  Created by shaik riyaz on 23/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ALJson.h"


@interface ALFileMetaInfo : ALJson

@property (nonatomic,copy) NSString * key;
@property (nonatomic,copy) NSString * userKey;
@property (nonatomic, copy) NSString * blobKey;
@property (nonatomic,copy) NSString * name;
@property (nonatomic,copy)NSString *url;
@property (nonatomic,copy) NSString * size;
@property (nonatomic,copy) NSString * contentType;
@property (nonatomic,copy) NSString * thumbnailUrl;
@property (nonatomic,copy) NSNumber * createdAtTime;

@property (nonatomic, assign) CGFloat progressValue;

-(NSString *) getTheSize;

-(ALFileMetaInfo *) populate:( NSDictionary *)dict;

@end
