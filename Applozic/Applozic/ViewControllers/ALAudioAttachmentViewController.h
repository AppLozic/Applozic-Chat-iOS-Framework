//
//  ALAudioAttachmentViewController.h
//  Applozic
//
//  Created by devashish on 19/02/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ALAudioAttachmentDelegate <NSObject>

-(void)audioAttachment:(NSString *)audioFilePath;

@end

@interface ALAudioAttachmentViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *audioImageView;
@property (weak, nonatomic) IBOutlet UILabel *mediaProgressLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

@property (weak, nonatomic) NSTimer * timer;

@property (weak, nonatomic) NSString * outputFilePath;

@property (weak, nonatomic) id <ALAudioAttachmentDelegate> audioAttchmentDelegate;

- (IBAction)pauseButtonAction:(id)sender;
- (IBAction)playButtonAction:(id)sender;
- (IBAction)stopButtonAction:(id)sender;
- (IBAction)sendButtonAction:(id)sender;
- (IBAction)recordAction:(id)sender;
- (IBAction)cancelAction:(id)sender;


@end
