//
//  ALAudioVideoBaseVC.m
//  Applozic
//
//  Created by Abhishek Thapliyal on 1/12/17.
//  Copyright © 2017 applozic Inc. All rights reserved.
//

#import "ALAudioVideoBaseVC.h"
#import "ALVOIPNotificationHandler.h"


@interface ALAudioVideoBaseVC ()

@end

@implementation ALAudioVideoBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
     [super viewWillDisappear:animated];
}

+(BOOL)chatRoomEngage
{
    return chatRoomEngage;
}

+(void)setChatRoomEngage:(BOOL)flag
{
    chatRoomEngage = flag;
}

-(void)dismissAVViewController:(BOOL)animated
{

}

-(void)handleDataConnectivity
{
    
}

@end
