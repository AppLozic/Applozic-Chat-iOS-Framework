//
//  ALDBHandler.m
//  ChatApp
//
//  Created by Gaurav Nigam on 09/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALDBHandler.h"
#import "DB_CONTACT.h"
#import "ALContact.h"

@implementation ALDBHandler

+(ALDBHandler *) sharedInstance
{
    static ALDBHandler *sharedMyManager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedMyManager = [[self alloc] init];
        
    });
    
    return sharedMyManager;
}

- (id)init {
    
    if (self = [super init]) {
        
        
    }
    return self;
}


@synthesize managedObjectContext = _managedObjectContext;

@synthesize managedObjectModel = _managedObjectModel;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    
    // The directory the application uses to store the Core Data store file. This code uses a directory named "tricon-infotech.coredata_demo" in the application's documents directory.
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    
    if (_managedObjectModel != nil) {
        
        return _managedObjectModel;
        
    }
    
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]]URLForResource:@"AppLozic" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    
    if (_persistentStoreCoordinator != nil) {
        
        return _persistentStoreCoordinator;
        
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AppLozic.sqlite"];
    
    NSError *error = nil;
    
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSInferMappingModelAutomaticallyOption:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption:[NSNumber numberWithBool:YES]} error:&error]) {
        
        // Report any error we got.
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        
        dict[NSUnderlyingErrorKey] = error;
        
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        
        // Replace this with code to handle the error appropriately.
        
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    
    if (_managedObjectContext != nil) {
        
        return _managedObjectContext;
        
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (!coordinator) {
        
        return nil;
        
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        
        NSError *error = nil;
        
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            
            // Replace this implementation with code to handle the error appropriately.
            
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
            abort();
        }
    }
}

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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",contact.userId];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    for (DB_CONTACT *userContact in result) {
        
        [self.managedObjectContext deleteObject:userContact];
    }
    
    NSError *deleteError = nil;
    
    success = [self.managedObjectContext save:&deleteError];
    
    if (!success) {
        
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", deleteError, deleteError.localizedDescription);
    }
    
    return success;
}

- (BOOL)purgeAllContact {
    BOOL success = NO;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    NSError *fetchError = nil;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    for (DB_CONTACT *userContact in result) {
        
        [self.managedObjectContext deleteObject:userContact];
    }
    
    NSError *deleteError = nil;
    
    success = [self.managedObjectContext save:&deleteError];
    
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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CONTACT" inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",contact.userId];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    for (DB_CONTACT *userContact in result) {
        
        userContact.userId = contact.userId;
        userContact.email = contact.email;
        userContact.fullName = contact.fullName;
        userContact.contactNumber = contact.contactNumber;
        userContact.contactImageUrl = contact.contactImageUrl;
        userContact.displayName = contact.displayName;
        userContact.localImageResourceName = contact.localImageResourceName;
        if(contact.contactType){
            userContact.contactType = contact.contactType;
        }
        userContact.roleType = contact.roleType;
        userContact.metadata =contact.metadata.description;
    }
    
    NSError *error = nil;
    
    success = [self.managedObjectContext save:&error];
    
    if (!success) {
        
        NSLog(@"DB ERROR :%@",error);
    }
    
    return success;
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

- (ALContact *) loadContactByKey:(NSString *) key value:(NSString*) value {
    DB_CONTACT *dbContact = [self getContactByKey:key value:value];
    ALContact *contact = [[ALContact alloc]init];

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
     contact.contactType = dbContact.contactType;
     contact.roleType = dbContact.roleType;
     contact.metadata = [contact getMetaDataDictionary:dbContact.metadata];

     return contact;
}


- (DB_CONTACT *)getContactByKey:(NSString *) key value:(NSString*) value {
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
        contact.contactNumber = dbContact.contactNumber];
        contact.displayName = dbContact.displayName;
        contact.contactImageUrl = dbContact.contactImageUrl;
        contact.email = dbContact.email;
        contact.localImageResourceName = dbContact.localImageResourceName;
        return contact;*/
        
        return dbContact;
    } else {
        return nil;
    }
}

-(BOOL)addContact:(ALContact *)userContact {
    
    DB_CONTACT* existingContact = [self getContactByKey:@"userId" value:[userContact userId]];
    if (existingContact) {
        return false;
    }
    
    BOOL result = NO;
    
    DB_CONTACT * contact = [NSEntityDescription insertNewObjectForEntityForName:@"DB_CONTACT" inManagedObjectContext:self.managedObjectContext];
    
    contact.userId = userContact.userId;
    
    contact.fullName = userContact.fullName;
    
    contact.contactNumber = userContact.contactNumber;
    
    contact.displayName = userContact.displayName;
    
    contact.email = userContact.email;
    
    contact.contactImageUrl = userContact.contactImageUrl;
    
    contact.localImageResourceName = userContact.localImageResourceName;
    contact.contactType = userContact.contactType;
    contact.roleType = userContact.roleType;
    contact.metadata = userContact.metadata.description;
    
    NSError *error = nil;
    
    result = [self.managedObjectContext save:&error];
    
    if (!result) {
        NSLog(@"DB ERROR :%@",error);
    }
    
    return result;
}



@end
