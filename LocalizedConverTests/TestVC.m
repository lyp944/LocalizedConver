//
//  TestVC.m
//  LocalizedConverTests
//
//  Created by Mega on 2019/5/28.
//

#import "TestVC.h"

@interface TestVC ()

@end

@implementation TestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    /*
    NSString *a = @"我是注释//*//*/中的字符串";
    NSLog(@"我是注释中NSLog中的字符串")；
    */
    
   // NSString *b = @"我是注释//中的字符串";
    NSLog(@"我是NSLog中的字符串");
    
    NSString *f = @"我是应该被替换的字符窜";
    NSLog(@"%@",f);
    
    NSString *d = @"我是应该被替换的字符窜,而且我超过20个字符没办法";
    NSLog(@"%@",d);
    




}

@end
