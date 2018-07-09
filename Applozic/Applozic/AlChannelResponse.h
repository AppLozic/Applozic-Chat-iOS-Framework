//
//  AlChannelResponse.h
//  Applozic
//
//  Created by Nitin on 21/10/17.
//  Copyright © 2017 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSManagedObject.h>
#import "ALJson.h"
#import "ALConversationProxy.h"

@interface AlChannelResponse :  ALJson

@property (nonatomic, strong) NSNumber *key;
@property (nonatomic, strong) NSString *clientGroupId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *adminKey;
@property (nonatomic) short type;
@property (nonatomic, strong) NSNumber *userCount;
@property (nonatomic, strong) NSNumber *unreadCount;
@property (nonatomic, strong) ALConversationProxy *conversationProxy;
@property (nonatomic, strong) NSNumber * notificationAfterTime;
@property (nonatomic, strong) NSNumber * deletedAtTime;
@property (nonatomic, strong) NSMutableDictionary * metadata;


@end
