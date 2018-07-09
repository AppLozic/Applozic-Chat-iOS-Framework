//
//  ALLocationCell.h
//  Applozic
//
//  Created by devashish on 01/04/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//
/*********************************************************************
 TABLE CELL CUSTOM CLASS : THIS CLASS IS FOR LOCATION CELL
 **********************************************************************/

#import <UIKit/UIKit.h>
#import "ALMediaBaseCell.h"

@interface ALLocationCell : ALMediaBaseCell

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize;
-(NSString*)getLocationUrl:(ALMessage*)almessage;

@end
