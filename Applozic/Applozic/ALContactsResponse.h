//
//  ALContactsResponse.h
//  Applozic
//
//  Created by devashish on 25/04/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALJson.h"

@interface ALContactsResponse : ALJson

@property (nonatomic, strong) NSNumber * lastFetchTime;
@property (nonatomic, strong) NSNumber * totalUnreadCount;

@property (nonatomic, strong) NSMutableArray * userDetailList;

@end
