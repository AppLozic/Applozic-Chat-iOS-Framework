//
//  ALMultipleAttachmentView.h
//  Applozic
//
//  Created by devashish on 29/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALCollectionReusableView.h"

@protocol ALMUltipleAttachmentDelegate <NSObject>
@required

-(void) multipleAttachmentProcess:(NSMutableArray *)attachmentPathArray andText:(NSString *)messageText;

@end

@interface ALMultipleAttachmentView : UICollectionViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray * imageArray;
@property (nonatomic, strong) NSMutableArray * mediaFileArray;

@property (nonatomic, strong) UIImage * classImage;
@property (nonatomic, strong) NSString * classVideoPath;

@property (nonatomic, weak) id <ALMUltipleAttachmentDelegate> multipleAttachmentDelegate;

@end
