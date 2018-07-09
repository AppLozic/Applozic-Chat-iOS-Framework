//
//  DB_FileMetaInfo.h
//  ChatApp
//
//  Created by shaik riyaz on 23/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DB_FileMetaInfo : NSManagedObject

@property (nonatomic, retain) NSString * blobKeyString;
@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSNumber * createdAtTime;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSString * suUserKeyString;
@property (nonatomic, retain) NSString * thumbnailUrl;

@end
