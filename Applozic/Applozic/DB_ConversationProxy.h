//
//  DB_ConversationProxy.h
//  Applozic
//
//  Created by devashish on 13/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DB_ConversationProxy : NSManagedObject

@property (nonatomic, strong) NSNumber *iD;
@property (nonatomic, strong) NSString *topicId;
@property (nonatomic, strong) NSNumber *groupId;
@property(nonatomic,strong) NSString * userId;
@property (nonatomic,retain) NSNumber *created;
@property(nonatomic,retain) NSNumber * closed;

@property(nonatomic,strong) NSString * topicDetailJson;



@end
