//
//  ALContactDBService.m
//  ChatApp
//
//  Created by Devashish on 23/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALContactDBService.h"
#import "ALDBHandler.h"
#import "ALConstant.h"
#import "DB_Message.h"

@implementation ALContactDBService

#pragma mark - Delete Contacts API -


- (BOOL)purgeListOfContacts:(NSArray *)contacts {
    BOOL result = NO;
    
    for (ALContact *contact in contacts) {
        
        result = [self purgeContact:contact];
        
        if (!result) {
            
            NSLog(@"Failure to delete the contacts");
            break;
        }
    }
    
    return result;
}

- (BOOL)purgeContact:(ALContact *)contact {
    
    BOOL success = NO;
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];


    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",contact.userId];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    for (DB_CONTACT *userContact in result) {
        
        [dbHandler.managedObjectContext deleteObject:userContact];
    }
    
    NSError *deleteError = nil;
    
    success = [dbHandler.managedObjectContext save:&deleteError];
    
    if (!success) {
        
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", deleteError, deleteError.localizedDescription);
    }
    
    return success;
}

- (BOOL)purgeAllContact
{
    BOOL success = NO;
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    NSError *fetchError = nil;
    
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    for (DB_CONTACT *userContact in result) {
        
        [dbHandler.managedObjectContext deleteObject:userContact];
    }
    
    NSError *deleteError = nil;
    
    success = [dbHandler.managedObjectContext save:&deleteError];
    
    if (!success) {
        
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", deleteError, deleteError.localizedDescription);
    }
    
    return success;
}

#pragma mark - Update Contacts API -

- (BOOL)updateListOfContacts:(NSArray *)contacts {
    
    BOOL result = NO;
    
    for (ALContact *contact in contacts) {
        
        result = [self updateContact:contact];
        
        if (!result) {
            
            NSLog(@"Failure to update the contacts");
            break;
        }
    }
    
    return result;
}

- (BOOL)updateContact:(ALContact *)contact {
    
    BOOL success = NO;
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",contact.userId];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    for (DB_CONTACT * userContact in result) {
        
        userContact.userId = contact.userId;
        userContact.email = contact.email;
        userContact.fullName = contact.fullName;
        userContact.contactNumber = contact.contactNumber;
        userContact.contactImageUrl = contact.contactImageUrl;
        userContact.unreadCount = contact.unreadCount ? contact.unreadCount : [NSNumber numberWithInt:0];
        if(contact.email){
            userContact.email = contact.email;
        }
        if(contact.fullName){
            userContact.fullName = contact.fullName;
        }
        if(contact.contactNumber){
            userContact.contactNumber = contact.contactNumber;
        }
        if(contact.contactImageUrl){
            userContact.contactImageUrl = contact.contactImageUrl;
        }
        
        if(contact.unreadCount != nil && [contact.unreadCount  compare:[NSNumber numberWithInt:0]] != NSOrderedSame){
            userContact.unreadCount = contact.unreadCount;
        }
    
        userContact.userStatus = contact.userStatus;
        userContact.connected = contact.connected;
        if(contact.displayName)
        {
            userContact.displayName = contact.displayName;
        }
        if(contact.contactType){
            userContact.contactType = contact.contactType;
        }
        userContact.localImageResourceName = contact.localImageResourceName;
        userContact.deletedAtTime = contact.deletedAtTime;
        userContact.roleType = contact.roleType;
        userContact.metadata = contact.metadata.description;
    }
    
    NSError *error = nil;
    
    success = [dbHandler.managedObjectContext save:&error];
    
    if (!success) {
        
        NSLog(@"updateContactFERROR :%@",error);
    }
    
    return success;
}

-(BOOL)setUnreadCountDB:(ALContact*)contact{
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",contact.userId];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *fetchError = nil;
    
    
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if(result.count > 0)
    {
        DB_CONTACT * dbContact = [result objectAtIndex:0];
        dbContact.unreadCount = [NSNumber numberWithInt:0];
    }
    
    NSError *error = nil;
    if (![dbHandler.managedObjectContext save:&error]) {
        
        NSLog(@"DB ERROR :%@",error);
        return NO;
    }
    
    return YES;
    
}

