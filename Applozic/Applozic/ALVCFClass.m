//
//  ALVCFClass.m
//  Applozic
//
//  Created by devashish on 09/04/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALVCFClass.h"
#import "UIImage+Utility.h"
#import "ALUtilityClass.h"
@import CoreFoundation;
@import AddressBook;


@implementation ALVCFClass
{
    ABAddressBookRef book;
}
-(NSString *)saveContactToDocumentDirectory:(ABRecordRef)person
{
    NSArray * array = [[NSArray alloc] initWithObjects:(__bridge id _Nonnull)(person), nil];
    CFArrayRef arrayRef = (__bridge CFArrayRef)array;
    NSData * VCFDATA = (__bridge NSData *)(ABPersonCreateVCardRepresentationWithPeople(arrayRef));
 
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * vcfCARDPath = [documentsDirectory stringByAppendingString:
                              [NSString stringWithFormat:@"/CONTACT_%f_CARD.vcf",[[NSDate date] timeIntervalSince1970] * 1000]];
    
    [VCFDATA writeToFile:vcfCARDPath atomically:YES];
    
    return vcfCARDPath;
}

-(void)parseVCFData:(NSString *)vcfFilePath
{
    NSData *vcard = [NSData dataWithContentsOfFile:vcfFilePath];
    [self addVCardToContacts:vcard];
    
//////////////////////////////////// AUTHORIZATION FOR CONTACT (IF NEEDED) //////////////////////////////////
    
//    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
//    {
//        NSLog(@"AUTHORISED");
////        [ALUtilityClass showAlertMessage:@"CONTACT PERMISSION AUTHORISED" andTitle:@"Contacts"];
//        [self addVCardToContacts:vcard];
//    }
//    else
//    {
//        NSLog(@"===================== NOT_DETERMINED ======================");
//        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error)
//        {
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 
//                if (!granted)
//                {
//                    NSLog(@"JUST_DENIED");
//    //                [ALUtilityClass showAlertMessage:@"CONTACT PERMISSION DENIED" andTitle:@"Contacts"];
//                    return;
//                }
//                
//                NSLog(@"JUST_AUTHORISED");
//    //            [ALUtilityClass showAlertMessage:@"CONTACT PERMISSION JUST AUTHORISED" andTitle:@"Contacts"];
//                [self addVCardToContacts:vcard];
//            });
//        });
//    }
    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
}

- (void)addVCardToContacts:(NSData *)vcard
{
    
    if(vcard == nil || vcard.length == 0 ){
        return;
    }
    
    CFDataRef vCardData = CFDataCreate(NULL, [vcard bytes], [vcard length]);
    book = ABAddressBookCreate();
    ABRecordRef personInfo = ABAddressBookCopyDefaultSource(book);
        
    ABRecordRef person = nil;
    CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(personInfo, vCardData);

    self.fullName = @"";
    
    CFErrorRef CFerror = NULL;
    
    if(CFArrayGetCount(vCardPeople) == 1)
    {
        person = CFArrayGetValueAtIndex(vCardPeople,(CFIndex)0);
        ABAddressBookAddRecord(book, person, &CFerror);
        CFRelease(person);
    }
    
    NSError *theError = (__bridge NSError *)CFerror;
    NSLog(@"ERROR VCARD (IF ANY) :: %@",theError.description);
    
    // get the first name
    self.firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);

    // get the last name
    self.lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    if(self.firstName)
    {
        self.fullName = self.firstName;
    }
    
    if(self.lastName)
    {
        self.fullName = [NSString stringWithFormat:@"%@ %@", self.fullName, self.lastName];
    }
    
    //get the phone no.
    ABMultiValueRef phone = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFStringRef phoneID = ABMultiValueCopyValueAtIndex(phone, 0);
    
    self.phoneNumber = (__bridge NSString *)(phoneID);
    
    NSString *ph2 = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phone, 1));
    if(ph2)
    {
        self.phoneNumber = [NSString stringWithFormat:@"%@\n%@",self.phoneNumber,ph2];
    }
    
    // get the emailid
    ABMultiValueRef email = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonEmailProperty);
    CFStringRef emailID = ABMultiValueCopyValueAtIndex(email, 0);
    self.emailID = (__bridge_transfer NSString *)(emailID);

    self.retrievedImage = nil;
    // get personPicture
    if (person != nil && ABPersonHasImageData(person))
    {
        UIImage *tempImage = [UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)];
        self.retrievedImage = [tempImage getCompressedImageLessThanSize:0.5];
    }

}

-(void)showOptionForContact
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Contact"
                                                    message: @"Save Contact"
                                                   delegate: self
                                          cancelButtonTitle: @"CANCEL"
                                          otherButtonTitles: @"SAVE", nil];
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //    if (buttonIndex != [alertView cancelButtonIndex])
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"SAVE"])
    {
        [self saveContact];
    }
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Settings"])
    {
        [ALUtilityClass openApplicationSettings];
    }
}

-(void)saveContact
{
    CFErrorRef CFError = NULL;
    if(!ABAddressBookSave(book, &CFError))
    {
        NSError *error = (__bridge NSError *)CFError;
        NSLog(@"ERROR_IN_SAVE_CONTACT : %@",error.description);
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Application Settings"
                                                             message:@"Enable Contacts Permission"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"Settings", nil];
        
        [alertView show];
        
        return;
    }
    
    [ALUtilityClass showAlertMessage:@"Contact Saved Successfully" andTitle:@"Contact"];
}

@end
