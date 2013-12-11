//
//  mYoutubeTestAppTests.m
//  mYoutubeTestAppTests
//
//  Created by Kabkee Moon on 2013. 12. 8..
//  Copyright (c) 2013년 Kabkee Moon. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ViewController.h"

@interface mYoutubeTestAppTests : XCTestCase

@end

@implementation mYoutubeTestAppTests
{
    ViewController *vc;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    vc = [[ViewController alloc]init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFetchMyChannelList
{


}

@end
