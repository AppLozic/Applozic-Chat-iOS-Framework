//
//  ALConnectionQueueHandler.m
//  ChatApp
//
//  Created by shaik riyaz on 26/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALConnectionQueueHandler.h"

@implementation ALConnectionQueueHandler

+(ALConnectionQueueHandler *)sharedConnectionQueueHandler
{
    static ALConnectionQueueHandler * sharedHandler = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
    
        sharedHandler = [[self alloc] init];
    
    });
    
    return sharedHandler;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
    
        _mConnectionsArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(NSMutableArray *)getCurrentConnectionQueue
{
    return _mConnectionsArray;
}

@end