#pragma mark - Add Contacts API -

- (BOOL)addListOfContacts:(NSArray *)contacts {
    
    BOOL result = NO;
    
    for (ALContact *contact in contacts) {
        
        result = [self addContact:contact];
        
        if (!result) {
            break;
        }
    }
    
    return result;
}

- (ALContact *) loadContactByKey:(NSString *) key value:(NSString*) value
{
    DB_CONTACT *dbContact = [self getContactByKey:key value:value];
    ALContact *contact = [[ALContact alloc] init];
    
    if (!dbContact) {
        contact.userId = value;
        contact.displayName = value;
        return contact;
    }
    contact.userId = dbContact.userId;
    contact.fullName = dbContact.fullName;
    contact.contactNumber = dbContact.contactNumber;
    contact.displayName = dbContact.displayName;
    contact.contactImageUrl = dbContact.contactImageUrl;
    contact.email = dbContact.email;
    contact.localImageResourceName = dbContact.localImageResourceName;
    contact.connected = dbContact.connected;
    contact.lastSeenAt = dbContact.lastSeenAt;
    contact.unreadCount=dbContact.unreadCount;
    contact.block = dbContact.block;
    contact.blockBy = dbContact.blockBy;
    contact.userStatus = dbContact.userStatus;
    contact.deletedAtTime = dbContact.deletedAtTime;
    contact.metadata = [contact getMetaDataDictionary:dbContact.metadata];
    contact.roleType = dbContact.roleType;
    
    return contact;
}


- (DB_CONTACT *)getContactByKey:(NSString *) key value:(NSString*) value
{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@",key,value];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if (result.count > 0) {
        DB_CONTACT* dbContact = [result objectAtIndex:0];
        /* ALContact *contact = [[ALContact alloc]init];
         contact.userId = dbContact.userId;
         contact.fullName = dbContact.fullName;
         contact.contactNumber = dbContact.contactNumber;
         contact.displayName = dbContact.displayName;
         contact.contactImageUrl = dbContact.contactImageUrl;
         contact.email = dbContact.email;
         return contact;*/
        return dbContact;
    } else {
        return nil;
    }
}

-(BOOL)addContact:(ALContact *)userContact {
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];

    DB_CONTACT* existingContact = [self getContactByKey:@"userId" value:[userContact userId]];
    if (existingContact) {
        return NO;
    }
    
    BOOL result = NO;
    
    DB_CONTACT * contact = [NSEntityDescription insertNewObjectForEntityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    
    contact.userId = userContact.userId;
    contact.fullName = userContact.fullName;
    contact.contactNumber = userContact.contactNumber;
    contact.displayName = userContact.displayName;
    contact.email = userContact.email;
    contact.contactImageUrl = userContact.contactImageUrl;
    contact.localImageResourceName = userContact.localImageResourceName;
    contact.unreadCount = userContact.unreadCount ? userContact.unreadCount : [NSNumber numberWithInt:0];
    contact.lastSeenAt = userContact.lastSeenAt;
    contact.userStatus = userContact.userStatus;
    contact.connected = userContact.connected;
    contact.contactType = userContact.contactType;
    contact.userTypeId = userContact.userTypeId;
    contact.deletedAtTime = userContact.deletedAtTime;
    contact.metadata = userContact.metadata.description;
    contact.roleType = userContact.roleType;

    
    NSError *error = nil;
    
    result = [dbHandler.managedObjectContext save:&error];
    
    if (!result) {
        NSLog(@"addContact DB ERROR :%@",error);
    }
    
    return result;
}


-(void)addUserDetails:(NSMutableArray *)userDetails
{
    for(ALUserDetail *theUserDetail in userDetails)
    {
        [self updateUserDetail:theUserDetail];
    }
}

-(void)addUserDetailsWithoutUnreadCount:(NSMutableArray *)userDetails
{
    for(ALUserDetail *theUserDetail in userDetails)
    {
        theUserDetail.unreadCount = 0;
        [self updateUserDetail:theUserDetail];
    }
}

