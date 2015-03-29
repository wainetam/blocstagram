//
//  CropImageViewController.m
//  Blocstagram
//
//  Created by Waine Tam on 3/28/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "CropImageViewController.h"
#import "CropBox.h"
#import "Media.h"
#import "UIImage+ImageUtilities.h"

@interface CropImageViewController ()

@property (nonatomic, strong) CropBox *cropBox;
@property (nonatomic, assign) BOOL hasLoadedOnce;
@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;

@end

@implementation CropImageViewController

- (instancetype) initWithImage:(UIImage *)sourceImage {
    self = [super init];
    
    if (self) {
        self.media = [[Media alloc] init];
        self.media.image = sourceImage;
        self.cropBox = [CropBox new];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.shareButton removeFromSuperview]; // remove share button inherited from parent class
    
    self.view.clipsToBounds = YES;
    
    [self.view addSubview:self.cropBox];

    // create crop image button in nav bar
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Crop", @"Crop command") style:UIBarButtonItemStyleDone target:self action:@selector(cropPressed:)];
    
    self.navigationItem.title = NSLocalizedString(@"Crop Image", nil);
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // disable UINavController's behavior of automatically adjusting scroll view insets
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    
    // translucent top and bottom UIToolbars
    self.topView = [UIToolbar new];
    self.bottomView = [UIToolbar new];
    
    UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
    self.topView.barTintColor = whiteBG; // barTintColor is like backgroundColor but it'll be translucent when rendered
    self.bottomView.barTintColor = whiteBG;
    self.topView.alpha = 0.5;
    self.bottomView.alpha = 0.5;
    
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect cropRect = CGRectZero;
    
    CGFloat edgeSize = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    cropRect.size = CGSizeMake(edgeSize, edgeSize);
    
    CGSize size = self.view.frame.size;
    
    self.cropBox.frame = cropRect;
    self.cropBox.center = CGPointMake(size.width / 2, size.height / 2);
    self.scrollView.frame = self.cropBox.frame;
    self.scrollView.clipsToBounds = NO;

    self.topView.frame = CGRectMake(0, self.topLayoutGuide.length, edgeSize, CGRectGetMinY(self.cropBox.frame) - self.topLayoutGuide.length);
    self.bottomView.frame = CGRectMake(0, CGRectGetMaxY(self.cropBox.frame), edgeSize, self.view.frame.size.height - CGRectGetMaxY(self.cropBox.frame));
    
    [self recalculateZoomScale];
    
    if (self.hasLoadedOnce == NO ) {
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        self.hasLoadedOnce = YES;
    }
}

- (void) cropPressed:(UIBarButtonItem *)sender {
    CGRect visibleRect;
    float scale = 1.0f / self.scrollView.zoomScale / self.media.image.scale;
    visibleRect.origin.x = self.scrollView.contentOffset.x * scale;
    visibleRect.origin.y = self.scrollView.contentOffset.y * scale;
    visibleRect.size.width = self.scrollView.bounds.size.width * scale;
    visibleRect.size.height = self.scrollView.bounds.size.height * scale;
    
    UIImage *scrollViewCrop = [self.media.image imageWithFixedOrientation];
    scrollViewCrop = [scrollViewCrop imageCroppedToRect:visibleRect];
    
    [self.delegate cropControllerFinishedWithImage:scrollViewCrop];
}

@end
