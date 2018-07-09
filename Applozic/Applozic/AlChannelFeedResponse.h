//
//  AlChannelFeedResponse.h
//  Applozic
//
//  Created by Nitin on 20/10/17.
//  Copyright © 2017 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALAPIResponse.h"
#import "ALChannel.h"

@interface AlChannelFeedResponse : ALAPIResponse

@property (nonatomic, strong) ALChannel *alChannel;

-(instancetype)initWithJSONString:(NSString *)JSONString;

@end