-(void) updateConnectedStatus: (NSString *) userId lastSeenAt:(NSNumber *) lastSeenAt  connected: (BOOL) connected
{
    ALUserDetail *ob = [[ALUserDetail alloc] init];
    ob.lastSeenAtTime = lastSeenAt;
    ob.connected =  connected;
    ob.userId = userId;
    
    [self updateUserDetail:ob];
}

-(BOOL)updateUserDetail:(ALUserDetail *)userDetail
{
    BOOL success = NO;
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",userDetail.userId];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if(result.count > 0)
    {
        
        DB_CONTACT * dbContact = [result objectAtIndex:0];
        dbContact.lastSeenAt = userDetail.lastSeenAtTime;
        dbContact.connected = userDetail.connected;
        if(userDetail.unreadCount != nil && [userDetail.unreadCount  compare:[NSNumber numberWithInt:0]] != NSOrderedSame){
            dbContact.unreadCount = userDetail.unreadCount;
        }
        
        if(userDetail.displayName)
        {
            dbContact.displayName = userDetail.displayName;
        }
        dbContact.contactImageUrl = userDetail.imageLink;
        dbContact.contactNumber = userDetail.contactNumber;
        dbContact.userStatus = userDetail.userStatus;
        dbContact.deletedAtTime = userDetail.deletedAtTime;
        dbContact.metadata = userDetail.metadata.description;
        dbContact.roleType = userDetail.roleType;

    }
    else
    {
         // Add contact in DB.
        ALContact * contact = [[ALContact alloc] init];
        contact.userId = userDetail.userId;
        contact.unreadCount = userDetail.unreadCount;
        contact.lastSeenAt = userDetail.lastSeenAtTime;
        contact.displayName = userDetail.displayName;
        contact.contactImageUrl = userDetail.imageLink;
        contact.contactNumber = userDetail.contactNumber;
        contact.connected = userDetail.connected;
        contact.userStatus = userDetail.userStatus;
        contact.deletedAtTime = userDetail.deletedAtTime;
        contact.roleType = userDetail.roleType;
        contact.metadata = userDetail.metadata;
        [self addContact:contact];
    }
    
    NSError *error = nil;
    success = [dbHandler.managedObjectContext save:&error];
    
    if (!success) {
        
        NSLog(@"DB ERROR :%@",error);
    }
    
    return success;

}
-(BOOL)updateLastSeenDBUpdate:(ALUserDetail *)userDetail
{
    BOOL success = NO;
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",userDetail.userId];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if(result.count > 0)
    {
        DB_CONTACT * dbContact = [result objectAtIndex:0];
        dbContact.connected = userDetail.connected;
        dbContact.lastSeenAt = userDetail.lastSeenAtTime;
    }
    
    NSError *error = nil;
    success = [dbHandler.managedObjectContext save:&error];
    
    if (!success) {
        
        NSLog(@"DB ERROR :%@",error);
    }
    
    return success;
}

-(NSUInteger)markConversationAsDeliveredAndRead:(NSString*)contactId
{
    NSArray *messages =  [self getUnreadMessagesForIndividual:contactId];

    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    for (DB_Message *dbMessage in messages)
    {
        dbMessage.status = @(DELIVERED_AND_READ);
    }
    NSError *error = nil;
    [dbHandler.managedObjectContext save:&error];
    NSLog(@"ERROR(IF-ANY) WHILE UPDATING DELIVERED_AND_READ : %@",error.description);
    
    return messages.count;
}

- (NSArray *)getUnreadMessagesForIndividual:(NSString *)contactId {
    
    //Runs at Opening AND Leaving ChatVC AND Opening MessageList..
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_Message" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate;
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"status != %i AND type==%@ ",DELIVERED_AND_READ,@"4"];
    
    if (contactId) {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K=%@",@"contactId",contactId];
        NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"groupId==%d OR groupId==%@",0,NULL];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2,predicate3]];
    } else {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate2]];
    }
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    return result;
}

