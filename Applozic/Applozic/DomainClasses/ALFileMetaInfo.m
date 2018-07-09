//
//  ALFileMetaInfo.m
//  ChatApp
//
//  Created by shaik riyaz on 23/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALFileMetaInfo.h"
#import "ALConstant.h"
#import "ALApplozicSettings.h"

@implementation ALFileMetaInfo



-(NSString *)getTheSize
{
    
    if ((self.size.intValue/1024.0)/1024.0 >= 1) {
        
        return [NSString stringWithFormat:@" %.1f mb",(self.size.intValue/1024.0)/1024.0];
    }
    else
    {
        return [NSString stringWithFormat:@" %d kb",self.size.intValue/1024];
    }
    
}

-(ALFileMetaInfo *) populate:(NSDictionary *)dict {
    self.blobKey=[dict objectForKey:@"blobKey"];
    self.contentType=[dict objectForKey:@"contentType"];
    self.createdAtTime= @([[dict objectForKey:@"createdAtTime"] doubleValue]);
    self.key=[dict objectForKey:@"key"];
    self.name=[dict objectForKey:@"name"];
    if([dict objectForKey:@"size"]) {
        // If the type of size is number then convert to string otherwise it's a string.
        self.size = [[dict objectForKey:@"size"] isKindOfClass:[NSNumber class]]? [[dict objectForKey:@"size"] stringValue]:[dict objectForKey:@"size"];
    } else {
        self.size = nil;
    }
    self.userKey=[dict objectForKey:@"suUserKeyString"];
    NSString *thumbnail = [self getFullThumbnailUrl:[dict objectForKey:@"thumbnailUrl"]];
    self.thumbnailUrl= thumbnail;
    self.url= [dict objectForKey:@"url"];
    return self;

}

-(NSString *) getFullThumbnailUrl:(NSString*)url
{
    if (ALApplozicSettings.isStorageServiceEnabled) {
        NSString *fullUrl = [[NSString alloc] initWithFormat:@"%@%@%@",KBASE_FILE_URL,IMAGE_THUMBNAIL_ENDPOIT,url];
        return fullUrl;
    }
    return url;
}

@end
