//
//  ALMuteRequest.h
//  Applozic
//
//  Created by Adarsh Kumar Mishra on 1/12/17.
//  Copyright © 2017 applozic Inc. All rights reserved.
//

#import "ALJson.h"

@interface ALMuteRequest : ALJson
  
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSNumber *id;		    //Group unique identifier
@property (nonatomic, strong) NSString * clientGroupId;		//	Client Group unique identifier
@property (nonatomic, strong) NSNumber* notificationAfterTime; //Time Interval for which notification has be be disabled

@end
