//
//  ALUtilityClass.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALUtilityClass.h"
#import "ALConstant.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ALChatViewController.h"
#import "ALAppLocalNotifications.h"
#import <QuartzCore/QuartzCore.h>
#import "TSMessage.h"
#import "TSMessageView.h"
#import "ALPushAssist.h"
#import "ALAppLocalNotifications.h"
#import "ALUserDefaultsHandler.h"
#import "ALContactDBService.h"
#import "ALContact.h"
#import "UIImageView+WebCache.h"

@implementation ALUtilityClass

+ (NSString *) formatTimestamp:(NSTimeInterval) timeInterval toFormat:(NSString *) forMatStr
{
    
    NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
    [formatter setAMSymbol:@"ص"];
    [formatter setPMSymbol:@"م"];
    [formatter setDateFormat:forMatStr];
    formatter.timeZone = [NSTimeZone localTimeZone];
    
    NSString * dateStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
        
    return dateStr;
    
}

+ (NSString *)generateJsonStringFromDictionary:(NSDictionary *)dictionary {
 
    NSString *jsonString = nil;
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }
    else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
    
}

+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *colorString = [[hex stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    NSString *cString = [[colorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+(id)parsedALChatCostomizationPlistForKey:(NSString *)key {
    
    id value = nil;
    
    NSDictionary *values = [ALUtilityClass dictionary];
    
    if ([key isEqualToString:APPLOZIC_TOPBAR_COLOR]) {
        NSString *color= [values valueForKey:APPLOZIC_TOPBAR_COLOR];
        if (color) {
            value = [ALUtilityClass colorWithHexString:color];
        }
    }else if ([key isEqualToString:APPLOZIC_CHAT_BACKGROUND_COLOR]) {
        NSString *color= [values valueForKey:APPLOZIC_CHAT_BACKGROUND_COLOR];
        if (color) {
            value = [ALUtilityClass colorWithHexString:color];
        }
    }else if ([key isEqualToString:APPLOZIC_CHAT_FONTNAME]) {
        
        value = [values valueForKey:APPLOZIC_CHAT_FONTNAME];
    }else if ([key isEqualToString:APPLOGIC_TOPBAR_TITLE_COLOR]){
        NSString *color = [values valueForKey:APPLOGIC_TOPBAR_TITLE_COLOR];
        if (color) {
            value = [ALUtilityClass colorWithHexString:color];
        }
    }
    return value;
}

+ (NSDictionary *)dictionary {
    static NSDictionary *parsedDict = nil;
    if (parsedDict == nil) {
        NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"ALChatCostomization" ofType:@"plist"];
        parsedDict=[[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
    return parsedDict;
}

+ (BOOL)isToday:(NSDate *)todayDate {
    
    BOOL result = NO;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:todayDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate]) {
        //do stuff
        result = YES;
    }
    return result;
}

+ (NSString*) fileMIMEType:(NSString*) file {
    NSString *mimeType = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:file] && [file pathExtension]){
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[file pathExtension], NULL);
        CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
        CFRelease(UTI);
        if(MIMEType){
            mimeType = [NSString stringWithString:(__bridge NSString *)(MIMEType)];
            CFRelease(MIMEType);
        }
    }
    
    return mimeType;
}

+(CGSize)getSizeForText:(NSString *)text maxWidth:(CGFloat)width font:(NSString *)fontName fontSize:(float)fontSize
{
    CGSize constraintSize;
    constraintSize.height = MAXFLOAT;
    constraintSize.width = width;
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:fontName size:fontSize], NSFontAttributeName,nil];
    
    CGRect frame = [text boundingRectWithSize:constraintSize
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:attributesDictionary
                                      context:nil];
    CGSize stringSize = frame.size;

    return stringSize;
}

+(void)displayToastWithMessage:(NSString *)toastMessage
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
        UILabel * toastView = [[UILabel alloc] init];
        [toastView setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        toastView.text = toastMessage;
        [toastView setTextColor:[ALApplozicSettings getColorForToastText]];
        toastView.backgroundColor = [ALApplozicSettings getColorForToastBackground];
        toastView.textAlignment = NSTextAlignmentCenter;
        [toastView setNumberOfLines:2];
        CGFloat width =  keyWindow.frame.size.width - 60;
        toastView.frame = CGRectMake(0, 0, width, 80);
        toastView.layer.cornerRadius = toastView.frame.size.height/2;
        toastView.layer.masksToBounds = YES;
        toastView.center = keyWindow.center;
        
        [keyWindow addSubview:toastView];
        
        [UIView animateWithDuration: 3.0f
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             toastView.alpha = 0.0;
                         }
                         completion: ^(BOOL finished) {
                             [toastView removeFromSuperview];
                         }
         ];
    }];
}



