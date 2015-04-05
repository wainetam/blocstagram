//
//  MediaTests.m
//  Blocstagram
//
//  Created by Waine Tam on 4/4/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Media.h"
#import "User.h"
#import "Comment.h"

@interface MediaTests : XCTestCase

@end

@implementation MediaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testThatInitializationWorks {
    
    NSDictionary *userDictionary = @{@"id":@"8675309",
                                       @"username":@"d'oh",
                                       @"full_name":@"Homer Simpson",
                                       @"profile_picture":@"http://www.example.com/example.jpg"};

    NSDictionary *fromUserDictionary = @{@"id":@"274",
                                     @"username":@"SaxophoneLady",
                                     @"full_name":@"Lisa Simpson",
                                     @"profile_picture":@"http://www.example.com/example.jpg"};

    NSDictionary *commentDictionary = @{@"id":@"123",
                                        @"text":@"Don't have a cow, man",
                                        @"from":fromUserDictionary};
    
    Comment *newComment = [[Comment alloc]initWithDictionary:commentDictionary];
    
    NSDictionary *mediaDictionary = @{@"id":@"911",
                                      @"user":userDictionary,
                                      @"images":@{@"standard_resolution":@{@"url":@"www.apple.com"}},
                                      @"caption":@{@"text":@"hello testing"},
                                      @"comments":@{@"data":@[commentDictionary]},
                                      @"likes":@{@"count":@88},
                                      @"user_has_liked":@YES};
    
    NSString *standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
    NSURL *standardResolutionImageURL = [NSURL URLWithString:standardResolutionImageURLString];

    Media *testMedia = [[Media alloc] initWithDictionary:mediaDictionary];
    
    XCTAssertEqualObjects(testMedia.idNumber, mediaDictionary[@"id"]);
    XCTAssertEqualObjects(testMedia.mediaURL, standardResolutionImageURL);
    XCTAssertEqualObjects(testMedia.caption, mediaDictionary[@"caption"][@"text"]);
    XCTAssertTrue(testMedia.likeCount == (int)@88);
    XCTAssertTrue(testMedia.likeState == LikeStateLiked);
    
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
