//
//  ALUserBlockResponse.h
//  Applozic
//
//  Created by devashish on 07/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#define RESPONSE_SUCCESS @"success"

#import "ALAPIResponse.h"
#import "ALUserBlocked.h"

@interface ALUserBlockResponse : ALAPIResponse

@property(nonatomic, strong) NSMutableArray * blockedToUserList;
@property(nonatomic, strong) NSMutableArray * blockedByList;

@property(nonatomic, strong) NSMutableArray <ALUserBlocked *> * blockedUserList;
@property(nonatomic, strong) NSMutableArray <ALUserBlocked *> * blockByUserList;

-(instancetype)initWithJSONString:(NSString *)JSONString;

@end
