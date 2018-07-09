//
//  ALAudioVideoBaseVC.h
//  Applozic
//
//  Created by Abhishek Thapliyal on 1/12/17.
//  Copyright © 2017 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

static BOOL chatRoomEngage;

typedef enum {
    AV_CALL_DIALLED = 0,
    AV_CALL_RECEIVED = 1
}AV_LAUNCH_OPTIONS;

/**************************************************
 AV_CALL_CONTENT_TWO = 102    (NOTIFICATION ONLY)
 AV_CALL_CONTENT_THREE = 103  (SHOW MESG CONTENT)
 **************************************************/
typedef enum
{
    AV_CALL_CONTENT_TWO = 102,
    AV_CALL_CONTENT_THREE = 103
} CALL_CONTENT_TYPE;

@interface ALAudioVideoBaseVC : UIViewController

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSNumber *launchFor;
@property (nonatomic, strong) NSString *baseRoomId;
@property (nonatomic) BOOL callForAudio;

+(BOOL)chatRoomEngage;
+(void)setChatRoomEngage:(BOOL)flag;
-(void)dismissAVViewController:(BOOL)animated;
-(void)handleDataConnectivity;

@end
