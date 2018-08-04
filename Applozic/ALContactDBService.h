//
//  ALContactDBService.h
//  ChatApp
//
//  Created by Devashish on 23/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALContact.h"
#import "DB_CONTACT.h"
#import "ALUserDetail.h"
#import "ALUserBlocked.h"
#import "ALContactsResponse.h"

@interface ALContactDBService : NSObject

-(BOOL)purgeListOfContacts:(NSArray *)contacts;

-(BOOL)purgeContact:(ALContact *)contact;

-(BOOL)purgeAllContact;

-(BOOL)updateListOfContacts:(NSArray *)contacts;

-(BOOL)updateContact:(ALContact *)contact;

-(BOOL)addListOfContacts:(NSArray *)contacts;

-(BOOL)addContact:(ALContact *)userContact;

-(void) updateConnectedStatus: (NSString *) userId lastSeenAt:(NSNumber *) lastSeenAt  connected: (BOOL) connected;

- (DB_CONTACT *)getContactByKey:(NSString *) key value:(NSString*) value;

- (ALContact *)loadContactByKey:(NSString *) key value:(NSString*) value;

-(void)addUserDetails:(NSMutableArray *)userDetails;


-(BOOL)updateUserDetail:(ALUserDetail *)userDetail;

-(BOOL)updateLastSeenDBUpdate:(ALUserDetail *)userDetail;

-(NSUInteger)markConversationAsDeliveredAndRead:(NSString*)contactId;
- (NSArray *)getUnreadMessagesForIndividual:(NSString *)contactId;
-(BOOL)setBlockUser:(NSString *)userId andBlockedState:(BOOL)flag;
-(BOOL)setBlockByUser:(NSString *)userId andBlockedByState:(BOOL)flag;
-(void)blockAllUserInList:(NSMutableArray *)userList;
-(void)blockByUserInList:(NSMutableArray *)userList;
-(NSMutableArray *)getListOfBlockedUsers;

-(BOOL)setUnreadCountDB:(ALContact*)contact;

-(void)updateFilteredContacts:(ALContactsResponse *)contactsResponse;

-(NSMutableArray *)getAllContactsFromDB;
-(NSNumber *)getOverallUnreadCountForContactsFromDB;
-(BOOL)isUserDeleted:(NSString *)userId;
-(void)addUserDetailsWithoutUnreadCount:(NSMutableArray *)userDetails;

@end
