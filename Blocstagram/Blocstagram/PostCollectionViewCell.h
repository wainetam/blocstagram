//
//  SelectViewCell.h
//  Blocstagram
//
//  Created by Waine Tam on 3/29/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostCollectionViewCell : UICollectionViewCell

//@property (nonatomic, assign) NSInteger imageViewTag;
//@property (nonatomic, assign) NSInteger labelTag;
//@property (nonatomic, assign) CGFloat edgeSize;
@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UILabel *label;

- (PostCollectionViewCell *)layoutWithEdgeSize:(CGFloat)size;

@end
