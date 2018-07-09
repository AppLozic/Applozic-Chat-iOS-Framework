//
//  ALChannelCreateResponse.h
//  Applozic
//
//  Created by devashish on 12/02/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALAPIResponse.h"
#import "ALChannel.h"

@interface ALChannelCreateResponse : ALAPIResponse

@property (nonatomic, strong) ALChannel *alChannel;

-(instancetype)initWithJSONString:(NSString *)JSONString;

@end
