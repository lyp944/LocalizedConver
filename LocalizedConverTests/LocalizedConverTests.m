//
//  LocalizedConverTests.m
//  LocalizedConverTests
//
//  Created by Mega on 2019/5/23.
//
#import <XCTest/XCTest.h>
#import "LYPRegExp.h"



@interface LocalizedConverTests : XCTestCase
@property (strong , nonatomic) NSString *testString;
@end

@implementation LocalizedConverTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestVC" ofType:@"txt"];
    NSFileHandle *readFileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    self.testString = [[NSString alloc] initWithData:readFileHandle.availableData encoding:NSUTF8StringEncoding];
}
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
  
    
    
    
    NSArray *arrays = [LYPRegExp fourArrayMatchesInString:self.testString];
    
    XCTAssertNotNil(arrays);
    
    //eg:@"你好"
    NSMutableArray *stringRangeArray = arrays[0];
    NSRange stringRange = [stringRangeArray.firstObject rangeValue];
    NSMutableArray *stringArray = arrays[1];
    
    //eg:你好
    NSMutableArray *subStringRangeArray = arrays[2];
    NSRange subStringRange = [subStringRangeArray.firstObject rangeValue];
    NSMutableArray *subStringArray = arrays[3];
    
    
    XCTAssertTrue(NSEqualRanges(stringRange, [self.testString rangeOfString:@"@\"我是应该被替换的字符窜\""]));
    XCTAssertEqualObjects(stringArray, @[@"@\"我是应该被替换的字符窜\""]);
    
    XCTAssertTrue(NSEqualRanges(subStringRange, [self.testString rangeOfString:@"我是应该被替换的字符窜"]));
    XCTAssertEqualObjects(subStringArray, @[@"我是应该被替换的字符窜"]);
    XCTAssertEqualObjects(subStringRangeArray, @[[NSValue valueWithRange:[self.testString rangeOfString:@"我是应该被替换的字符窜"]]]);

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
