//
//  ALMessageArrayWrapper.m
//  Applozic
//
//  Created by devashish on 17/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALMessageArrayWrapper.h"
#import "ALUserDefaultsHandler.h"

@interface ALMessageArrayWrapper ()

@end

@implementation ALMessageArrayWrapper

-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.messageArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSMutableArray *)getUpdatedMessageArray
{
    return self.messageArray;
}

-(void)addALMessageToMessageArray:(ALMessage *)alMessage
{
    if([self getUpdatedMessageArray].count == 0)
    {
        ALMessage *dateLabel = [self getDatePrototype:
                                NSLocalizedStringWithDefaultValue(@"today", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Today", @"")
                                   andAlMessageObject:alMessage];
        [self.messageArray addObject:dateLabel];
    }
    else
    {
        ALMessage *msg = [self.messageArray lastObject];
        
        if([self checkDateOlder:msg.createdAtTime andNewer:alMessage.createdAtTime])
        {
            ALMessage *dateLabel = [self getDatePrototype:self.dateCellText andAlMessageObject:alMessage];
            [self.messageArray addObject:dateLabel];
        }
    }
    
    [self.messageArray addObject:alMessage];
}

-(void)removeALMessageFromMessageArray:(ALMessage *)almessage
{
    
    ALMessage *msgLast = [self.messageArray lastObject];
    if([msgLast isEqual:almessage])
    {
        [self.messageArray removeObject:almessage];
        ALMessage *msg = [self.messageArray lastObject];
        if([msg.type isEqualToString:@"100"])
        {
            [self.messageArray removeObject:msg];
        }
    }
    else
    {
        int x = (int)[self.messageArray indexOfObject:almessage];
        ALMessage *prev = [self.messageArray objectAtIndex:x - 1];
        ALMessage *next = [self.messageArray objectAtIndex:x + 1];
        if([prev.type isEqualToString:@"100"] && [next.type isEqualToString:@"100"])
        {
            [self.messageArray removeObject:prev];
        }
        [self.messageArray removeObject:almessage];
    }
    
}

-(void)addObjectToMessageArray:(NSMutableArray *)paramMessageArray
{
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    //remove first object if it a date ..
    if( [self.messageArray firstObject  ] ){
        ALMessage *messgae = [self.messageArray firstObject ];
        if([ messgae.type isEqualToString:@"100"]){
            [self.messageArray removeObjectAtIndex:0];
        }
    }
    
    tempArray = [NSMutableArray arrayWithArray:self.messageArray];
    [tempArray addObjectsFromArray:paramMessageArray];
    
    int countX  =((int)self.messageArray.count);
    for(int i = (int)(tempArray.count-1); i >= countX; i--)
    {
        //Adding last message as comparision last message is missing
        if(i==0){
            [self.messageArray insertObject:tempArray[i] atIndex:0];
        }else{
            ALMessage * msg1 = tempArray[i - 1];
            ALMessage * msg2 = tempArray[i];
            
            [self.messageArray insertObject:tempArray[i] atIndex:0];
            
            if([self checkDateOlder:msg1.createdAtTime andNewer:msg2.createdAtTime])
            {
                ALMessage *dateLabel = [self getDatePrototype:self.dateCellText andAlMessageObject:tempArray[i]];
                [self.messageArray insertObject:dateLabel atIndex:0];
            }
        }
    }
    //final addintion of date at top ....
    ALMessage * message = [self.messageArray firstObject];
    if(message){
        NSString * dateTxt = [self msgAtTop:message];
        ALMessage *dateLabel = [self getDatePrototype:dateTxt andAlMessageObject:message];
        [self.messageArray insertObject:dateLabel atIndex:0];
    }
    
    [tempArray removeAllObjects];
}

-(void)addLatestObjectToArray:(NSMutableArray *)paramMessageArray
{
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    paramMessageArray = [self filterOutDuplicateMessage:paramMessageArray];
    if(!paramMessageArray.count){
        return;
    }
    tempArray = [NSMutableArray arrayWithArray:self.messageArray];
    [tempArray addObjectsFromArray:paramMessageArray];
    
    
    if(tempArray.count == 1)
    {
        
        self.dateCellText = NSLocalizedStringWithDefaultValue(@"today", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Today", @"");
        
        ALMessage *dateLabel = [self getDatePrototype:self.dateCellText andAlMessageObject:tempArray[0]];
        
        [self.messageArray addObject:dateLabel];
        [self.messageArray addObject:tempArray[0]];
        [tempArray removeAllObjects];
        return;
    }
    
    int countX  =((int)self.messageArray.count==0)?1:((int)self.messageArray.count);
    for(int i = countX-1 ; i  < (tempArray.count-1) ; i++)
    {
        
        if(i==0){
            [self.messageArray addObject:tempArray[0]];
        }else{
            ALMessage * msg1 = tempArray[i];
            ALMessage * msg2 = tempArray[i+1];
            if([self checkDateOlder:msg1.createdAtTime andNewer:msg2.createdAtTime])
            {
                ALMessage *dateLabel = [self getDatePrototype:self.dateCellText andAlMessageObject:tempArray[i]];
                [self.messageArray addObject:dateLabel];
            }
            [self.messageArray addObject:tempArray[i+1] ];
        }
    }
    
    //final addintion of date at top ....
    //    ALMessage * message = [self.messageArray firstObject];
    //    if(message){
    //        NSString * dateTxt = [self msgAtTop:message];
    //        ALMessage *dateLabel = [self getDatePrototype:dateTxt andAlMessageObject:message];
    //        [self.messageArray insertObject:dateLabel atIndex:0];
    //    }
    
    [tempArray removeAllObjects];
}

-(ALMessage *)getDatePrototype:(NSString *)messageText andAlMessageObject:(ALMessage *)almessage
{
    ALMessage *dateLabel = [[ALMessage alloc] init];
    dateLabel.createdAtTime = almessage.createdAtTime;
    dateLabel.message = messageText;
    dateLabel.type = @"100";
    dateLabel.contactIds = almessage.contactIds;
    dateLabel.fileMeta.thumbnailUrl = nil;
    dateLabel.groupId = almessage.groupId;
    return  dateLabel;
}

-(void)removeObjectFromMessageArray:(NSMutableArray *)paramMessageArray
{
    [self.messageArray removeObject:paramMessageArray];
}

-(BOOL)checkDateOlder:(NSNumber *)older andNewer:(NSNumber *)newer
{
    double old = [older doubleValue];
    double new = [newer doubleValue];
    
    NSDate *olderDate = [[NSDate alloc] initWithTimeIntervalSince1970:(old/1000)];
    NSDate *newerDate = [[NSDate alloc] initWithTimeIntervalSince1970:(new/1000)];
    
    NSDate *current = [[NSDate alloc] init];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy"];
    
    NSString *todaydate = [format stringFromDate:current];
    NSString *newerDateString = [format stringFromDate:newerDate];
    NSString *olderDateString = [format stringFromDate:olderDate];
    
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    NSString *yesterdaydate = [format stringFromDate:yesterday];
    
    if([newerDateString isEqualToString:olderDateString])
    {
        return NO;
    }
    else
    {
        if([newerDateString isEqualToString:todaydate])
        {
            self.dateCellText = NSLocalizedStringWithDefaultValue(@"today", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Today", @"");
            
        }
        else if([newerDateString isEqualToString:yesterdaydate])
        {
            self.dateCellText = NSLocalizedStringWithDefaultValue(@"yesterday", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Yesterday", @"");
        }
        else
        {
            [format setDateFormat:@"EEEE MMM dd,yyyy"];
            self.dateCellText = [format stringFromDate:newerDate];
        }
        return YES;
    }
    
    
}

-(NSString *)msgAtTop:(ALMessage *)almessage
{
    double old = [almessage.createdAtTime doubleValue];
    NSDate *olderDate = [[NSDate alloc] initWithTimeIntervalSince1970:(old/1000)];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    
    [format setDateFormat:@"dd/MM/yyyy"];
    
    NSString *string = [format stringFromDate:olderDate];
    
    NSDate *current = [[NSDate alloc] init];
    [format setDateFormat:@"dd/MM/yyyy"];
    NSString *todaydate = [format stringFromDate:current];
    
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    NSString *yesterdaydate = [format stringFromDate:yesterday];
    NSString *actualDate = @"";
    
    if([string isEqualToString:todaydate])
    {
        actualDate = NSLocalizedStringWithDefaultValue(@"today", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Today", @"");
    }
    else if ([string isEqualToString:yesterdaydate])
    {
        actualDate = NSLocalizedStringWithDefaultValue(@"yesterday", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Yesterday", @"");    }
    else
    {
        [format setDateFormat:@"EEEE MMM dd,yyyy"];
        actualDate = [format stringFromDate:olderDate];
    }
    
    return actualDate;
    
}

-(NSMutableArray*)filterOutDuplicateMessage:(NSMutableArray*)newMessageArray {
    
    ALMessage * firstInNewMessage = [newMessageArray objectAtIndex:0];
    //    ALMessage * lastInOldMessage = [self.messageArray lastObject];
    
    
    if(self.messageArray.count <=0){
        return newMessageArray;
    }
    if( firstInNewMessage.createdAtTime > [ALUserDefaultsHandler getLastSyncTime]){
        return newMessageArray;
    }
    NSMutableArray * tempArray = [NSMutableArray arrayWithArray:newMessageArray];
    
    int count = (int)self.messageArray.count;
    for (ALMessage *message in tempArray)
    {
        
        for(int i = count-1 ; i  > 0 ; i--)
        {
            ALMessage * oldMessage = [self.messageArray objectAtIndex:i];
            if ([oldMessage.key isEqualToString:message.key])
            {
                NSLog(@"removing duplicate object found....");
                [newMessageArray removeObject:message];
            }
            else if (message.createdAtTime  > oldMessage.createdAtTime)
            {
                return newMessageArray;
            }
        }
        
    }
    return newMessageArray;
}

@end
