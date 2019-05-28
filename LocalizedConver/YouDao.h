//
//  YouDao.h
//  LocalizedConver
//
//  Created by Mega on 2019/5/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YouDao : NSObject
+(void)translate:(NSString*) string completion:(void(^)(id response)) completion;
@end

NS_ASSUME_NONNULL_END
