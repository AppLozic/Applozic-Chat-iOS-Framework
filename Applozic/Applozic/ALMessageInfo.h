//
//  ALMessageInfo.h
//  Applozic
//
//  Created by devashish on 17/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALJson.h"

@interface ALMessageInfo : ALJson

@property (nonatomic, strong) NSString *userId;
@property (nonatomic) short messageStatus;
@property (nonatomic, strong) NSNumber * deliveredAtTime;
@property (nonatomic, strong) NSNumber * readAtTime;

-(id)initWithDictonary:(NSDictionary *)messageDictonary;
-(void)parseMessage:(id) messageJson;

@end
