//
//  ALNavigationController.m
//  Applozic
//
//  Created by Adarsh Kumar Mishra on 12/7/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALNavigationController.h"



@implementation ALNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)customNavigationItemClicked:(id)sender withTag:(NSString*)tag{
    NSLog(@"baseController ALNavigationController...");
}

-(NSMutableArray*)getCustomButtons
{
    NSLog(@" Base getCustomButtonView");
    return nil;
}

@end
