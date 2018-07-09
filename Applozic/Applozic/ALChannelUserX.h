//
//  ALChannelUserX.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSManagedObject.h>
#import "ALJson.h"



typedef enum
{   USER = 0,
    ADMIN = 1,
    MODERATOR = 2,
    MEMBER = 3
} ROLE_TYPE;



@interface ALChannelUserX : ALJson

@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSNumber *key;
@property (nonatomic) short status;
@property (nonatomic, strong) NSNumber *unreadCount;
@property (nonatomic, strong) NSNumber *parentKey;
@property (nonatomic, copy) NSManagedObjectID *channelUserXDBObjectId;
@property (nonatomic, strong) NSNumber *role;

-(id)initWithDictonary:(NSDictionary *)messageDictonary;

@end
