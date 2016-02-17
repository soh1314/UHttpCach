//
//  UHttper.m
//  test-网络
//


#import "UHttper.h"
@interface UHttper()
{
    AFHTTPRequestOperationManager * _manager;
}
@end
@implementation UHttper

+ (instancetype)manager
{
    return [[self alloc]initWithBaseURL:nil];
}
- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super init];
    if (!self) {
        return nil;
    }
    if ([[url path] length] > 0 && ![[url absoluteString] hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }
    return self;
}
- (void)HttperGet:(NSString *)urlString HttperOption:(HttperOption)option Success:(void(^)(AFHTTPRequestOperation * operation,id response))success Failure:(void(^)(AFHTTPRequestOperation * operation, NSError * error))failure
{
    if (option == 3) {
        NSData * data = [[UCach sharedUCache]diskDataForKeyWithStr:urlString];
       if( (data == nil||data.length < 1) || [[UCach sharedUCache]isExpirationFor:urlString] )
       {
        
           [self HttperGet:urlString Success:^(AFHTTPRequestOperation *operation, id response) {
               success(operation,response);
               [[UCach sharedUCache]storeData:response forKey:urlString toDisk:YES];
           } Failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               failure(operation,error);
           }];
     
       }
        else
        {
            NSData * data = [[UCach sharedUCache]diskDataForKeyWithStr:urlString];
            NSLog(@"cache");
            success(nil,data);
            
        }
    }
}
- (void)HttperPost:(NSString *)urlString HttperOption:(HttperOption)option Success:(void(^)(AFHTTPRequestOperation * operation,id response))success Failure:(void(^)(AFHTTPRequestOperation * operation, NSError * error))failure
{
    if (option == 3) {
        NSData * data = [[UCach sharedUCache]diskDataForKeyWithStr:urlString];
        if( (data == nil||data.length < 1) || [[UCach sharedUCache]isExpirationFor:urlString] )
        {
            
            [self HttperPost:urlString Success:^(AFHTTPRequestOperation *operation, id response) {
                success(operation,response);
                [[UCach sharedUCache]storeData:response forKey:urlString toDisk:YES];
            } Failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                failure(operation,error);
            }];
            
        }
        else
        {
            NSData * data = [[UCach sharedUCache]diskDataForKeyWithStr:urlString];
            NSLog(@"cache");
            success(nil,data);
            
        }
    }

}


- (void)HttperGet:(NSString *)urlString Success:(void(^)(AFHTTPRequestOperation * operation,id response))success Failure:(void(^)(AFHTTPRequestOperation * operation, NSError * error))failure
{
    _manager = [AFHTTPRequestOperationManager manager];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [_manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
#pragma mark --执行成功block
        success(operation,responseObject);
        NSLog(@"成功");
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        failure(operation,error);
    }];
}
- (void)HttperPost:(NSString *)urlString Success:(void(^)(AFHTTPRequestOperation * operation,id response))success Failure:(void(^)(AFHTTPRequestOperation * operation, NSError * error))failure;
{
    _manager = [AFHTTPRequestOperationManager manager];
    [_manager POST:urlString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        success(operation,responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
       failure(operation,error);
    }];
}

@end
