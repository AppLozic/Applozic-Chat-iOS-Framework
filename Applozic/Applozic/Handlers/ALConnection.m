//
//  ALConnection.m
//  ChatApp
//
//  Created by shaik riyaz on 26/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALConnection.h"

@implementation ALConnection

-(instancetype)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately {
    self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
    if (self) {
        self.mData = [[NSMutableData alloc] init];
    }
    return self;
}

@end
