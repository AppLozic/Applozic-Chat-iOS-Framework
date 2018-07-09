//
//  ALImagePickerController.m
//  Applozic
//
//  Created by devashish on 30/07/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALImagePickerController.h"

@interface ALImagePickerController ()

@end

@implementation ALImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(orientation == UIDeviceOrientationLandscapeRight || orientation == UIDeviceOrientationLandscapeLeft)
        return UIInterfaceOrientationMaskLandscape;
    else
        return UIInterfaceOrientationMaskPortrait;
}

@end
