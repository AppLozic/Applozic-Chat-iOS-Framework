//
//  ALMessageArrayWrapper.h
//  Applozic
//
//  Created by devashish on 17/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALMessage.h"
#import "ALApplozicSettings.h"

@interface ALMessageArrayWrapper : NSObject

@property (nonatomic, strong) NSMutableArray *messageArray;

@property (nonatomic, strong) NSString *dateCellText;

-(BOOL)checkDateOlder:(NSNumber *)older andNewer:(NSNumber *)newer;

-(NSMutableArray *)getUpdatedMessageArray;

-(void)addObjectToMessageArray:(NSMutableArray *)paramMessageArray;

-(void)addALMessageToMessageArray:(ALMessage *)alMessage;

-(void)removeObjectFromMessageArray:(NSMutableArray *)paramMessageArray;

-(void)removeALMessageFromMessageArray:(ALMessage *)almessage;

-(void)addLatestObjectToArray:(NSMutableArray *)paramMessageArray;

-(ALMessage *)getDatePrototype:(NSString *)messageText andAlMessageObject:(ALMessage *)almessage;

-(NSString *)msgAtTop:(ALMessage *)almessage;

@end
