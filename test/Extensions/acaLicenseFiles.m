//
//  acaLicenseFiles.m
//  acaBenchiPhone
//
//  Created by Sebastien Boero on 9/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "acaLicenseFiles.h"


@implementation acaLicenseFiles

+ (NSInteger)userID {

    return 0x01c7b439;
}

+ (NSInteger)pwd {

    return 0x00004427;
}

+ (NSString *)license {

    return [[NSString alloc] initWithCString:"\"5526 0 NSCA #EVALUATION#NSCAPI Acapela-group\"\nV26UONwcfvic6afGbd7I4HNp@%c6$2izATv3eewbWWeizdgNUtTmJra!PWN@\nY2JQ!X5RzKm$jkMBJKEZnHo3NvvRSYtDbaaGtQ##\nXGHCxjY%ZnKXmxxXeViL\n" encoding:NSASCIIStringEncoding];
}


@end
