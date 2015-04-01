//
//  Media.m
//  Blocstagram
//
//  Created by Waine Tam on 2/15/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "Media.h"
#import "User.h"
#import "Comment.h"
#import "ImagesTableViewController.h"
//#import "MediaFullScreenViewController.h"

@implementation Media

- (instancetype) initWithDictionary:(NSDictionary *)mediaDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = mediaDictionary[@"id"];
        self.user = [[User alloc] initWithDictionary:mediaDictionary[@"user"]];
        NSString *standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
        NSURL *standardResolutionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResolutionImageURL) {
            self.mediaURL = standardResolutionImageURL;
            self.downloadState = MediaDownloadStateNeedsImage;
        } else {
            self.downloadState = MediaDownloadStateNonRecoverableError;
        }
        
        NSDictionary *captionDictionary = mediaDictionary[@"caption"];
        
        if ([captionDictionary isKindOfClass:([NSDictionary class])]) {
            self.caption = captionDictionary[@"text"];
        } else {
            self.caption = @"";
        }
        
        NSMutableArray *commentsArray = [NSMutableArray array];
        
        for (NSDictionary *commentDictionary in mediaDictionary[@"comments"][@"data"]) {
            Comment *comment = [[Comment alloc] initWithDictionary:commentDictionary];
            [commentsArray addObject:comment];
            
        }
        
        self.comments = commentsArray;
        
        BOOL userHasLiked = [mediaDictionary[@"user_has_liked"] boolValue];
        self.likeState = userHasLiked ? LikeStateLiked : LikeStateNotLiked;
        self.likeCount = (int)mediaDictionary[@"likes"][@"count"];
//        NSLog(@"%d", self.likeCount);
    }
    
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.idNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(idNumber))];
        self.user = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user))];
        self.mediaURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mediaURL))];
        self.image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
        
        if (self.image) {
            self.downloadState = MediaDownloadStateHasImage;
        } else if (self.mediaURL) {
            self.downloadState = MediaDownloadStateNeedsImage;
        } else {
            self.downloadState = MediaDownloadStateNonRecoverableError;
        }
        
        self.caption = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(caption))];
        self.comments = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(comments))];
        self.likeState = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(likeState))];
        self.likeCount = (int)[aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(likeCount))];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.user forKey:NSStringFromSelector(@selector(user))];
    [aCoder encodeObject:self.mediaURL forKey:NSStringFromSelector(@selector(mediaURL))];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
    [aCoder encodeObject:self.caption forKey:NSStringFromSelector(@selector(caption))];
    [aCoder encodeObject:self.comments forKey:NSStringFromSelector(@selector(comments))];
    [aCoder encodeInteger:self.likeState forKey:NSStringFromSelector(@selector(likeState))];
    [aCoder encodeInteger:(int)self.likeCount forKey:NSStringFromSelector(@selector(likeCount))];
}

- (void) shareMediaWithViewController: (UIViewController *)vc {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (self.caption.length > 0) {
        [itemsToShare addObject:self.caption];
    }
    
    if (self.image) {
        [itemsToShare addObject:self.image];
    }
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        if (isPhone) {
            [vc presentViewController:activityVC animated:YES completion:nil];
        } else {
            UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityVC];
            popup.popoverContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 480);
            
            UIImageView *imageView = ((ImagesTableViewController *)vc).lastLongPressedImageView;
            CGFloat imageViewX = imageView.frame.origin.x;
            CGFloat imageViewY = imageView.frame.origin.y;
            // QUESTION: why always get same x, y coords
            
            CGRect imageViewRect = CGRectMake(imageViewX, imageViewY, imageView.frame.size.width, imageView.frame.size.height);
            
            ((ImagesTableViewController *)vc).sharePopover = popup;
            
            [((ImagesTableViewController *)vc).sharePopover presentPopoverFromRect:imageViewRect inView:imageView.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

@end
