//
//  CommentView.m
//  Blocstagram
//
//  Created by Waine Tam on 4/5/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ComposeCommentView.h"
#import "comment.h"

@interface CommentView : XCTestCase

@end

@implementation CommentView

- (void)setUp {
    [super setUp];

//    ComposeCommentView *ccView = [[ComposeCommentView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
//    - (void) setText:(NSString *)text {
//        _text = text;
//        self.textView.text = text;
//        self.textView.userInteractionEnabled = YES;
//        self.isWritingComment = text.length > 0;
//    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testSetText {
    ComposeCommentView *ccView = [[ComposeCommentView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    ccView.text = @"hello";
    
//    XCTAssertTrue(testMedia.likeState == LikeStateLiked);
    XCTAssertTrue(ccView.isWritingComment == YES);
    
}

- (void)testSetNoText {
    ComposeCommentView *ccView = [[ComposeCommentView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    ccView.text = @"";
    
    XCTAssertTrue(ccView.isWritingComment == NO);
    
}




@end
