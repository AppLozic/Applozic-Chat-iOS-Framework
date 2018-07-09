//
//  DB_Message.h
//  ChatApp
//
//  Created by Gaurav Nigam on 02/09/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DB_FileMetaInfo;

@interface DB_Message : NSManagedObject

@property (nonatomic) short contentType;
@property (nonatomic, retain) NSString * contactId;
@property (nonatomic, retain) NSNumber * createdAt;
@property (nonatomic, retain) NSString * deviceKey;
@property (nonatomic, retain) NSString * filePath;
//@property (nonatomic, retain) NSNumber * isRead;
//@property (nonatomic, retain) NSNumber * isSent;
@property (nonatomic, retain) NSNumber * deletedFlag;
@property (nonatomic, retain) NSNumber * isSentToDevice;
@property (nonatomic, retain) NSNumber * isShared;
@property (nonatomic, retain) NSNumber * isStoredOnDevice;
@property (nonatomic, retain) NSNumber * isUploadFailed;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * messageText;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * inProgress;
@property (nonatomic, retain) NSNumber * delivered;
@property (nonatomic, retain) NSNumber * sentToServer;
@property (nonatomic, retain) DB_FileMetaInfo *fileMetaInfo;
@property (nonatomic, retain) NSNumber * groupId;
@property (nonatomic, retain) NSNumber * conversationId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * pairedMessageKey;
@property (nonatomic, retain) NSString * metadata;
@property (nonatomic, retain) NSNumber * msgHidden;
@property (nonatomic, retain) NSNumber * replyMessageType;



@end
