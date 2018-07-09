//
//  ALLastSeenSyncFeed.h
//  Applozic
//
//  Created by Devashish on 19/12/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALUserDetail.h"
#import "ALJson.h"

@interface ALLastSeenSyncFeed : ALJson

-(instancetype)initWithJSONString:(NSString*)lastSeenResponse;

@property(nonatomic)  NSMutableArray <ALUserDetail *>* lastSeenArray ;

-(void)populateLastSeenDetail:(NSMutableArray *)jsonString;


@end
