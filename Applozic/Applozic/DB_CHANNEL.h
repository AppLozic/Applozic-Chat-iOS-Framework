//
//  DB_CHANNEL.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DB_CHANNEL : NSManagedObject

@property (nonatomic, retain) NSString *adminId;
@property (nonatomic, retain) NSString *channelDisplayName;
@property (nonatomic, retain) NSString *channelImageURL;
@property (nonatomic, retain) NSNumber *channelKey;
@property (nonatomic, retain) NSNumber *parentGroupKey;
@property (nonatomic, retain) NSString *parentClientGroupKey;

@property (nonatomic, retain) NSString *clientChannelKey;
@property (nonatomic) short type;
@property (nonatomic, strong) NSNumber *userCount;
@property (nonatomic, strong) NSNumber *unreadCount;
@property (nonatomic) BOOL isLeft;
@property (nonatomic, strong) NSNumber* notificationAfterTime;
@property (nonatomic, strong) NSNumber* deletedAtTime;
@property (nonatomic, retain) NSString * metadata;

@end
