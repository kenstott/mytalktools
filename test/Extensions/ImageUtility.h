//
//  ImageUtility.h
//  iphoneComm
//
//  Created by Ken Stott on 10/5/11.
//  Copyright 2011 Second Half Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface ImageUtility : NSObject

+ (long)orientationForTrack:(AVAsset *)asset;

+ (long)orientationForTrackByUrl:(NSURL *)url;

+ (UIImage *)scaleAndRotateImage:(UIImage *)image;

+ (UIImage *)scaleAndRotateImage:(UIImage *)image setWidth:(int)scaleWidth setHeight:(int)scaleHeight;

+ (UIImage *)scaleAndRotateImage:(UIImage *)image setWidth:(int)scaleWidth setHeight:(int)scaleHeight setOrientation:(UIImageOrientation)orientation;

+ (UIImage *)scaleAndRotateImage:(UIImage *)image orientation:(UIImageOrientation)orient;

@end
