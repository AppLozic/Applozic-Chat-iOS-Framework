//
//  DB_CONTACT.h
//  ChatApp
//
//  Created by shaik riyaz on 11/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DB_CONTACT : NSManagedObject

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * contactNumber;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * contactImageUrl;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * localImageResourceName;
@property (nonatomic, retain) NSNumber * lastSeenAt;
@property (nonatomic, retain) NSString * userStatus;
@property (nonatomic) BOOL connected;
@property (nonatomic, retain) NSNumber * unreadCount;
@property (nonatomic) BOOL block;
@property (nonatomic) BOOL blockBy;
@property (nonatomic, retain) NSNumber * userTypeId;
@property (nonatomic, retain) NSNumber * contactType;
@property (nonatomic, retain) NSNumber * deletedAtTime;
@property (nonatomic, retain) NSString * metadata;
@property (nonatomic, retain) NSNumber * roleType;
@end
