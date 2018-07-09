//
//  UIImage+Utility.m
//  ChatApp
//
//  Created by shaik riyaz on 22/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "UIImage+Utility.h"
#import "ALChatViewController.h"
#import "ALApplozicSettings.h"

#define  DEFAULT_MAX_FILE_UPLOAD_SIZE 32

@implementation UIImage (Utility)

-(double)getImageSizeInMb
{
    NSData * imageData = UIImageJPEGRepresentation(self, 1);
    
    return (imageData.length/1024.0)/1024.0;
}

//-(BOOL)islandScape
//{
//    return self.size.width>self.size.height?YES:NO;
//}

-(UIImage *)getCompressedImageLessThanSize:(double)sizeInMb
{
    
    UIImage * originalImage = self;
    
    NSData * theImageData = UIImageJPEGRepresentation(originalImage,1);
    
    int numberOfAttempts = 0;
    
    while (self.getImageSizeInMb > sizeInMb && numberOfAttempts < 5) {
        
        numberOfAttempts = numberOfAttempts + 1;
        
        theImageData = UIImageJPEGRepresentation(self,0.9);
        
        originalImage = [UIImage imageWithData:theImageData];
        
    }
    
    return originalImage;
}

-(NSData *)getCompressedImageData
{
    
    CGFloat compression = 1.0f;
    CGFloat maxCompression = [ALApplozicSettings getMaxCompressionFactor];
    NSInteger maxSize =( [ALApplozicSettings getMaxImageSizeForUploadInMB]==0 )? DEFAULT_MAX_FILE_UPLOAD_SIZE : [ALApplozicSettings getMaxImageSizeForUploadInMB];
    NSData *imageData = UIImageJPEGRepresentation(self, compression);
    
    while (((imageData.length/1024.0)/1024.0) > maxSize & compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(self, compression);
        
    }
    return imageData;
    
}


@end
