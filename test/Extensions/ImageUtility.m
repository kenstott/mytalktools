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

@end
