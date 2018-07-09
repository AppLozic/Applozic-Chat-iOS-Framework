//
//  ALMediaPlayer.h
//  Applozic
//
//  Created by Devashish on 23/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol ALALMediaPlayerDelegate <NSObject>

-(void)getProgressOfTrack;
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;

@end

@interface ALMediaPlayer : NSObject<AVAudioPlayerDelegate>

+(ALMediaPlayer *)sharedInstance;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSTimer *timer;
@property(nonatomic, weak) id <ALALMediaPlayerDelegate>delegate;
@property (nonatomic, strong) NSString * key;

-(void) getProgressOfTrack;
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
-(void) playAudio:(NSString * ) filePath;
-(void) playVideo:(NSString * ) filePath;
-(BOOL) isPlayingCurrentKey:(NSString*) key;
-(BOOL) stopPlaying;
-(void) pauseAudio;
-(void) resumeAudio;
+(NSString *)getTotalDuration:(NSString *)path;
@end
