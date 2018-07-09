//
//  ALMediaPlayer.m
//  Applozic
//
//  Created by Devashish on 23/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALMediaPlayer.h"

@implementation ALMediaPlayer



+(ALMediaPlayer *)sharedInstance
{
    static ALMediaPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ALMediaPlayer alloc] init];
    });
    return sharedInstance;
    
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Audio life Cycle ( create session, paly, pause, resume, stop )
//------------------------------------------------------------------------------------------------------------------

-(void)createSession
{
    NSError * error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if(error == nil)
        
    {
        NSLog(@"AUDIO SESSION CREATED SUCCESSFULLY");
    }
    else
    {
        NSLog(@"AUDIO SESSION FAIL TO CREATE : %@", [error description]);
    }
}

-(void)playAudio:(NSString *)filePath{
    
    NSLog(@"starting Audio....");
    [self createSession];
    NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * filePath1 = [docDir stringByAppendingPathComponent:filePath];
    NSURL *soundFileURL = [NSURL fileURLWithPath:filePath1];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    self.audioPlayer.delegate = self;
    [self.audioPlayer play];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(getProgressOfTrack) userInfo:nil repeats:YES];
    
}

-(void)pauseAudio{
    
    NSLog(@"Audio Paused");
    
    [self.timer invalidate];
    [self.audioPlayer pause];
}


-(void)resumeAudio{
    
    NSLog(@"Audio resumed");
    
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(getProgressOfTrack) userInfo:nil repeats:YES];
    [self.audioPlayer play];
}

-(BOOL)stopPlaying{
    [self.timer invalidate];
    [self.delegate audioPlayerDidFinishPlaying:self.audioPlayer successfully:false];
    return true;
}


-(void)playVideo:(NSString *)filePath{
    NSLog(@"Video is not implimented yet");
}


-(BOOL) isPlayingCurrentKey : (NSString * )key{
    
    return (self.audioPlayer && [ self.key isEqualToString:key]);
    
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - ALMedia player delegates + AVAudioPlayerDelegate
//------------------------------------------------------------------------------------------------------------------

-(void) getProgressOfTrack
{
    [self.delegate getProgressOfTrack];
}


-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.timer invalidate];
    [self.delegate audioPlayerDidFinishPlaying:player successfully:flag];
}

+(NSString* )getTotalDuration:(NSString *)path
{
    NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * filePath = [docDir stringByAppendingPathComponent:path];
    NSURL * soundFileURL = [NSURL fileURLWithPath:filePath];

    NSError * error;
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
    return [self getFormattedTime:player.duration];
}

+(NSString*) getFormattedTime:(float)seconds
{
    NSInteger min = ((int)seconds/60) % 60;
    NSInteger sec = ((int)seconds % 60);

    NSString * minStr = [[NSString alloc] initWithFormat:@"%ld", (long)min];
    NSString * secStr = [[NSString alloc] initWithFormat:@"%ld", (long)sec];

    if(sec < 10) {
        secStr = [[NSString alloc] initWithFormat:@"0%@", secStr];
    }
    return [[NSString alloc] initWithFormat:@"%@:%@", minStr, secStr];
}
@end
