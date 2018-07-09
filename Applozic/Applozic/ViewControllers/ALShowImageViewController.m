//
//  ALShowImageViewController.m
//  Applozic
//
//  Created by Divjyot Singh on 26/07/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALShowImageViewController.h"
#import "ALImageActivity.h"
#import "ALApplozicSettings.h"

@interface ALShowImageViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareToolBarButton;
//@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
//@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBarButton;

@end

@implementation ALShowImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //@"SHARE_IMAGE"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToMessageViewController) name:@"SHARE_IMAGE" object:nil];
    [self setupBarItems];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;
    
}

-(void)setupBarItems
{
    self.alImageActivity = [[ALImageActivity alloc] init];
    self.alImageActivity.imageActivityDelegate = self;
    
    [self.navigationController.navigationBar setTintColor:[ALApplozicSettings getColorForNavigation]];
    [self.navigationController.navigationBar setBarTintColor:[ALApplozicSettings getColorForNavigation]];
    
//    [self.backBarButton setTitle:NSLocalizedStringWithDefaultValue(@"back", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Back", @"")];
    self.navigationController.navigationBar.topItem.title = NSLocalizedStringWithDefaultValue(@"imagePreview", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Image Preview", @"");
    self.navigationController.navigationBar.titleTextAttributes = @{
                                               NSForegroundColorAttributeName:[ALApplozicSettings getColorForNavigationItem]
                                               ,
                                               NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi" size:18]};
    //[self.toolBar setBarTintColor:[ALApplozicSettings getColorForNavigation]];
    [self.backBarButton setTintColor:[ALApplozicSettings getColorForNavigationItem]];
    [self.shareToolBarButton setTintColor:[ALApplozicSettings getColorForNavigationItem]];
    //[self.navigationBar addSubview:[ALUtilityClass setStatusBarStyle]];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.imageView setImage:self.image];
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:^{}];
    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)shareToolBarButton:(id)sender {
    [self share:sender];
}

- (void) share:(id)sender{
    
    NSLog(@"shareButton pressed");
    
    //Image iteself
    UIImage *imagetoshare = self.image;
    
    // Message if associated with image
    ALMessage * alMessage = self.alMessage;
    NSString * messageString = alMessage.message;
    NSLog(@"MSG_STRING :: %@",messageString);
    
    NSArray *activityItems = @[imagetoshare];
    
    //Custom Activity for Applozic Sharing
    // set "uiActivityArray" for "applicationActivities:nil" instead of nill to add this fuctionality
    //    NSArray *uiActivityArray = @[self.alImageActivity];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:activityItems
                                            applicationActivities:nil];
    
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                         UIActivityTypePrint,
                                         UIActivityTypePostToTwitter,
                                         UIActivityTypePostToWeibo,
                                         UIActivityTypeMail];
    
    [self presentViewController:activityVC animated:TRUE completion:nil];
}

-(void)showContactsToShareImage
{
    
    UIStoryboard * applozic = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:[ALNewContactsViewController class]]];
    
    self.contactsViewController = [applozic instantiateViewControllerWithIdentifier:@"ALNewContactsViewController"];
    self.contactsViewController.forGroup = [NSNumber numberWithInteger:IMAGE_SHARE];
    
    
    
    UIBarButtonItem * leftBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"cancelOptionText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Cancel", @"") style:UIBarButtonItemStylePlain target:self action:@selector(dismissContactViewControllerWithCompletion:)];
    
    UINavigationItem * navigationItem = [[UINavigationItem alloc] init];
    navigationItem.leftBarButtonItem = leftBarButton;
    
    UINavigationBar * contactsNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(self.view.frame),44)];
    contactsNavigationBar.translucent = NO;
    contactsNavigationBar.items = @[navigationItem];
    
    [self.contactsViewController.view addSubview:contactsNavigationBar];
    
    [self presentViewController:self.contactsViewController animated:YES completion:^{}];
}

-(void)backToMessageViewController{
    [self dismissContactViewControllerWithCompletion:^{}];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)dismissContactViewControllerWithCompletion: (void (^ __nullable)(void))completion{
    [self.contactsViewController dismissViewControllerAnimated:YES completion:^{}];
}


@end
