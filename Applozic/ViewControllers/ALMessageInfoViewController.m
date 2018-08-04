//
//  ALMessageInfoViewController.m
//  Applozic
//
//  Created by devashish on 17/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALMessageInfoViewController.h"
#import "UIImageView+WebCache.h"
#import "ALApplozicSettings.h"
#import "ALDataNetworkConnection.h"
#import "ALNotificationView.h"
#import "TSMessageView.h"

@interface ALMessageInfoViewController ()
{
    NSMutableArray *arrayList;
    NSMutableArray *readList;
    NSMutableArray *deliveredList;
}

-(void)cellAtIndexPath:(ALMessageInfo *)msgInfo inSection:(NSInteger)section;
-(UIView *)customHeaderView:(NSInteger)section withTitle:(NSString *)title andName:(NSString *)name;

@end

@implementation ALMessageInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.alTableView.delegate = self;
    self.alTableView.dataSource = self;
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.activityIndicator stopAnimating];
    [self navigationBarColor];
}

-(void)navigationBarColor
{
    if([ALApplozicSettings getColorForNavigation] && [ALApplozicSettings getColorForNavigationItem])
    {
        [self.navigationController.navigationBar addSubview:[ALUtilityClass setStatusBarStyle]];
        [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
        [self.navigationController.navigationBar setTintColor: [ALApplozicSettings getColorForNavigationItem]];
    }
}

//==================================================================================================
# pragma TABLE VIEW DELEGATES
//==================================================================================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    else if (section == 1)
    {
        return readList.count;
    }
    else
    {
        return deliveredList.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.msgHeaderHeight + 20;
    }
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [self viewForMessageSection:tableView];
    }
    else if(section == 1)
    {
        return [self customHeaderView:section withTitle:NSLocalizedStringWithDefaultValue(@"read", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Read", @"") andName:@"ic_action_read.png"];
    }
    else
    {
        return [self customHeaderView:section withTitle:NSLocalizedStringWithDefaultValue(@"delivered", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Delivered", @"")  andName:@"ic_action_message_delivered.png"];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALContactCell *contactCell = (ALContactCell *)[tableView dequeueReusableCellWithIdentifier:@"userCell"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self setTableCellView: contactCell];
        ALMessageInfo *msgInfo;
        if(indexPath.section == 1)
        {
            msgInfo = readList[indexPath.row];
            [self cellAtIndexPath:msgInfo inSection:indexPath.section];
        }
        else if(indexPath.section == 2)
        {
            msgInfo = deliveredList[indexPath.row];
            [self cellAtIndexPath:msgInfo inSection:indexPath.section];
        }
    });
    
    return contactCell;
}

//==================================================================================================
# pragma TABLE VIEW HELPER METHODS
//==================================================================================================

-(void)setMessage:(ALMessage *)alMessage andHeaderHeight:(CGFloat)headerHeight withCompletionHandler:(void(^)(NSError * error))completion
{
    if(![ALDataNetworkConnection checkDataNetworkAvailable])
    {
        ALNotificationView * notification = [ALNotificationView new];
        [notification noDataConnectionNotificationView];
        completion([self customError]);
        return;
    }
    if(!alMessage.sentToServer)
    {
        [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
        [TSMessage showNotificationWithTitle:NSLocalizedStringWithDefaultValue(@"messageProccessText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Message is in processing", @"") type:TSMessageNotificationTypeWarning];
        completion([self customError]);
        return;
    }
    
    self.almessage = alMessage;
    self.msgHeaderHeight = headerHeight;
    
    readList = [NSMutableArray new];
    deliveredList = [NSMutableArray new];
    
    ALMessageService *msgService = [ALMessageService new];
    [msgService getMessageInformationWithMessageKey:self.almessage.key withCompletionHandler:^(ALMessageInfoResponse *msgInfo, NSError *theError) {
        
        if(!theError)
        {
            arrayList = [NSMutableArray arrayWithArray:msgInfo.msgInfoList];
            
            for (ALMessageInfo *info in arrayList)
            {
                if(info.messageStatus == (short)READ)
                {
                    [readList addObject:info];
                }
                
                if(info.messageStatus == (short)DELIVERED)
                {
                    [deliveredList addObject:info];
                }
                
            }
            completion(theError);
        }
    }];
}

-(void)setTableCellView:(ALContactCell *)contactCell
{
    self.firstAlphabet = (UILabel *)[contactCell viewWithTag:505];
    self.userImage = (UIImageView *)[contactCell viewWithTag:504];
    self.userName = (UILabel *)[contactCell viewWithTag:503];
    self.dateLabel = (UILabel *)[contactCell viewWithTag:502];
    [self.dateLabel setTextColor:[UIColor grayColor]];
    //    self.timeLabel = (UILabel *)[contactCell viewWithTag:501];
    
    [self.firstAlphabet setTextColor:[UIColor whiteColor]];
    self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2;
    self.userImage.layer.masksToBounds = YES;
}

-(UIView *)viewForMessageSection:(UITableView *)tableView
{
    return [self populateCellForMessage:self.view.frame.size];
}

-(UIView *)customHeaderView:(NSInteger)section withTitle:(NSString *)title andName:(NSString *)name
{
    self.headerTitle = [[UILabel alloc] init];
    [self.headerTitle setBackgroundColor:[UIColor clearColor]];
    [self.headerTitle setTextColor:[UIColor blackColor]];
    [self.headerTitle setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    [self.headerTitle setTextAlignment:NSTextAlignmentLeft];
    
    self.tickImageView = [[UIImageView alloc] init];
    [self.tickImageView setBackgroundColor:[UIColor clearColor]];
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    [headerView setBackgroundColor:[UIColor colorWithRed:238.0/255 green:238.0/255 blue:238.0/255 alpha:1.0]];
    
    [self.tickImageView setFrame:CGRectMake(headerView.frame.origin.x + 10, headerView.frame.origin.y + 10, 30, 30)];
    [self.headerTitle setFrame:CGRectMake(self.tickImageView.frame.origin.x + self.tickImageView.frame.size.width + 10, self.tickImageView.frame.origin.y, 200, 30)];
    
    [self.tickImageView setContentMode:UIViewContentModeScaleAspectFit];
    [headerView addSubview:self.tickImageView];
    [headerView addSubview:self.headerTitle];
    
    [self.headerTitle setText:title];
    [self.tickImageView setImage:[ALUtilityClass getImageFromFramworkBundle:name]];
    
    return headerView;
}

-(void)cellAtIndexPath:(ALMessageInfo *)msgInfo inSection:(NSInteger)section
{
    ALContactDBService * alContactDBService = [ALContactDBService new];
    ALContact *alContact = [alContactDBService loadContactByKey:@"userId" value:msgInfo.userId];
    
    NSURL * theUrl = [NSURL URLWithString:alContact.contactImageUrl];
    [self.userImage sd_setImageWithURL:theUrl];
    [self.firstAlphabet setHidden:YES];
    [self.userName setText:[alContact getDisplayName]];
    
    if(!alContact.contactImageUrl)
    {
        [self.firstAlphabet setHidden:NO];
        [self.userImage setBackgroundColor:[ALColorUtility getColorForAlphabet:[alContact getDisplayName]]];
        [self.firstAlphabet setText:[ALColorUtility getAlphabetForProfileImage:[alContact getDisplayName]]];
    }
    
    ALUtilityClass *utility = [ALUtilityClass new];
    [utility getExactDate:msgInfo.readAtTime];
    
    if(section == 2)
    {
        [utility getExactDate:msgInfo.deliveredAtTime];
    }
    
    [self.dateLabel setText:[NSString stringWithFormat:@"%@ %@", utility.msgdate, utility.msgtime]];
}


-(UIView *)populateCellForMessage:(CGSize)cellSize
{
    CGFloat maxWidth = cellSize.width - 150;
    
    UIImageView *bubbleView = [[UIImageView alloc] init];
    [bubbleView setBackgroundColor:[ALApplozicSettings getSendMsgColor]];
    bubbleView.layer.cornerRadius = 5;
    bubbleView.layer.masksToBounds = YES;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setBackgroundColor:[UIColor whiteColor]];
    imageView.layer.cornerRadius = 5;
    imageView.layer.masksToBounds = YES;
    
    CGRect frameImage = CGRectMake(cellSize.width - 265, 10, maxWidth, maxWidth);
    
    if(self.almessage.contentType == ALMESSAGE_CONTENT_LOCATION)
    {
        frameImage = CGRectMake(cellSize.width - 265, 10, maxWidth, self.msgHeaderHeight);
    }
    
    CGRect subFrameImage = CGRectMake(frameImage.origin.x + 5, frameImage.origin.y + 5, frameImage.size.width - 10,  frameImage.size.height-10);
    
    UITextView *textView = [[UITextView alloc] init];
    [textView setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    textView.selectable = YES;
    textView.editable = NO;
    textView.scrollEnabled = NO;
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.textContainer.lineFragmentPadding = 0;
    [textView setTextColor:[UIColor whiteColor]];;
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setText:self.almessage.message];
    
    CGSize textSize = [ALUtilityClass getSizeForText:self.almessage.message maxWidth:maxWidth + 5 font:textView.font.fontName fontSize:textView.font.pointSize];
    
    bubbleView.frame = frameImage;
    imageView.frame = subFrameImage;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.msgHeaderHeight + 20)];
    
    if([self.almessage.fileMeta.contentType hasPrefix:@"audio"])
    {
        
        
        
        textSize  =  [ALUtilityClass getSizeForText:self.almessage.fileMeta.name maxWidth:maxWidth + 5 font:textView.font.fontName fontSize:textView.font.pointSize];
        [textView setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        
        
        
        [imageView setImage:[ALUtilityClass getImageFromFramworkBundle:@"ic_mic.png"]];
        
        bubbleView.frame = CGRectMake(cellSize.width - 265, 10, maxWidth, self.msgHeaderHeight);
        imageView.frame = CGRectMake(bubbleView.frame.origin.x + 5, bubbleView.frame.origin.y + 5, self.msgHeaderHeight - 10, self.msgHeaderHeight - 10);
        textView.frame = CGRectMake(imageView.frame.origin.x+  25, bubbleView.frame.origin.y +25, textSize.width, textSize.height);
        textView.hidden = NO;
        
        [textView setText:self.almessage.fileMeta.name];
        
        [view addSubview:textView];
        [view addSubview:imageView];
        
    }
    else if ([self.almessage.fileMeta.contentType hasPrefix:@"video"])
    {
        if(self.almessage.message.length)
        {
            CGSize textSize = [ALUtilityClass getSizeForText:self.almessage.message
                                                    maxWidth:imageView.frame.size.width
                                                        font:textView.font.fontName
                                                    fontSize:textView.font.pointSize];
            
            bubbleView.frame = CGRectMake(cellSize.width - 265, 10, maxWidth, self.msgHeaderHeight);
            imageView.frame = CGRectMake(bubbleView.frame.origin.x + 5, bubbleView.frame.origin.y + 5, bubbleView.frame.size.width - 10, maxWidth - 40);
            textView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y + imageView.frame.size.height + 5,
                                        imageView.frame.size.width, textSize.height );
            [view addSubview:textView];
            [textView setText:self.almessage.message];
        }
        
        
        
        if(self.almessage.imageFilePath != nil && self.almessage.fileMeta.blobKey)
        {
            NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString * filePath = [docDir stringByAppendingPathComponent:self.almessage.imageFilePath];
            [imageView setImage: [ALUtilityClass setVideoThumbnail:filePath]];
            
            
        }
        else
        {
            [imageView setImage:[ALUtilityClass getImageFromFramworkBundle:@"VIDEO.png"]];
            
        }
        
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        
        
        [view addSubview:imageView];
        
        
    }
    else if ([self.almessage.fileMeta.contentType hasPrefix:@"image"] || self.almessage.contentType == ALMESSAGE_CONTENT_LOCATION)
    {
        [imageView sd_setImageWithURL:self.contentURL];
        [view addSubview:imageView];
        if(self.almessage.message.length && self.almessage.contentType == ALMESSAGE_CONTENT_ATTACHMENT)
        {
            CGSize textSize = [ALUtilityClass getSizeForText:self.almessage.message maxWidth:imageView.frame.size.width font:textView.font.fontName fontSize:textView.font.pointSize];
            bubbleView.frame = CGRectMake(cellSize.width - 265, 10, maxWidth, self.msgHeaderHeight);
            textView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y + imageView.frame.size.height + 10, imageView.frame.size.width, textSize.height + 20);
            [view addSubview:textView];
            [textView setText:self.almessage.message];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
        }
    }
    else if(self.almessage.fileMeta.contentType)
    {
        bubbleView.frame = CGRectMake(cellSize.width - 265, 10, maxWidth, self.msgHeaderHeight);
        imageView.frame = CGRectMake(bubbleView.frame.origin.x + 5, bubbleView.frame.origin.y + 5, self.msgHeaderHeight - 10, self.msgHeaderHeight - 10);
        
        [imageView setImage:[ALUtilityClass getImageFromFramworkBundle:@"documentSend.png"]];
        [textView setText:self.almessage.fileMeta.name];
        
        textView.frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 5,
                                    imageView.frame.origin.y + 5,
                                    bubbleView.frame.size.width - imageView.frame.size.width - 10,
                                    imageView.frame.size.height);
        
        if(self.almessage.contentType == ALMESSAGE_CONTENT_VCARD)
        {
            imageView.frame = CGRectMake(bubbleView.frame.origin.x + 10, bubbleView.frame.origin.y + 5, 50, 50);
            imageView.layer.cornerRadius = imageView.frame.size.width/2;
            
            [imageView setImage: [ALUtilityClass getImageFromFramworkBundle:@"ic_contact_picture_holo_light.png"]];
            if(IS_OS_EARLIER_THAN_10)
            {
                if(self.VCFObject.retrievedImage)
                {
                    [imageView setImage:self.VCFObject.retrievedImage];
                }
                [textView setText:[NSString stringWithFormat:@"%@\n\n%@",self.VCFObject.fullName,self.VCFObject.phoneNumber]];
                if(self.VCFObject.emailID)
                {
                    [textView setText:[NSString stringWithFormat:@"%@\n\n%@\n\n%@",self.VCFObject.fullName,self.VCFObject.phoneNumber,self.VCFObject.emailID]];
                }
            }
            else
            {
                if(self.VCardClass.contactImage)
                {
                    [imageView setImage:self.VCardClass.contactImage];
                }
                [textView setText:[NSString stringWithFormat:@"%@\n\n%@",self.VCardClass.fullName,self.VCardClass.userPHONE_NO]];
                if(self.VCardClass.userEMAIL_ID)
                {
                    [textView setText:[NSString stringWithFormat:@"%@\n\n%@\n\n%@",self.VCardClass.fullName, self.VCardClass.userPHONE_NO,
                                       self.VCardClass.userEMAIL_ID]];
                }
            }
            textView.frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 10,
                                        bubbleView.frame.origin.y + 5,
                                        bubbleView.frame.size.width - imageView.frame.size.width - 10,
                                        bubbleView.frame.size.height - 10);
        }
        
        
        [view addSubview:textView];
        [view addSubview:imageView];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    else
    {
        bubbleView.frame = CGRectMake((view.frame.size.width - textSize.width - 27), view.frame.origin.y + 10, textSize.width + 18, self.msgHeaderHeight);
        textView.frame = CGRectMake(bubbleView.frame.origin.x + 10, bubbleView.frame.origin.y + 10, textSize.width, textSize.height);
        [view addSubview:textView];
        [textView setText:self.almessage.message];
    }
    
    [view setBackgroundColor:[UIColor colorWithRed:250.0/255 green:250.0/255 blue:250.0/255 alpha:1.0]];
    [view addSubview:bubbleView];
    [view bringSubviewToFront:textView];
    [view bringSubviewToFront:imageView];
    
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        textView.textAlignment = NSTextAlignmentRight;
        imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        
    }
    
    return view;
}



-(NSError *)customError
{
    NSString * domain = @"com.applozic.domain";
    NSString * desc = NSLocalizedString(@"EITHER 'NO NETWORK' OR 'MSG YET TO SENT'", @"");
    NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : desc };
    NSError * error = [NSError errorWithDomain:domain code:0 userInfo:userInfo];
    return error;
}

@end
