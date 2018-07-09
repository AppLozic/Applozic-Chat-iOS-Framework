//
//  DB_CHANNEL_USER_X.h
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DB_CHANNEL_USER_X : NSManagedObject


@property (nonatomic, retain) NSNumber *channelKey;
@property (nonatomic, retain) NSNumber *parentGroupKey;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic) short status;
@property (nonatomic, retain) NSNumber * unreadCount;
@property (nonatomic,retain) NSNumber * role;



@end
