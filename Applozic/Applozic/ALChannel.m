//
//  ALChannel.m
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALChannel.h"
#import "ALChannelUser.h"
#import "ALUserDefaultsHandler.h"


@interface ALChannel ()

@end

@implementation ALChannel

@synthesize membersName = _membersName;

-(id)initWithDictonary:(NSDictionary *)messageDictonary
{
    [self parseMessage:messageDictonary];
    return self;
}

-(void)parseMessage:(id) messageJson
{
    self.key = [self getNSNumberFromJsonValue:messageJson[@"id"]];
    self.clientChannelKey = [self getStringFromJsonValue:messageJson[@"clientGroupId"]];
    self.name = [self getStringFromJsonValue:messageJson[@"name"]];
    self.channelImageURL = [self getStringFromJsonValue:messageJson[@"imageUrl"]];
    self.adminKey = [self getStringFromJsonValue:messageJson[@"adminId"]];
    self.unreadCount = [self getNSNumberFromJsonValue:messageJson[@"unreadCount"]];
    self.userCount = [self getNSNumberFromJsonValue:messageJson[@"userCount"]];
//    self.membersName = [[NSMutableArray alloc] initWithArray:[messageJson objectForKey:@"membersName"]];
    [self setMembersName: [[NSMutableArray alloc] initWithArray:[messageJson objectForKey:@"membersName"]]];
    self.membersId = [[NSMutableArray alloc] initWithArray:[messageJson objectForKey:@"membersId"]];
    
    self.removeMembers = [[NSMutableArray alloc] initWithArray:[messageJson objectForKey:@"removedMembersId"]];
    self.type = [self getShortFromJsonValue:messageJson[@"type"]];
    
    self.metadata = [[NSMutableDictionary alloc] initWithDictionary:[messageJson objectForKey:@"metadata"]];
   
    self.childKeys = [[NSMutableArray alloc] initWithArray:[messageJson objectForKey:@"childKeys"]];
    
    self.notificationAfterTime = [self getNSNumberFromJsonValue:messageJson[@"notificationAfterTime"]];
    
    self.deletedAtTime = [self getNSNumberFromJsonValue:messageJson[@"deletedAtTime"]];
    
    self.parentKey = [self getNSNumberFromJsonValue:messageJson[@"parentKey"]];
    self.parentClientKey = [self getStringFromJsonValue:messageJson[@"parentClientGroupId"]];
    
    NSDictionary * channelDetailGroup = [messageJson objectForKey:@"groupUsers"];
    NSMutableArray * userArray = [NSMutableArray new];

    for(NSDictionary* dict in channelDetailGroup){
        ALChannelUser * channelUser = [[ALChannelUser alloc] initWithDictonary:dict];
        [userArray addObject:channelUser];
    }
    self.groupUsers = userArray;
}

-(NSNumber *)getChannelMemberParentKey:(NSString *)userId
{
    for(ALChannelUser * channelUser in self.groupUsers)
    {
        if(userId && [userId isEqualToString:channelUser.userId])
        {
            return channelUser.parentGroupKey;
        }
    }
    
    return nil;
}

-(BOOL)isNotificationMuted{
    
    long secsUtc1970 = [[NSNumber numberWithDouble:[[NSDate date]timeIntervalSince1970] ] longValue ]*1000L;
    if(_notificationAfterTime){
        return ([_notificationAfterTime longValue]> secsUtc1970);
    }
    else {
        return ([self isGroupMutedByDefault]);
    }
}

-(void)setMembersName:(NSMutableArray *)membersName {
    _membersName = membersName;
}

-(NSMutableArray *)membersName
{
//    return _membersName ? _membersName : self.membersId;
    return self.membersId;
}

-(NSString*)getReceiverIdInGroupOfTwo{
    
    if(self.type!=GROUP_OF_TWO){
        return nil;
    }
    
    for(NSString* userId in self.membersName)
    {
        if(!([userId isEqualToString:[ALUserDefaultsHandler getUserId]]) ){
            return userId;
        }
    }
    return nil;
}

-(NSMutableDictionary *)getMetaDataDictionary:(NSString *)string
{
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSPropertyListFormat format;
    NSMutableDictionary * dictionary;

    @try
    {
        NSError * error;
        dictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable
                                                                        format:&format
                                                                         error:&error];
        if(!dictionary)
        {
//            NSLog(@"ERROR: COULD NOT PARSE META-DATA : %@", error.description);
        }
    }
    @catch(NSException * exp)
    {
//         NSLog(@"METADATA_DICTIONARY_EXCEPTION :: %@", exp.description);
    }
    
    return dictionary;
}

-(BOOL)isGroupMutedByDefault{
    
    if( _metadata && [_metadata  valueForKey:CHANNEL_DEFAULT_MUTE] ){
        
        return ([ [_metadata  valueForKey:CHANNEL_DEFAULT_MUTE] isEqualToString:@"true"]);
    }
    return NO;
}


-(BOOL)isConversationClosed{

    if( _metadata && [_metadata  valueForKey:CHANNEL_CONVERSATION_STATUS] ){

        return ([ [_metadata  valueForKey:CHANNEL_CONVERSATION_STATUS] isEqualToString:@"CLOSE"]);
    }
    return NO;
}

@end
