//
//  ALGroupCreationViewController.m
//  Applozic
//
//  Created by Divjyot Singh on 13/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

//groupNameInput
//groupIcon
#define DEFAULT_GROUP_ICON_IMAGE ([UIImage imageNamed:@"applozic_group_icon.png"])

#import "ALGroupCreationViewController.h"
#import "ALNewContactsViewController.h"
#import "ALChatViewController.h"
#import "ALConnection.h"
#import "ALConnectionQueueHandler.h"
#import "UIImage+Utility.h"
#import "ALApplozicSettings.h"
#import "ALUtilityClass.h"
#import "ALConnection.h"
#import "ALConnectionQueueHandler.h"
#import "ALUserDefaultsHandler.h"
#import "ALImagePickerHandler.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALNotificationView.h"
#import "ALDataNetworkConnection.h"
#import "ALRegisterUserClientService.h"
#import "UIImageView+WebCache.h"
#import "ALContactService.h"
#import "ALVOIPNotificationHandler.h"

@interface ALGroupCreationViewController ()

@property (nonatomic,strong) UIImagePickerController * mImagePicker;
@property (nonatomic,strong) NSString * mainFilePath;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ALGroupCreationViewController
{
    UIBarButtonItem *nextContacts;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    nextContacts = [[UIBarButtonItem alloc] init];
    [nextContacts setStyle:UIBarButtonItemStylePlain];
    [nextContacts setTarget:self];

    self.navigationItem.rightBarButtonItem = nextContacts;
    
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.groupNameInput.textAlignment = NSTextAlignmentRight;
    }
    
    
    self.groupNameInput.placeholder = NSLocalizedStringWithDefaultValue(@"groupNameTextField", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Type your group name", @"");
    
    [self.descriptionTextView setText: NSLocalizedStringWithDefaultValue(@"descriptionTextForGroup", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Please provide group name", @"")];
    
    if(self.isViewForUpdatingGroup)
    {
        [self setTitle:NSLocalizedStringWithDefaultValue(@"groupUpdateViewText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Group Update", @"")];
        [nextContacts setTitle:NSLocalizedStringWithDefaultValue(@"updateUiButtonText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Update", @"")];
        [nextContacts setAction:@selector(updateGroupInfo:)];
        self.groupNameInput.text = self.channelName;
        [self setProfileImage];
    }
    else
    {   [self setTitle:NSLocalizedStringWithDefaultValue(@"groupTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Create Group", @"")];
        [nextContacts setTitle:NSLocalizedStringWithDefaultValue(@"nextUiButtonText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Next", @"")];
        [nextContacts setAction:@selector(launchContactSelection:)];
    }
    
    
    self.automaticallyAdjustsScrollViewInsets = NO; //setting to NO helps show UITextView's text at view load
    [self setupGroupIcon];
    
    self.mImagePicker = [[UIImagePickerController alloc] init];
    self.mImagePicker.delegate = self;
    self.mImagePicker.allowsEditing = YES;
    
    [self.activityIndicator setHidesWhenStopped:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.groupNameInput becomeFirstResponder];
    self.descriptionTextView.hidden = NO;
    self.descriptionTextView.userInteractionEnabled = NO;
    [self.tabBarController.tabBar setHidden:YES];
    // self.alNewContactViewController.delegateGroupCreation = self;
}

-(void)setProfileImage
{
    NSURL *imageURL = [NSURL URLWithString:self.groupImageURL];
    if(imageURL.path.length)
    {
        [self.groupIconView sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageRefreshCached];
    }
    else
    {
        [self.groupIconView setImage:DEFAULT_GROUP_ICON_IMAGE];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

//=========================================================================================================================================
#pragma mark - NAVIGATION RIGHT BUTTON SELECTORS : CREATION/UPDATE
//=========================================================================================================================================

- (void)launchContactSelection:(id)sender
{
    //Check if group name text is empty
    if([self.groupNameInput.text isEqualToString:@""])
    {
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle: NSLocalizedStringWithDefaultValue(@"groupNameInfo", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Group Name", @"")
                                              message: NSLocalizedStringWithDefaultValue(@"groupNameEmptyAlertMessage", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Please give the group name.", @"")
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [ALUtilityClass setAlertControllerFrame:alertController andViewController:self];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringWithDefaultValue(@"okText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"OK", @"")                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    //Moving forward to member selection
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                         bundle:[NSBundle bundleForClass:ALGroupCreationViewController.class]];
    ALNewContactsViewController *contactsVC = [storyboard instantiateViewControllerWithIdentifier:@"ALNewContactsViewController"];
    
    //Setting groupName and forGroup flag
    contactsVC.forGroup = [NSNumber numberWithInt:GROUP_CREATION];
    contactsVC.groupName = self.groupNameInput.text;
    contactsVC.groupImageURL = self.groupImageURL;
    
    if([ALApplozicSettings getSubGroupLaunchFlag])
    {
        ALChannelService *channelService = [ALChannelService new];
        ALChannel *parentChannel = [channelService getChannelByKey:self.parentChannelKey];
        contactsVC.parentChannel = parentChannel;
        contactsVC.childChannels = [[NSMutableArray alloc] initWithArray:[channelService fetchChildChannelsWithParentKey:parentChannel.key]];
    }
    
    //Moving to contacts view for group member selection
    [self.navigationController pushViewController:contactsVC animated:YES];
}

- (void)updateGroupInfo:(id)sender
{
    if(!self.groupNameInput.text.length)
    {
        [ALUtilityClass showAlertMessage:
         NSLocalizedStringWithDefaultValue(@"youHaveNotUpdatedAnything", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"You haven't update anything", @"")  andTitle:NSLocalizedStringWithDefaultValue(@"wait", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Wait!!!", @"")];
        return;

    }
    [self.loadingIndicator startAnimating];
    
    self.groupImageURL = self.groupImageURL ? self.groupImageURL : @"";
    ALChannelService *channelService = [ALChannelService new];

    
    [channelService updateChannel:self.channelKey andNewName:self.groupNameInput.text
                      andImageURL:self.groupImageURL orClientChannelKey:nil isUpdatingMetaData:NO
                         metadata:nil orChildKeys:nil orChannelUsers:nil  withCompletion:^(NSError *error) {
        
          if(!error)
          {
        
              [ALUtilityClass showAlertMessage:NSLocalizedStringWithDefaultValue(@"groupSuccessFullyUpdateInfo", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Group information successfully updated", @"") andTitle:NSLocalizedStringWithDefaultValue(@"responseText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Response", @"")];
              [self.navigationController popViewControllerAnimated:YES];
              [self.grpInfoDelegate updateGroupInformation];
          }
          [self.loadingIndicator stopAnimating];
    }];
}

//=========================================================================================================================================
#pragma mark - GROUP ICON VIEW SETUP
//=========================================================================================================================================

-(void)setupGroupIcon
{
    dispatch_async(dispatch_get_main_queue(), ^{
          self.groupIconView.layer.cornerRadius = self.groupIconView.frame.size.width/2;
          self.groupIconView.layer.masksToBounds = YES;
          self.groupIconView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    });
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(uploadImage)];
    singleTap.numberOfTapsRequired = 1;
    [self.groupIconView addGestureRecognizer:singleTap];
}


-(void)uploadImage
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [ALUtilityClass setAlertControllerFrame:alertController andViewController:self];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"cancelOptionText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Cancel", @"") style:UIAlertActionStyleCancel handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"photoLibraryText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Photo Library", @"")style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self uploadByPhotos];
    }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"takePhotoText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Take Photo", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self uploadByCamera];
    }]];
    
    if(self.isViewForUpdatingGroup && self.groupImageURL.length)
    {
        UIAlertAction * removeAction = [UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"removePhoto", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Remove Photo", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            self.groupImageURL = @"";
            [self setProfileImage];
        }];
        
        [removeAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
        [alertController addAction:removeAction];
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)uploadByPhotos
{
    self.mImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.mImagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    [self presentViewController:self.mImagePicker animated:YES completion:nil];
}

-(void)uploadByCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (granted)
                {
                    self.mImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    self.mImagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
                    [self presentViewController:self.mImagePicker animated:YES completion:nil];
                }
                else
                {
                    
                    [ALUtilityClass permissionPopUpWithMessage:NSLocalizedStringWithDefaultValue(@"permissionPopMessageForCamera", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Enable Camera Permission", @"") andViewController:self];
                }
            });
        }];
    }
    else
    {
        [ALUtilityClass showAlertMessage:NSLocalizedStringWithDefaultValue(@"permissionNotAvailableMessageForCamera", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Camera is not Available !!!", @"") andTitle:NSLocalizedStringWithDefaultValue(@"oppsText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"OPPS !!", @"")];
        
        
    }
}