+(void)thirdDisplayNotificationTS:(NSString *)toastMessage andForContactId:(NSString *)contactId withGroupId:(NSNumber*) groupID delegate:(id)delegate
{
    
    if([ALUserDefaultsHandler getNotificationMode] == NOTIFICATION_DISABLE ){
        return;
    }
    //3rd Party View is Opened.........
    ALContact* dpName=[[ALContact alloc] init];
    ALContactDBService * contactDb=[[ALContactDBService alloc] init];
    dpName=[contactDb loadContactByKey:@"userId" value:contactId];
    
    
    ALChannel *channel=[[ALChannel alloc] init];
    ALChannelDBService *groupDb= [[ALChannelDBService alloc] init];
    
    NSString* title;
    if(groupID){
        channel = [groupDb loadChannelByKey:groupID];
        title=channel.name;
        contactId=[NSString stringWithFormat:@"%@",groupID];
    }
    else {
        title=dpName.getDisplayName;
    }

    ALPushAssist* top=[[ALPushAssist alloc] init];
    UIImage *appIcon = [UIImage imageNamed: [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]];
    
    [[TSMessageView appearance] setTitleFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
    [[TSMessageView appearance] setContentFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [[TSMessageView appearance] setContentTextColor:[UIColor whiteColor]];
   
    [TSMessage showNotificationInViewController:top.topViewController
                                          title:title
                                       subtitle:toastMessage
                                          image:appIcon
                                           type:TSMessageNotificationTypeMessage
                                       duration:1.75
                                       callback:^(void){
        
                                           
                                           [delegate thirdPartyNotificationTap1:contactId withGroupId:groupID];

        
    }buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:YES];
    
}

+(void)thirdDisplayNotificationTS:(NSString *)toastMessage andForContactId:(NSString *)contactId withGroupId:(NSNumber*) groupID completionHandler:(void (^)(BOOL))handler
{

    if([ALUserDefaultsHandler getNotificationMode] == NOTIFICATION_DISABLE){
        return;
    }
    //3rd Party View is Opened.........
    ALContact* dpName=[[ALContact alloc] init];
    ALContactDBService * contactDb=[[ALContactDBService alloc] init];
    dpName=[contactDb loadContactByKey:@"userId" value:contactId];


    ALChannel *channel=[[ALChannel alloc] init];
    ALChannelDBService *groupDb= [[ALChannelDBService alloc] init];

    NSString* title;
    if(groupID){
        channel = [groupDb loadChannelByKey:groupID];
        title=channel.name;
        contactId=[NSString stringWithFormat:@"%@",groupID];
    }
    else {
        title=dpName.getDisplayName;
    }

    ALPushAssist* top=[[ALPushAssist alloc] init];
    UIImage *appIcon = [UIImage imageNamed: [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]];

    [[TSMessageView appearance] setTitleFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
    [[TSMessageView appearance] setContentFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [[TSMessageView appearance] setContentTextColor:[UIColor whiteColor]];

    [TSMessage showNotificationInViewController:top.topViewController
                                          title:toastMessage
                                       subtitle:nil
                                          image:appIcon
                                           type:TSMessageNotificationTypeMessage
                                       duration:1.75
                                       callback:^(void){

                                           handler(YES);
                                           //                                           [delegate thirdPartyNotificationTap1:contactId withGroupId:groupID];


                                       }
                                    buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:YES];
    
}

+(NSString *)getFileNameWithCurrentTimeStamp
{
    NSString *resultString = [@"IMG-" stringByAppendingString: @([[NSDate date] timeIntervalSince1970]).stringValue];
    return resultString;
}


+(UIImage *)getImageFromFramworkBundle:(NSString *) UIImageName{
    
    NSBundle * bundle = [NSBundle bundleForClass:ALUtilityClass.class];
    UIImage *image = [UIImage imageNamed:UIImageName inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}


+(NSString *)getNameAlphabets:(NSString *)actualName
{
    NSString *alpha = @"";
    
    NSRange whiteSpaceRange = [actualName rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whiteSpaceRange.location != NSNotFound)
    {
        NSArray *listNames = [actualName componentsSeparatedByString:@" "];
        NSString *firstLetter = [[listNames[0] substringToIndex:1] uppercaseString];
        NSString *lastLetter = [[listNames[1] substringToIndex:1] uppercaseString];
        alpha = [[firstLetter stringByAppendingString: lastLetter] uppercaseString];
    }
    else
    {
        NSString *firstLetter = [actualName substringToIndex:1];
        alpha = [firstLetter uppercaseString];
    }
    return alpha;
}

-(void)getExactDate:(NSNumber *)dateValue
{
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970: [dateValue doubleValue]/1000];
    
    NSDate *current = [[NSDate alloc] init];
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyy"];
    
    NSString *todaydate = [format stringFromDate:current];
    NSString *yesterdaydate = [format stringFromDate:yesterday];
    NSString *serverdate = [format stringFromDate:date];
    self.msgdate = serverdate;
    
    if([serverdate isEqualToString:todaydate])
    {
        self.msgdate = NSLocalizedStringWithDefaultValue(@"todayMsgViewText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"today" , @"");
        
    }
    else if ([serverdate isEqualToString:yesterdaydate])
    {
        self.msgdate = NSLocalizedStringWithDefaultValue(@"yesterdayMsgViewText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"yesterday" , @"");
    }
    
    [format setDateFormat:@"hh:mm a"];
    [format setAMSymbol:@"ص"];
    [format setPMSymbol:@"م"];
    
    self.msgtime = [format stringFromDate:date];
    
}

+(UIImage *)setVideoThumbnail:(NSString *)videoFilePATH
{
    NSURL *url = [NSURL fileURLWithPath:videoFilePATH];
    UIImage * processThumbnail = [self subProcessThumbnail:url];
    return processThumbnail;
}

+(UIImage *)subProcessThumbnail:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage * thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return thumbnail;
}


+(void)subVideoImage:(NSURL *)url  withCompletion:(void (^)(UIImage *image)) completion{
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }
        
        completion([UIImage imageWithCGImage:im]);
    };
    
    CGSize maxSize = CGSizeMake(128, 128);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
}

+(void)showAlertMessage:(NSString *)text andTitle:(NSString *)title
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title
                                                         message:text
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:NSLocalizedStringWithDefaultValue(@"okText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"OK" , @""), nil];
    
    [alertView show];
    
}

+(UIView *)setStatusBarStyle
{
    UIApplication * app = [UIApplication sharedApplication];
    [app setStatusBarHidden:NO];
    [app setStatusBarStyle:[ALApplozicSettings getStatusBarStyle]];
    
    CGFloat height = app.statusBarFrame.size.height;
    CGFloat width = app.statusBarFrame.size.width;
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -height, width, height)];
    statusBarView.backgroundColor = [ALApplozicSettings getStatusBarBGColor];
    return statusBarView;
}

+(UIImage *)getNormalizedImage:(UIImage *)rawImage
{
    if(rawImage.imageOrientation == UIImageOrientationUp)
        return rawImage;
    
    UIGraphicsBeginImageContextWithOptions(rawImage.size, NO, rawImage.scale);
    [rawImage drawInRect:(CGRect){0, 0, rawImage.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return normalizedImage;
}

+(BOOL)isThisDebugBuild
{
    BOOL debug;
    #ifdef DEBUG
        NSLog(@"DEBUG_MODE");
        debug = YES;
    #else
        NSLog(@"RELEASE_MODE");
        debug = NO;
    #endif
    
    return debug;
}

+(void)openApplicationSettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}


+(void)permissionPopUpWithMessage:(NSString *)msgText andViewController:(UIViewController *)viewController
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringWithDefaultValue(@"applicationSettings", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Application Settings" , @"")    message:msgText
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    [ALUtilityClass setAlertControllerFrame:alertController andViewController:viewController];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"cancelOptionText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Cancel" , @"")  style:UIAlertActionStyleCancel handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"settings", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Settings" , @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [ALUtilityClass openApplicationSettings];
    }]];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

