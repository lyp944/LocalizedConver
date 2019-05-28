//
//  LYPRegExp.m
//  LocalizedConver
//
//  Created by Mega on 2019/5/28.
//

#import "LYPRegExp.h"

@implementation LYPRegExp
+(NSArray*)fourArrayMatchesInString:(NSString *)readString{
    
    if (readString.length < 1) {
        return nil;
    }
    
    //找出所有注释 和 NSLog、MGlog、Dlog
    NSMutableArray *ignoreRangeArray = [NSMutableArray new];
    NSString *pattern0 = @"(/\\*.*\\*/|//.*|[NS|MG|D]Log(.*))";
    NSRegularExpression *regex0 = [NSRegularExpression regularExpressionWithPattern:pattern0 options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray * matches0 = [regex0 matchesInString:readString options:0 range:NSMakeRange(0, [readString length])];
    for (NSTextCheckingResult *match in matches0) {
        
        for (int i = 1; i < [match numberOfRanges]; i++) {
            NSRange range = [match rangeAtIndex:i];
            if (range.location == NSNotFound) {
                continue;
            }
            
            NSValue *value = [NSValue valueWithRange:range];
//            NSString *string = [readString substringWithRange:range];
//            NSLog(@"%@",string);
            [ignoreRangeArray addObject:value];
            
        }
    }
    
    //找出所有汉字 (@"[^"]*[\u4E00-\u9FA5]+[^"\n]*?")\s*  中文
    NSString *pattern = @"(@\"([^\"]*[\u4E00-\u9FA5]+[^\"\n]*?)\")\\s*";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray * matches = [regex matchesInString:readString options:0 range:NSMakeRange(0, [readString length])];
    
    //eg:@"你好"
    NSMutableArray *stringRangeArray = [NSMutableArray new];
    NSMutableArray *stringArray = [NSMutableArray new];
    
    //eg:你好
    NSMutableArray *subStringRangeArray = [NSMutableArray new];
    NSMutableArray *subStringArray = [NSMutableArray new];
    
    for (NSTextCheckingResult *match in matches) {
        
        for (int i = 1; i < [match numberOfRanges]; i++) {
            NSRange range = [match rangeAtIndex:i];
            NSValue *value = [NSValue valueWithRange:range];
            NSString *string = [readString substringWithRange:range];
            
            BOOL shouldIgnore = NO;
            //忽略注释中的文字
            for (NSValue *ignoreValue in ignoreRangeArray) {
                NSRange ignoreRange = ignoreValue.rangeValue;
                if (NSIntersectionRange(ignoreRange, range).length > 0) {
                    shouldIgnore = YES;
                    break;
                }
            }
            
            if (shouldIgnore) {
                continue;
            }
            
            //            NSLog(@"%@",string);
            if (i == 1) {
                //pattern 1
                [stringRangeArray addObject:value];
                [stringArray addObject:string];
            }else{
                //pattern 2
                [subStringRangeArray addObject:value];
                [subStringArray addObject:string];
            }
            
        }
    }
    
    return @[stringRangeArray,stringArray,subStringRangeArray,subStringArray];
}
@end
