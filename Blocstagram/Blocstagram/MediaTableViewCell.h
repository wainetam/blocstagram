//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Waine Tam on 2/16/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class Media;
@class Media, MediaTableViewCell;

 // custom delegate
@protocol MediaTableViewCellDelegate <NSObject>

- (void) cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;
- (void) cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;
- (void) cell:(MediaTableViewCell *)cell didTwoFingerTapImageView:(UIImageView *)imageView;

@end

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;
@property (nonatomic, weak) id <MediaTableViewCellDelegate> delegate;

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

// get the media item
- (Media *)mediaItem;

// set a new media item
- (void)setMediaItem:(Media *)mediaItem;

@end
