//
//  LikeButton.h
//  Blocstagram
//
//  Created by Waine Tam on 3/16/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LikeState) {
    LikeStateNotLiked = 0,
    LikeStateLiking = 1,
    LikeStateLiked = 2,
    LikeStateUnliking = 3
};

@interface LikeButton : UIButton

// The current state of the like button
// Setting to NotLiked or Liked will display an empty heart or a heart, respectively. Setting to Liking or Unliking will display an activity indicator and disable button taps until the button is set to NotLiked or Liked.
@property (nonatomic, assign) LikeState likeButtonState;

@end
