//
//  ImageUtility.m
//  test
//
//  Created by Kenneth Stott on 5/10/23.
//

#import <Foundation/Foundation.h>
#import "ImageUtility.h"
#import <CoreGraphics/CGImage.h>
#import <UIKit/UIKit.h>
@import CoreGraphics;

@implementation ImageUtility

+ (long)orientationForTrack:(AVAsset *)asset {
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIInterfaceOrientationPortrait;
}

+ (long)orientationForTrackByUrl:(NSURL *)url {
    AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
    return [ImageUtility orientationForTrack:avAsset];
}

// Code for image scaling and rotating
+ (UIImage *)fixAndRotateImage:(UIImage *)image setWidth:(int)scaleWidth setHeight:(int)scaleHeight {
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > scaleWidth || height > scaleHeight) {
        CGFloat ratio = width / height;
        if (bounds.size.height > scaleHeight) {
            bounds.size.height = scaleHeight;
            bounds.size.width = bounds.size.height * ratio;
        }
        if (bounds.size.width > scaleWidth) {
            bounds.size.width = scaleWidth;
            bounds.size.height = bounds.size.width / ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    UIImageOrientation orient = image.imageOrientation;
    switch (orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, (CGFloat) -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, (CGFloat) M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, (CGFloat) -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, (CGFloat) -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, (CGFloat) (3.0 * M_PI / 2.0));
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, (CGFloat) (3.0 * M_PI / 2.0));
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            transform = CGAffineTransformMakeScale((CGFloat) -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, (CGFloat) (M_PI / 2.0));
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, (CGFloat) (M_PI / 2.0));
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid Image Orientation"];
            
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(scaleWidth, scaleHeight));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    if (image.size.width > image.size.height) {
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, - (image.size.width - image.size.height) / 2, width, height), imgRef);
    }
    else {
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake( (image.size.height - image.size.width) / 2, 0, width, height), imgRef);
    }
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

+ (UIImage *)scaleAndRotateImage:(UIImage *)image setWidth:(int)scaleWidth setHeight:(int)scaleHeight setOrientation:(UIImageOrientation)orientation {
    
    if (scaleHeight < 0 || scaleWidth < 0) return nil;
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    if (scaleHeight == 0) {
        scaleHeight = (int) height;
    }
    if (scaleWidth == 0) {
        scaleWidth = (int) width;
    }
    
    CGAffineTransform transform;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > scaleWidth || height > scaleHeight) {
        CGFloat ratio = width / height;
        if (bounds.size.height > scaleHeight) {
            bounds.size.height = scaleHeight;
            bounds.size.width = bounds.size.height * ratio;
        }
        if (bounds.size.width > scaleWidth) {
            bounds.size.width = scaleWidth;
            bounds.size.height = bounds.size.width / ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    if (orientation != UIImageOrientationUp) {
        orient = orientation;
    }
    switch (orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, (CGFloat) -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, (CGFloat) M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, (CGFloat) -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, (CGFloat) -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, (CGFloat) (3.0 * M_PI / 2.0));
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, (CGFloat) (3.0 * M_PI / 2.0));
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale((CGFloat) -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, (CGFloat) (M_PI / 2.0));
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, (CGFloat) (M_PI / 2.0));
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid Image Orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!context) {
        return nil;
    }
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

+ (UIImage *)scaleAndRotateImage:(UIImage *)image setWidth:(int)scaleWidth setHeight:(int)scaleHeight {
    CGImageRef imgRef = image.CGImage;
    CGFloat hRatio = scaleHeight / image.size.height;
    CGFloat wRatio = scaleWidth / image.size.width;
    CGFloat ratio = 1 / MAX(hRatio, wRatio);
    return [UIImage imageWithCGImage:imgRef scale:ratio orientation:image.imageOrientation];
}

+ (UIImage *)scaleAndRotateImage:(UIImage *)image {
    return [ImageUtility scaleAndRotateImage:image orientation:image.imageOrientation];
}

+ (UIImage *)scaleAndRotateImage:(UIImage *)image orientation:(UIImageOrientation)orient {
    CGImageRef imgRef = image.CGImage;
    CGFloat scaleHeight = 1024.0f;
    CGFloat scaleWidth = 1024.0f;
    CGFloat hRatio = scaleHeight / image.size.height;
    CGFloat wRatio = scaleWidth / image.size.width;
    CGFloat ratio = 1 / MIN(MAX(hRatio, wRatio), 1);
    return [UIImage imageWithCGImage:imgRef scale:ratio orientation:UIImageOrientationUp];
}

@end
