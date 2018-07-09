//
//  ALDBHandler.h
//  ChatApp
//
//  Created by Gaurav Nigam on 09/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DB_CONTACT.h"

@class ALContact;

@interface ALDBHandler : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;

+(ALDBHandler *) sharedInstance;

-(BOOL)purgeListOfContacts:(NSArray *)contacts;

-(BOOL)purgeContact:(ALContact *)contact;

-(BOOL)purgeAllContact;

-(BOOL)updateListOfContacts:(NSArray *)contacts;

-(BOOL)updateContact:(ALContact *)contact;

-(BOOL)addListOfContacts:(NSArray *)contacts;

-(BOOL)addContact:(ALContact *)userContact;

- (DB_CONTACT *)getContactByKey:(NSString *) key value:(NSString*) value;

- (ALContact *)loadContactByKey:(NSString *) key value:(NSString*) value;

@end
