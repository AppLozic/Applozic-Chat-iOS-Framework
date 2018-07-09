//
//  ALUserDetail.h
//  Applozic
//
//  Created by devashish on 26/11/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <CoreData/NSManagedObject.h>
#import <Foundation/Foundation.h>
#import "ALJson.h"

@interface ALUserDetail : ALJson

@property (nonatomic, strong) NSString * userId;
@property (nonatomic) BOOL connected;
@property (nonatomic, strong) NSNumber * lastSeenAtTime;
@property (nonatomic, strong)  NSNumber * unreadCount;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, copy) NSManagedObjectID * userDetailDBObjectId;
@property (nonatomic, strong) NSString * imageLink;
@property (nonatomic, strong) NSString * contactNumber;
@property (nonatomic, strong)  NSString * userStatus;
@property (nonatomic, strong)  NSArray * keyArray;
@property (nonatomic, strong)  NSArray * valueArray;
@property (nonatomic, strong)  NSString * userIdString;
@property (nonatomic, strong) NSNumber * userTypeId;
@property (nonatomic, strong) NSNumber * deletedAtTime;
@property (nonatomic, strong) NSNumber * roleType;
@property (nonatomic,retain) NSMutableDictionary * metadata;

-(void)setUserDetails:(NSString *)jsonString;

-(void)userDetail;

-(NSString *)getDisplayName;

-(id)initWithDictonary:(NSDictionary*)messageDictonary;

-(void)parsingDictionaryFromJSON:(NSDictionary *)JSONDictionary;

@end
