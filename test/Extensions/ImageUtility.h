//
//  ImageUtility.h
//  iphoneComm
//
//  Created by Ken Stott on 10/5/11.
//  Copyright 2011 Second Half Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ImageUtility : NSObject

+ (long)orientationForTrack:(AVAsset *)asset;

+ (long)orientationForTrackByUrl:(NSURL *)url;

@end
