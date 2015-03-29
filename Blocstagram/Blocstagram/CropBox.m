//
//  CropBox.m
//  Blocstagram
//
//  Created by Waine Tam on 3/28/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "CropBox.h"

@interface CropBox ()

@property (nonatomic, strong) NSArray *horizonalLines;
@property (nonatomic, strong) NSArray *verticalLines;

@end

@implementation CropBox

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
    }
    
    // initialization code
    NSArray *lines = [self.horizonalLines arrayByAddingObjectsFromArray:self.verticalLines];
    for (UIView *lineView in lines) {
        [self addSubview:lineView];
    }
    
    return self;
}

- (NSArray *) horizonalLines {
    if (!_horizonalLines) {
        _horizonalLines = [self newArrayOfFourWhiteViews];
    }
    
    return _horizonalLines;
}

- (NSArray *) verticalLines {
    if (!_verticalLines) {
        _verticalLines = [self newArrayOfFourWhiteViews];
    }
    
    return _verticalLines;
}

- (NSArray *) newArrayOfFourWhiteViews {
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < 4; i++) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        [array addObject:view];
    }
    
    return array;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.frame);
    
    CGFloat thirdOfWidth = width / 3;
    
    for (int i = 0; i < 4; i++) {
        UIView *horizonalLine = self.horizonalLines[i];
        UIView *verticalLine = self.verticalLines[i];
        
        horizonalLine.frame = CGRectMake(0, (i * thirdOfWidth), width, 0.5);
        
        CGRect verticalFrame = CGRectMake(i * thirdOfWidth, 0, 0.5, width);
        
        if (i == 3) {
            verticalFrame.origin.x -= 0.5;
        }
        
        verticalLine.frame = verticalFrame;
    }
}



@end
