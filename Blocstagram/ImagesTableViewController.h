//
//  ImagesTableViewController.h
//  Blocstagram
//
//  Created by Waine Tam on 2/15/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagesTableViewController : UITableViewController

//@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, weak) UIImageView *lastTappedImageView;
@property (nonatomic, weak) UIImageView *lastLongPressedImageView;
@property (nonatomic, strong) UIPopoverController *cameraPopover;
@property (nonatomic, strong) UIPopoverController *sharePopover;

@end

