//
//  DataSource.h
//  Blocstagram
//
//  Created by Waine Tam on 2/15/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSource : NSObject

+ (instancetype) sharedInstance;

//@property (nonatomic, strong, readonly) NSArray *mediaItems;
@property (nonatomic, strong) NSMutableArray *mediaItems;

@end