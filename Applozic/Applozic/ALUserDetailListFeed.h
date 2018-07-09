//
//  ALUserDetailListFeed.h
//  Applozic
//
//  Created by Abhishek Thapliyal on 10/13/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Applozic/ALJson.h>

@interface ALUserDetailListFeed : ALJson

@property (nonatomic, strong) NSMutableArray * userIdList;

@property (nonatomic) BOOL contactSync;

-(void)setArray:(NSMutableArray *)array;

@end
