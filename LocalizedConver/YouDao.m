//
//  YouDao.m
//  LocalizedConver
//
//  Created by Mega on 2019/5/28.
//

#include <CommonCrypto/CommonCrypto.h>
#import "AFNetworking.h"
#import "YouDao.h"

#error 去有道翻译开放平台申请key:https://ai.youdao.com

//下面的key不可用
#define YouDaoKey @"p5d2caf49fd1c5716"
#define YouDaoSecret @"nVzKxFiSwGzwEBBpiuuOj4DJLFwFLJtq"


@interface NSData (encrypt)
@end
@implementation NSData (encrypt)
- (NSData *)sha256Data {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(self.bytes, (CC_LONG)self.length, result);
    return [NSData dataWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)sha256String {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(self.bytes, (CC_LONG)self.length, result);
    NSMutableString *hash = [NSMutableString
                             stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

@end



@interface YouDao ()
@property (strong , nonatomic) AFHTTPSessionManager *manager;

@end
@implementation YouDao

+(instancetype)shared {
    static YouDao *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YouDao alloc]init];
    });
    return instance;
}

-(instancetype)init {
    if (self = [super init]) {
        NSURL *url = [NSURL URLWithString:@"https://openapi.youdao.com/api"];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithBaseURL:url];
        manager.requestSerializer.timeoutInterval = 60;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];

        _manager = manager;
    }
    return self;
}

//https://ai.youdao.com/docs/doc-trans-api.s#p04
+(void)translate:(NSString*) string completion:(void(^)(id response)) completion {
    
    NSString *text = [NSString stringWithCString:[string UTF8String] encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:text forKey:@"q"];
    [params setObject:@"zh-CHS" forKey:@"from"];
    [params setObject:@"en" forKey:@"to"];
    [params setObject:YouDaoKey forKey:@"appKey"];
    
    NSString *salt = [[NSUUID UUID] UUIDString];
    [params setObject:salt forKey:@"salt"];
    
    
    NSInteger timestamp = [NSDate date].timeIntervalSince1970;
    NSString *input = nil;
    if (text.length > 20) {
        input = [NSString stringWithFormat:@"%@%lu%@",[text substringToIndex:10],(unsigned long)text.length,[text substringFromIndex:text.length-10]];
    }else{
        input = text;
    }
    NSString *signString = [NSString stringWithFormat:@"%@%@%@%ld%@",YouDaoKey,input,salt,(long)timestamp,YouDaoSecret];
    NSString *sign256String = [[signString dataUsingEncoding:NSUTF8StringEncoding] sha256String];
    [params setObject:sign256String forKey:@"sign"];

//    [params setObject:@"mp3" forKey:@"ext"]
//    [params setObject:@"0" forKey:@"voice"];
    
    [params setObject:@"v3" forKey:@"signType"];
    [params setObject:@(timestamp).stringValue forKey:@"curtime"];
    
    
    
    [[[self shared] manager] GET:@"" parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"YouDao translate:%@\n",responseObject);
        NSArray *translationArray = [responseObject valueForKey:@"translation"];
        if(completion) completion(translationArray?:@[@"❌"]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(completion) completion(@[@"❌翻译失败"]);
    }];
    
}
@end