-(BOOL)setBlockUser:(NSString *)userId andBlockedState:(BOOL)flag
{
    BOOL success = NO;
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",userId];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if(result.count > 0)
    {
        DB_CONTACT *resultDBContact = [result objectAtIndex:0];
        resultDBContact.block = flag;
    }

    NSError *error = nil;
    success = [dbHandler.managedObjectContext save:&error];
    
    if (!success)
    {
        NSLog(@"DB ERROR FOR BLOCKING/UNBLOCKING USER %@ :%@",userId, error);
    }
    return success;
}

-(void)blockAllUserInList:(NSMutableArray *)userList
{
    for(ALUserBlocked *userBlocked in userList)
    {
        [self setBlockUser:userBlocked.blockedTo andBlockedState:userBlocked.userBlocked];
    }
}

-(void)blockByUserInList:(NSMutableArray *)userList
{
    for(ALUserBlocked *userBlocked in userList)
    {
        [self setBlockByUser:userBlocked.blockedBy andBlockedByState:userBlocked.userblockedBy];
    }
}

-(BOOL)setBlockByUser:(NSString *)userId andBlockedByState:(BOOL)flag
{
    BOOL success = NO;
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",userId];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if(result.count > 0)
    {
        DB_CONTACT *resultDBContact = [result objectAtIndex:0];
        resultDBContact.blockBy = flag;
    }
    
    NSError *error = nil;
    success = [dbHandler.managedObjectContext save:&error];
    
    if (!success)
    {
        NSLog(@"DB ERROR FOR BLOCKED BY USER %@ :%@", userId, error);
    }
    return success;
}

-(NSMutableArray *)getListOfBlockedUsers
{
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:theDBHandler.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *array = [theDBHandler.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray * userList = [[NSMutableArray alloc] init];
    
    if(array.count)
    {
        for(DB_CONTACT *contact in array)
        {
            if(contact.block)
            {
                [userList addObject:contact.userId];
            }
        }
    }
    else
    {
        NSLog(@"NO BLOCKED USER FOUND");
    }
    
    return userList;
}

-(void)updateFilteredContacts:(ALContactsResponse *)contactsResponse 
{
    NSMutableArray * contactArray = [NSMutableArray new];
    for(ALUserDetail * userDetail in contactsResponse.userDetailList)
    {
        userDetail.unreadCount = 0;
        [self updateUserDetail:userDetail];
        ALContact * contact = [self loadContactByKey:@"userId" value: userDetail.userId];
        [contactArray addObject:contact];
    }
}

-(NSMutableArray *)getAllContactsFromDB
{
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CONTACT"];
    [theRequest setReturnsDistinctResults:YES];
    
    NSMutableArray * contactList = [NSMutableArray new];
    NSArray * theArray = [theDbHandler.managedObjectContext executeFetchRequest:theRequest error:nil];
    
    for (DB_CONTACT * dbContact in theArray)
    {
        ALContact *contact = [[ALContact alloc] init];
        
        contact.userId = dbContact.userId;
        contact.fullName = dbContact.fullName;
        contact.contactNumber = dbContact.contactNumber;
        contact.displayName = dbContact.displayName;
        contact.contactImageUrl = dbContact.contactImageUrl;
        contact.email = dbContact.email;
        contact.localImageResourceName = dbContact.localImageResourceName;
        contact.unreadCount = dbContact.unreadCount;
        contact.userStatus = dbContact.userStatus;
        contact.connected = dbContact.connected;
        contact.deletedAtTime = dbContact.deletedAtTime;
        contact.roleType = dbContact.roleType;
        contact.metadata = [contact getMetaDataDictionary:dbContact.metadata];
        
        [contactList addObject:contact];
    }

    return contactList;
    
}

-(NSNumber *)getOverallUnreadCountForContactsFromDB
{
    NSNumber * unreadCount;
    int count = 0;
    NSMutableArray * contactArray = [NSMutableArray arrayWithArray:[self getAllContactsFromDB]];
    for(ALContact *contact in contactArray)
    {
        count = count + [contact.unreadCount intValue];
    }
    unreadCount = [NSNumber numberWithInt:count];
    return unreadCount;
}

-(BOOL)isUserDeleted:(NSString *)userId
{
    ALContact * contact = [self loadContactByKey:@"userId" value:userId];
    return contact.deletedAtTime ? YES : NO;
}

@end
