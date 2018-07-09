//
//  ALConnectionQueueHandler.h
//  ChatApp
//
//  Created by shaik riyaz on 26/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALConnectionQueueHandler : NSObject

@property (nonatomic,retain) NSMutableArray * mConnectionsArray;

+(ALConnectionQueueHandler *) sharedConnectionQueueHandler;

-(NSMutableArray *) getCurrentConnectionQueue;

@end
