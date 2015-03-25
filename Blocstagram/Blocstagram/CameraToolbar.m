//
//  CameraToolbar.m
//  Blocstagram
//
//  Created by Waine Tam on 3/23/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "CameraToolbar.h"

@interface CameraToolbar ()

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) UIView *purpleView;

@end

@implementation CameraToolbar

// QUESTION: can you create any init function after alloc?
- (instancetype) initWithImageNames:(NSArray *)imageNames {
    self = [super init];
    
    if (self) {
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.leftButton addTarget:self action:@selector(leftButtonPressedOnToolbar:) forControlEvents: UIControlEventTouchUpInside];

        [self.cameraButton addTarget:self action:@selector(cameraButtonPressedOnToolbar:) forControlEvents: UIControlEventTouchUpInside];

        [self.rightButton addTarget:self action:@selector(rightButtonPressedOnToolbar:) forControlEvents: UIControlEventTouchUpInside];
    
        [self.leftButton setImage:[UIImage imageNamed:imageNames.firstObject] forState:UIControlStateNormal];

        [self.rightButton setImage:[UIImage imageNamed:imageNames.lastObject] forState:UIControlStateNormal];

        [self.cameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        
        [self.cameraButton setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 15, 10)]; // top, left, bottom, right
        
        self.whiteView = [UIView new];
        self.whiteView.backgroundColor = [UIColor whiteColor];
        
        self.purpleView = [UIView new];
        self.purpleView.backgroundColor = [UIColor colorWithRed:0.345 green:0.318 blue:0.424 alpha:1]; // #58516c
    }
    
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    // QUESTION: where did we set the bounds?
    CGRect whiteFrame = self.bounds;
    whiteFrame.origin.y += 10;
    self.whiteView.frame = whiteFrame;
    
    CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 3;
    NSArray *buttons = @[self.leftButton, self.cameraButton, self.rightButton];
    
    for (int i = 0; i < 3; i++) {
        UIButton *button = buttons[i];
        button.frame = CGRectMake(i * buttonWidth, 10, buttonWidth, CGRectGetHeight(whiteFrame));
    }
    
    self.purpleView.frame = CGRectMake(buttonWidth, 0, buttonWidth, CGRectGetHeight(self.bounds));
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.purpleView.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10.0, 10.0)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.purpleView.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.purpleView.layer.mask = maskLayer;
}

# pragma mark - Button Handlers

- (void) leftButtonPressedOnToolbar:(UIButton *)sender {
    [self.delegate leftButtonPressedOnToolbar:self];
}

- (void) rightButtonPressedOnToolbar:(UIButton *)sender {
    [self.delegate rightButtonPressedOnToolbar:self];
}

- (void) cameraButtonPressedOnToolbar:(UIButton *)sender {
    [self.delegate cameraButtonPressedOnToolbar:self];
}

@end