// FOR IPAD DEVICES
+(void)setAlertControllerFrame:(UIAlertController *)alertController andViewController:(UIViewController *)viewController
{
    if(IS_IPAD)
    {
        alertController.popoverPresentationController.sourceView = viewController.view;
        CGSize size = viewController.view.bounds.size;
        CGRect frame = CGRectMake((size.width/2.0), (size.height/2.0), 1.0, 1.0); // (x, y, popup point X, popup point Y);
        alertController.popoverPresentationController.sourceRect = frame;
        [alertController.popoverPresentationController setPermittedArrowDirections:0]; // HIDING POPUP ARROW
    }
}

+(void)movementAnimation:(UIButton *)button andHide:(BOOL)flag
{
    if(flag)  // FADE IN
    {
        [UIView animateWithDuration:0.3 animations:^{
            button.alpha = 0;
        } completion: ^(BOOL finished) {
            button.hidden = finished;
        }];
    }
    else
    {
         button.alpha = 0;  // FADE OUT
         button.hidden = NO;
         [UIView animateWithDuration:0.3 animations:^{
         button.alpha = 1;
         }];
    }
}

+(NSString *)getDevieUUID
{
    NSString * uuid = [[NSUUID UUID] UUIDString];
    return uuid;
}

+(BOOL)checkDeviceKeyString:(NSString *)string
{
    NSArray * array = [string componentsSeparatedByString:@":"];
    NSString * deviceString = (NSString *)[array firstObject];
    return [deviceString isEqualToString:[ALUtilityClass getDevieUUID]];
}

