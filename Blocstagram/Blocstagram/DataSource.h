//
//  DataSource.h
//  Blocstagram
//
//  Created by Waine Tam on 2/15/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Media;

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface DataSource : NSObject

+ (instancetype) sharedInstance;

//QUESTION: why a class property
+ (NSString *) instagramClientID;

//@property (nonatomic, strong, readonly) NSArray *mediaItems;
@property (nonatomic, strong) NSMutableArray *mediaItems;
@property (nonatomic, strong, readonly) NSString *accessToken;

- (void)deleteMediaItem:(Media *)item;

- (void)requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
- (void)requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;

@end
