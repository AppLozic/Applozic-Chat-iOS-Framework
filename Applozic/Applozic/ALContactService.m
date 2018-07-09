//
//  ALContactService.m
//  ChatApp
//
//  Created by Devashish on 23/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALContactService.h"
#import "ALContactDBService.h"
#import "ALDBHandler.h"
#import "ALUserDefaultsHandler.h"
#import "ALUserService.h"

@implementation ALContactService

 ALContactDBService * alContactDBService;

-(instancetype)  init{
    self= [super init];
    alContactDBService = [[ALContactDBService alloc] init];
    return self;
}

#pragma mark Deleting APIS


//For purgeing single contacts

-(BOOL)purgeContact:(ALContact *)contact{
    
    return [alContactDBService purgeContact:contact];
}


//For purgeing multiple contacts
-(BOOL)purgeListOfContacts:(NSArray *)contacts{
    
    return [ alContactDBService purgeListOfContacts:contacts];
}


//For delting all contacts at once

-(BOOL)purgeAllContact{
  return  [alContactDBService purgeAllContact];
    
}

#pragma mark Update APIS


-(BOOL)updateContact:(ALContact *)contact{
    return [alContactDBService updateContact:contact];
    
}

-(BOOL)setUnreadCountInDB:(ALContact*)contact{
    return [alContactDBService setUnreadCountDB:contact];
}

-(BOOL)updateListOfContacts:(NSArray *)contacts{
    return [alContactDBService updateListOfContacts:contacts];
}

-(NSNumber *)getOverallUnreadCountForContact
{
   return  [alContactDBService getOverallUnreadCountForContactsFromDB];
}

-(BOOL) isContactExist:(NSString *) value{
   
    DB_CONTACT* contact= [alContactDBService getContactByKey:@"userId" value:value];
    return !(contact.lastSeenAt==nil);
    
}
#pragma update OR insert contact

-(BOOL) updateOrInsert:(ALContact*)contact{
    
    return ([self isContactExist:contact.userId]) ? [self updateContact:contact] : [self addContact:contact];

}

-(void)updateOrInsertListOfContacts:(NSMutableArray *)contacts {
    
    for(ALContact* conatct in contacts){
        [self updateOrInsert:conatct];
    }
}

#pragma mark addition APIS


-(BOOL)addListOfContacts:(NSArray *)contacts{
    return [alContactDBService updateListOfContacts:contacts];

}

-(BOOL)addContact:(ALContact *)userContact{
    return [alContactDBService addContact:userContact];

}

#pragma mark fetching APIS


- (ALContact *)loadContactByKey:(NSString *) key value:(NSString*) value

{
    return [alContactDBService loadContactByKey:key value:value];

}

#pragma mark fetching OR SAVE with Serevr call...


- (ALContact *)loadOrAddContactByKeyWithDisplayName:(NSString *) contactId value:(NSString*) displayName{
    
    DB_CONTACT * dbContact = [alContactDBService getContactByKey:@"userId" value:contactId];
    
    ALContact *contact = [[ALContact alloc] init];
    if (!dbContact)
    {
        contact.userId = contactId;
        contact.displayName = displayName;
        [self addContact:contact];
        [ALUserService updateUserDisplayName:contact];
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
    contact.unreadCount= dbContact.unreadCount;
    contact.userStatus = dbContact.userStatus;
    contact.deletedAtTime = dbContact.deletedAtTime;
    contact.roleType = dbContact.roleType;
    contact.metadata = [contact getMetaDataDictionary:dbContact.metadata];
    
    return contact;
}

-(BOOL)isUserDeleted:(NSString *)userId
{
    return [alContactDBService isUserDeleted:userId];
}

@end
