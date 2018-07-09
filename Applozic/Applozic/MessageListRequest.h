//
//  MessageListRequest.h
//  Applozic
//
//  Created by Devashish on 29/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageListRequest : NSObject

@property(nonatomic,retain) NSNumber * channelKey;
@property(nonatomic) short channelType;
@property(nonatomic,retain) NSString * startIndex;
@property(nonatomic,retain) NSString * pageSize;
@property(nonatomic,retain) NSNumber * endTimeStamp;
@property(nonatomic,retain) NSNumber * startTimeStamp;
@property(nonatomic,retain) NSString * userId;
@property(nonatomic,retain) NSNumber * conversationId;

-(NSString*)getParamString;
-(BOOL)isFirstCall;

@end
