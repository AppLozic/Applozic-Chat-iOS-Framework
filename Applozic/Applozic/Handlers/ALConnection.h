//
//  ALConnection.h
//  ChatApp
//
//  Created by shaik riyaz on 26/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DB_FileMetaInfo.h"

@interface ALConnection : NSURLConnection

@property (nonatomic, strong) NSString *connectionType;
@property (nonatomic,retain) NSMutableData * mData;
@property (nonatomic,strong) NSString * keystring;

@end
