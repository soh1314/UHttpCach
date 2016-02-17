//
//  UHttper.h
//  test-网络
//

//

#import <Foundation/Foundation.h>

#import "UCach.h"
typedef NS_ENUM(NSInteger,HttperOption)
{
    UHttperPost = 0,
    UHttperGet,
    UHttperCachPost,
    UHttperCachGet,
    UHttperSession
};
typedef void(^Success)(id response);
typedef void(^Failure)(id restrict);
@interface UHttper : NSObject

#pragma mark --网络是否正常连接
+ (instancetype)manager;
- (void)HttperGet:(NSString *)urlString HttperOption:(HttperOption)option Success:(void(^)(AFHTTPRequestOperation * operation,id response))success Failure:(void(^)(AFHTTPRequestOperation * operation, NSError * error))failure;
- (void)HttperPost:(NSString *)urlString HttperOption:(HttperOption)option Success:(void(^)(AFHTTPRequestOperation * operation,id response))success Failure:(void(^)(AFHTTPRequestOperation * operation, NSError * error))failure;
- (void)HttperGet:(NSString *)urlString Success:(void(^)(AFHTTPRequestOperation * operation,id response))success Failure:(void(^)(AFHTTPRequestOperation * operation, NSError * error))failure;
- (void)HttperPost:(NSString *)urlString Success:(void(^)(AFHTTPRequestOperation * operation,id response))success Failure:(void(^)(AFHTTPRequestOperation * operation, NSError * error))failure;

@end
