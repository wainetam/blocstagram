//
//  UIImage+ImageUtilities.h
//  Blocstagram
//
//  Created by Waine Tam on 3/23/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageUtilities)

- (UIImage *) imageWithFixedOrientation;
- (UIImage *) imageResizedToMatchAspectRatioOfSize:(CGSize)size;
- (UIImage *) imageCroppedToRect:(CGRect)cropRect;

- (UIImage *) imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect;

@end