+(void)setImageFromURL:(NSString *)urlString andImageView:(UIImageView *)imageView
{
    NSURL * imageURL = [NSURL URLWithString:urlString];
    [imageView sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageRefreshCached];
}

+(NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    NSString * text = @"";
    
    if (hours)
    {
        text = [NSString stringWithFormat:@"%ld ساعة %02ld دقيقة %02ld ثواني", (long)hours, (long)minutes, (long)seconds];
    }
    else if (minutes)
    {
        text = [NSString stringWithFormat:@"%ld دقيقة %ld ثواني", (long)minutes, (long)seconds];
    }
    else
    {
        text = [NSString stringWithFormat:@"%ld ثواني", (long)seconds];
    }
    
    return text;
}

+(UIImage *)getVOIPMessageImage:(ALMessage *)alMessage
{
    NSString *msgType = (NSString *)[alMessage.metadata objectForKey:@"MSG_TYPE"];
    BOOL flag = [[alMessage.metadata objectForKey:@"CALL_AUDIO_ONLY"] boolValue];
    
    NSString * imageName = @"";
    
    if([msgType isEqualToString:@"CALL_MISSED"] || [msgType isEqualToString:@"CALL_REJECTED"])
    {
        imageName = @"missed_call.png";
    }
    else if([msgType isEqualToString:@"CALL_END"])
    {
        imageName = flag ? @"audio_call.png" : @"ic_action_video.png";
    }
    
    UIImage *image = [ALUtilityClass getImageFromFramworkBundle:imageName];
    
    return image;
}


+(NSString*)getLocationUrl:(ALMessage*)almessage;
{
    NSString *latLongArgument = [self formatLocationJson:almessage];
    NSString * finalURl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=17&size=290x179&maptype=roadmap&format=png&visual_refresh=true&markers=%@&key=%@",
                           latLongArgument,latLongArgument,[ALUserDefaultsHandler getGoogleMapAPIKey]];
    return finalURl;
}

+(NSString*)getLocationUrl:(ALMessage*)almessage size: (CGRect) withSize
{
    
    
    NSString *latLongArgument = [self formatLocationJson:almessage];
    
    
    NSString *staticMapUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?format=png&markers=%@&key=%@&zoom=13&size=%dx%d&scale=1",latLongArgument,
                              [ALUserDefaultsHandler getGoogleMapAPIKey], 2*(int)withSize.size.width, 2*(int)withSize.size.height];
    
    return staticMapUrl;
}

+(NSString*)formatLocationJson:(ALMessage *)locationAlMessage
{
    NSError *error;
    NSData *objectData = [locationAlMessage.message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonStringDic = [NSJSONSerialization JSONObjectWithData:objectData
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&error];
    
    NSArray* latLog = [[NSArray alloc] initWithObjects:[jsonStringDic valueForKey:@"lat"],[jsonStringDic valueForKey:@"lon"], nil];
    
    if(!latLog.count)
    {
        return [self processMapUrl:locationAlMessage];
    }
    
    NSString *latLongArgument = [NSString stringWithFormat:@"%@,%@", latLog[0], latLog[1]];
    return latLongArgument;
}

+(NSString *)processMapUrl:(ALMessage *)message
{
    NSArray * URL_ARRAY = [message.message componentsSeparatedByString:@"="];
    NSString * coordinate = (NSString *)[URL_ARRAY lastObject];
    return coordinate;
}



@end
