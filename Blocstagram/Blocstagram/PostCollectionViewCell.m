//
//  SelectViewCell.m
//  Blocstagram
//
//  Created by Waine Tam on 3/29/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "PostCollectionViewCell.h"

static NSInteger imageViewTag = 1000;
static NSInteger labelTag = 1001;

@interface PostCollectionViewCell ()

@property (nonatomic, assign) NSInteger imageViewTag;
@property (nonatomic, assign) NSInteger labelTag;
@property (nonatomic, assign) CGFloat edgeSize;

@end

@implementation PostCollectionViewCell

- (instancetype) init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (PostCollectionViewCell *)layoutWithEdgeSize:(CGFloat)size {
    self.edgeSize = size;
        
    self.thumbnail = (UIImageView *)[self.contentView viewWithTag:imageViewTag];
    self.label = (UILabel *)[self.contentView viewWithTag:labelTag];
    
    if (!self.thumbnail) {
        self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, self.edgeSize, self.edgeSize)];
        self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnail.tag = imageViewTag;
        self.thumbnail.clipsToBounds = YES;
        
        [self.contentView addSubview:self.thumbnail];
    }
    
    if (!self.label) {
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.edgeSize, self.edgeSize, 20)];
        self.label.tag = labelTag;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
        [self.contentView addSubview:self.label];
    }
    
    return self;
}

@end
