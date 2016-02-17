//
//  UCach.h
//  test-网络
//
//  Copyright © 2016年 cuihuaxiaowo. All rights reserved.
//  Code based AFNetworking And SdWebImage;
//

#import <Foundation/Foundation.h>

typedef NSString *(^UCachFilterBlock)(NSURL *url);
typedef void(^UcachClearBlock)(void);
typedef void(^UcachCleanBlock)(void);
@interface UCach : NSObject
@property (nonatomic, copy) UCachFilterBlock cacheKeyFilter;
@property (assign, nonatomic) NSInteger maxCacheAge;
@property (assign, nonatomic) NSUInteger maxCacheSize;

+ (UCach *)sharedUCache;
#pragma mark ---生成磁盘缓存路径
-(NSString *)makeDiskCachePath:(NSString*)fullNamespace;
#pragma mark --根据url找到url文件保存路径
- (NSString *)cachePathForUrl:(NSURL *)url;

#pragma mark --根据url储存路径中的磁盘数据
- (void)storeData:(NSData *)netData forUrl:(NSURL *)url toDisk:(BOOL)toDisk;
- (void)storeDic:(NSDictionary *)dic forKey:(NSString *)key toDisk:(BOOL)toDisk;
- (void)storeData:(NSData *)netData forKey:(NSString *)key toDisk:(BOOL)toDisk;
#pragma mark --根据url得到路径中的磁盘缓存数据
- (NSData *)diskDataForKeyWithStr:(NSString *)key;
- (NSData *)diskDataForKeyWithUrl:(NSURL *)url;
- (NSDictionary *)diskDictionaryForKeyWithStr:(NSString *)key;

#pragma mark --判断缓存文件是否过期
- (BOOL)isExpirationFor:(NSString *)urlStr;
#pragma mark --清除路径中的缓存
- (void)clearDiskOnCompletion:(UcachClearBlock)completion;
#pragma mark --清理缓存
- (void)cleanDiskWithCompletionBlock:(UcachCleanBlock)completionBlock;
#pragma mark ---得到默认的缓存路径
- (NSString *)defaultCachePathForKey:(NSString *)key;
- (NSUInteger)getDiskCount;

@end
