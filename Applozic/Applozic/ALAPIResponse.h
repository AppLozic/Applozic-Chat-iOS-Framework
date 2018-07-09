//
//  ALAPIResponse.h
//  Applozic
//
//  Created by devashish on 19/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALJson.h"

#define RESPONSE_SUCCESS @"success"

@interface ALAPIResponse : ALJson

@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSNumber * generatedAt;
@property (nonatomic, strong) id response;
@property (nonatomic, strong) NSString * actualresponse;

@end
