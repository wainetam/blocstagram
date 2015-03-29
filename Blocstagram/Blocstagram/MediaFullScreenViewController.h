//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Waine Tam on 3/10/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *shareButton;

- (instancetype) initWithMedia:(Media *)media;
- (void) centerScrollView;
- (void) recalculateZoomScale;

@end
