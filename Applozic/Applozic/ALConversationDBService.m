//
//  ALConversationDBService.m
//  Applozic
//
//  Created by Devashish on 27/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALConversationDBService.h"
#import "ALDBHandler.h"

@implementation ALConversationDBService

-(void)insertConversationProxy:(NSMutableArray *)proxyArray
{
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    
    for(ALConversationProxy *proxy in proxyArray){
        
        [self createConversationProxy:proxy];
    }
    
    NSError *error = nil;
    if(![theDBHandler.managedObjectContext save:&error])
    {
        NSLog(@"ERROR: InsertConversationProxy METHOD %@",error);
    }
    
}

-(void)insertConversationProxyTopicDetails:(NSMutableArray*)proxyArray{
    
   
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    
    for(ALConversationProxy *proxy in proxyArray)
    {
        DB_ConversationProxy *dbConversationProxy = [self getConversationProxyByKey:proxy.Id];
        if(!dbConversationProxy){
        dbConversationProxy.topicDetailJson = proxy.topicDetailJson;
        }
    }
    
    NSError *error = nil;
    [theDBHandler.managedObjectContext save:&error];
    if(error)
    {
        NSLog(@"ERROR: TopicDetails Insert METHOD %@",error);
    }
    else{
        NSLog(@"SUCCESS: TopicDetails Insertion in DB ");
    }

}

-(DB_ConversationProxy *)createConversationProxy:(ALConversationProxy *)conversationProxy
{
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    DB_ConversationProxy *dbConversationProxy = [self getConversationProxyByKey:conversationProxy.Id];
    if(!dbConversationProxy)
    {
        dbConversationProxy = [NSEntityDescription insertNewObjectForEntityForName:@"DB_ConversationProxy" inManagedObjectContext:theDBHandler.managedObjectContext];
    }
    dbConversationProxy.iD=conversationProxy.Id;
    dbConversationProxy.topicId = conversationProxy.topicId;
    dbConversationProxy.groupId = conversationProxy.groupId;
    dbConversationProxy.created = [NSNumber numberWithBool:conversationProxy.created];
    dbConversationProxy.closed = [NSNumber numberWithBool:conversationProxy.closed];
    dbConversationProxy.userId = conversationProxy.userId;
    dbConversationProxy.topicDetailJson = conversationProxy.topicDetailJson;
    return dbConversationProxy;
}


-(DB_ConversationProxy *)getConversationProxyByKey:(NSNumber *)Id
{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_ConversationProxy" inManagedObjectContext:dbHandler.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD = %@",Id];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    if (result.count)
    {
        DB_ConversationProxy *proxy = [result objectAtIndex:0];
        return proxy;
    }
    else
    {
        return nil;
    }
}

-(NSArray*)getConversationProxyListFromDBForUserID:(NSString*)userId{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_ConversationProxy" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate;
    if (userId)
    {
        predicate = [NSPredicate predicateWithFormat:@"userId = %@",userId];
    }
    else{
        NSLog(@"Error");
    }
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[predicate]]];
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    if (result.count)
    {
        return result;
        
    }
    else{
        return nil;
    }
    
}

-(NSArray*)getConversationProxyListFromDBForUserID:(NSString*)userId andTopicId:(NSString*)topicId{
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_ConversationProxy" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate;
    if (userId)
    {
        predicate = [NSPredicate predicateWithFormat:@"userId == %@ && topicId == %@",userId,topicId];
    }
    else{
        NSLog(@"Error");
    }
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[predicate]]];
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    if (result.count){
        return result;
    }
    else{
        return nil;
    }
    
}


-(NSArray*)getConversationProxyListFromDBWithChannelKey:(NSNumber *)channelKey{
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_ConversationProxy" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate;
    if(channelKey){
        predicate = [NSPredicate predicateWithFormat:@"groupId = %@",channelKey];
    }
    else{
        NSLog(@"Error");
    }
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[predicate]]];
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    if (result.count){
        return result;
        
    }
    else{
        return nil;
    }
    
}

@end
