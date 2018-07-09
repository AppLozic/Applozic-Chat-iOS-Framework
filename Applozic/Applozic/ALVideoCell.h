//
//  ALVideoCell.h
//  Applozic
//
//  Created by devashish on 24/02/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//
/*********************************************************************
 TABLE CELL CUSTOM CLASS : THIS CLASS IS FOR VIDEO MESSSAGE
 VIDEO CAN BE RECORDED OR PICKED FROM GALLERY
 **********************************************************************/

#import <Applozic/Applozic.h>

@interface ALVideoCell : ALMediaBaseCell

-(instancetype) populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize;

-(void) videoFullScreen:(UITapGestureRecognizer *)sender;
-(void) downloadRetryAction;
-(void)setVideoThumbnail:(NSString *)videoFilePATH;

@property (nonatomic, strong) UITapGestureRecognizer *tapper;
@property (nonatomic, strong) NSURL *videoFileURL;

@property (nonatomic, strong) UIImageView * videoPlayFrontView;

@end