//=========================================================================================================================================
#pragma mark - IMAGE PICKER DELEGATES
//=========================================================================================================================================

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage * rawImage = [info valueForKey:UIImagePickerControllerEditedImage];
    UIImage * normalizedImage = [ALUtilityClass getNormalizedImage:rawImage];
    [self.groupIconView setImage:normalizedImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.mainFilePath = [self getImageFilePath:normalizedImage];
    [self confirmUserForGroupImage:normalizedImage];
}

-(NSString *)getImageFilePath:(UIImage *)image
{
    NSString *filePath = [ALImagePickerHandler saveImageToDocDirectory:image];
    return filePath;
}

-(void)confirmUserForGroupImage:(UIImage *)image
{
    image = [image getCompressedImageLessThanSize:1];
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringWithDefaultValue(@"confirmationText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Confirmation!", @"")
                                                                    message:NSLocalizedStringWithDefaultValue(@"areYouSureForUploadText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Are you sure to upload?!", @"")
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    [ALUtilityClass setAlertControllerFrame:alert andViewController:self];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"cancelOptionText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Cancel!", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [self.groupIconView setImage:DEFAULT_GROUP_ICON_IMAGE];
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction* upload = [UIAlertAction actionWithTitle: NSLocalizedStringWithDefaultValue(@"upload", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Upload!", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        if(![ALDataNetworkConnection checkDataNetworkAvailable])
        {
            ALNotificationView * notification = [ALNotificationView new];
            [notification noDataConnectionNotificationView];;
            return;
        }
        
        NSString * uploadUrl = [KBASE_URL stringByAppendingString:IMAGE_UPLOAD_URL];
        
        self.groupImageUploadURL = uploadUrl;
        
        //TODO: Call From Delegate !!
        [self proessUploadImage:image uploadURL:uploadUrl withdelegate:self];
        
    }];
    
    [alert addAction:cancel];
    [alert addAction:upload];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)proessUploadImage:(UIImage *)profileImage uploadURL:(NSString *)uploadURL withdelegate:(id)delegate
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.activityIndicator startAnimating];
    NSString *filePath = self.mainFilePath;
    NSMutableURLRequest * request = [ALRequestHandler createPOSTRequestWithUrlString:uploadURL paramString:nil];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        //Create boundary, it can be anything
        NSString *boundary = @"------ApplogicBoundary4QuqLuM1cE5lMwCy";
        // set Content-Type in HTTP header
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        // post body
        NSMutableData *body = [NSMutableData data];
        NSString *FileParamConstant = @"file";
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:filePath];
        NSLog(@"IMAGE_DATA :: %f",imageData.length/1024.0);
        
        //Assuming data is not nil we add this to the multipart form
        if (imageData)
        {
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", FileParamConstant, @"imge_123_profile"] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Type:%@\r\n\r\n", @"image/jpeg"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        //Close off the request with the boundary
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // setting the body of the post to the request
        [request setHTTPBody:body];
        // set URL
        [request setURL:[NSURL URLWithString:uploadURL]];
        
        ALConnection * connection = [[ALConnection alloc] initWithRequest:request delegate:delegate startImmediately:YES];
        connection.connectionType = CONNECTION_TYPE_GROUP_IMG_UPLOAD;
        
        [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] addObject:connection];
        
    }else{
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.activityIndicator stopAnimating];
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                        message:@"Unable to locate file on device"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        [ALUtilityClass setAlertControllerFrame:alert andViewController:self];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

//==============================================================================================================================
#pragma NSURL CONNECTION DELEGATES + HELPER METHODS
//==============================================================================================================================

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"GROUP_IMAGE UPLOAD_ERROR :: %@",error.description);
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.activityIndicator stopAnimating];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSLog(@"GROUP_IMAGE UPLOAD PROGRESS :: %lu out of %lu",totalBytesWritten,totalBytesExpectedToWrite);
}

-(void)connectionDidFinishLoading:(ALConnection *)connection
{
    NSLog(@"CONNNECTION_FINISHED");
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
    if([connection.connectionType isEqualToString:CONNECTION_TYPE_GROUP_IMG_UPLOAD])
    {
        NSString *imageLinkFromServer = [[NSString alloc] initWithData:connection.mData encoding:NSUTF8StringEncoding];
        NSLog(@"GROUP_IMAGE_LINK :: %@",imageLinkFromServer);
        self.groupImageURL = imageLinkFromServer;
    }
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.activityIndicator stopAnimating];
}

-(void)connection:(ALConnection *)connection didReceiveData:(NSData *)data
{
    [connection.mData appendData:data];
}

@end
// TextView     = 100
// ImageView    = 102
// Text Field   = 103
