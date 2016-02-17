//
//  UCach.m
//  test-网络
//

//

#import "UCach.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>

static const NSInteger SDefaultCacheMaxCacheAge = 240;

@interface SAutoPurgeCache : NSCache
@end

@implementation SAutoPurgeCache

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}
@end
@interface UCach ()
{
    NSFileManager *_fileManager;
}
#pragma mark---所有的路径私有化
@property (strong, nonatomic) NSCache *memCache;
@property (strong, nonatomic) NSString *diskCachePath;
@property (strong, nonatomic) NSMutableArray *customPaths;
@property (strong, nonatomic) dispatch_queue_t ioQueue;

@end
@implementation UCach
+ (UCach *)sharedUCache {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}
#pragma mark --单例模式创建default起名的cach目录
- (id)init {
    return [self initWithNamespace:@"defaultk"];
}
- (id)initWithNamespace:(NSString *)ns {
    NSString *path = [self makeDiskCachePath:ns];
    return [self initWithNamespace:ns diskCacheDirectory:path];
}
- (id)initWithNamespace:(NSString *)ns diskCacheDirectory:(NSString *)directory {
    if ((self = [super init])) {
#pragma mark --加入公司的前缀在cach目录下做出一个文件夹
        NSString *fullNamespace = [@"com.tkm.UCache." stringByAppendingString:ns];
        _ioQueue = dispatch_queue_create("com.tkm.UCache", DISPATCH_QUEUE_SERIAL);
        _maxCacheAge = SDefaultCacheMaxCacheAge;
        _memCache = [[SAutoPurgeCache alloc] init];
        dispatch_sync(_ioQueue, ^{
            _fileManager = [NSFileManager new];
        });
        _memCache.name = fullNamespace;
        if (directory != nil) {
            _diskCachePath = [directory stringByAppendingPathComponent:fullNamespace];
        } else {
            NSString *path = [self makeDiskCachePath:ns];
            _diskCachePath = path;
        }
    }
    return self;
}
#pragma mark --存储一个文件到磁盘中,如果是url直接就 absolut string
- (void)storeData:(NSData *)netData forUrl:(NSURL *)url toDisk:(BOOL)toDisk
{
    NSString * key = [url absoluteString];
    if (toDisk) {
        dispatch_async(self.ioQueue, ^{
            NSData *data = netData;
            if (data) {
                if (![_fileManager fileExistsAtPath:_diskCachePath]) {
                    [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
                }
                NSString *cachePathForKey = [self defaultCachePathForKey:key];
                [_fileManager createFileAtPath:cachePathForKey contents:data attributes:nil];
            }
        });
    }
}
- (void)storeDic:(NSDictionary *)dic forKey:(NSString *)key toDisk:(BOOL)toDisk
{
    if (toDisk) {
        dispatch_async(self.ioQueue, ^{
            if (dic) {
                if (![_fileManager fileExistsAtPath:_diskCachePath]) {
                    [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
                }
                NSString *cachePathForKey = [self defaultCachePathForKey:key];
                [dic writeToFile:cachePathForKey atomically:YES];
            }
        });
    }
}
- (void)storeData:(NSData *)netData forKey:(NSString *)key toDisk:(BOOL)toDisk
{
    if (toDisk) {
        dispatch_async(self.ioQueue, ^{
            NSData *data = netData;
            if (data) {
                if (![_fileManager fileExistsAtPath:_diskCachePath]) {
                    [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
                }
                NSString *cachePathForKey = [self defaultCachePathForKey:key];
                [_fileManager createFileAtPath:cachePathForKey contents:data attributes:nil];
            }
        });
    }
}
#pragma mark ---相应方法
- (NSData *)diskDataBySearchingAllPathsForKey:(NSString *)key {
    NSString *defaultPath = [self defaultCachePathForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:defaultPath];
    if (data) {
        return data;
    }
     NSArray *customPaths = [self.customPaths copy];
    for (NSString *path in customPaths) {
        NSString *filePath = [self cachePathForKey:key inPath:path];
        NSData *Data = [NSData dataWithContentsOfFile:filePath];
        if (Data) {
            return Data;
        }
    }
    
    return nil;
}
#pragma mark --根据key找到相应的NSData
- (NSDictionary *)diskDictionaryForKeyWithStr:(NSString *)key
{
    NSData *data = [self diskDataBySearchingAllPathsForKey:key];
    if (data) {
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        return dic;
    }
    else
    {
        return nil;
    }

  
}
- (NSData *)diskDataForKeyWithStr:(NSString *)key {
    NSData *data = [self diskDataBySearchingAllPathsForKey:key];
    if (data) {
        return data;
    }
    else {
        return nil;
    }
}
#pragma mark --根据url得到相应的数据
- (NSData *)diskDataForKeyWithUrl:(NSURL *)url {
    NSString * key = [url absoluteString];
    NSData *data = [self diskDataBySearchingAllPathsForKey:key];
    if (data) {
        return data;
    }
    else {
        return nil;
    }
}

- (NSString *)cachePathForUrl:(NSURL *)url
{
    NSString * key = [url absoluteString];
    return [self cachePathForKey:key inPath:self.diskCachePath];
}
#pragma mark --在方法中对字符串进行了加密操作生成新字符串
- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path {
    NSString *filename = [self cachedFileNameForKey:key];
    return [path stringByAppendingPathComponent:filename];
}
- (NSString *)defaultCachePathForKey:(NSString *)key {
    return [self cachePathForKey:key inPath:self.diskCachePath];
}
- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return filename;
}
- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (self.cacheKeyFilter) {
        return self.cacheKeyFilter(url);
    }
    else {
        return [url absoluteString];
    }
}
-(NSString *)makeDiskCachePath:(NSString*)fullNamespace{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:fullNamespace];
}
#pragma mark ---清空cach目录
- (void)clearDiskOnCompletion:(UcachClearBlock)completion
{
    dispatch_async(self.ioQueue, ^{
        [_fileManager removeItemAtPath:self.diskCachePath error:nil];
        [_fileManager createDirectoryAtPath:self.diskCachePath
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:NULL];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}
#pragma mark --得到缓存的大小
- (NSUInteger)getSize {
    __block NSUInteger size = 0;
    dispatch_sync(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.diskCachePath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}

- (BOOL)isExpirationFor:(NSString *)urlStr
{
    BOOL isExpiration;
    NSString * path = [self defaultCachePathForKey:urlStr];
    if (![_fileManager fileExistsAtPath:path])
    {
        [_fileManager createFileAtPath:path contents:nil attributes:nil];
        return YES;
    }
    else
    {
            NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
    
            NSURL * fileUrl = [NSURL fileURLWithPath:path];
            NSDictionary *resourceValues = [fileUrl resourceValuesForKeys:resourceKeys error:NULL];
            NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
        if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
            isExpiration = YES;
        }
        else
        {
            isExpiration = NO;
        }
    }

    return isExpiration;
}
- (void)cleanDiskWithCompletionBlock:(UcachCleanBlock)completionBlock
{
    dispatch_async(self.ioQueue, ^{
        NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
        NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
        
        // This enumerator prefetches useful properties for our cache files.
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:resourceKeys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
        NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
        NSUInteger currentCacheSize = 0;
        
        // Enumerate all of the files in the cache directory.  This loop has two purposes:
        //
        //  1. Removing files that are older than the expiration date.
        //  2. Storing file attributes for the size-based cleanup pass.
        NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
        for (NSURL *fileURL in fileEnumerator) {
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
            
            // Skip directories.
            if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            
            // Remove files that are older than the expiration date;

#pragma mark ---过期时间计算
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [urlsToDelete addObject:fileURL];
                continue;
            }
            
            // Store a reference to this file and account for its total size.
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
            [cacheFiles setObject:resourceValues forKey:fileURL];
        }
        
        for (NSURL *fileURL in urlsToDelete) {
            [_fileManager removeItemAtURL:fileURL error:nil];
        }
        
        // If our remaining disk cache exceeds a configured maximum size, perform a second
        // size-based cleanup pass.  We delete the oldest files first.
        if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize) {
            // Target half of our maximum cache size for this cleanup pass.
            const NSUInteger desiredCacheSize = self.maxCacheSize / 2;
            
            // Sort the remaining cache files by their last modification time (oldest first).
            NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                            usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                            }];
            
            // Delete files until we fall below our desired cache size.
            for (NSURL *fileURL in sortedFiles) {
                if ([_fileManager removeItemAtURL:fileURL error:nil]) {
                    NSDictionary *resourceValues = cacheFiles[fileURL];
                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                    
                    if (currentCacheSize < desiredCacheSize) {
                        break;
                    }
                }
            }
        }
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    });
}
#pragma mark--获得磁盘所有文件数量
- (NSUInteger)getDiskCount {
    __block NSUInteger count = 0;
    dispatch_sync(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.diskCachePath];
        count = [[fileEnumerator allObjects] count];
    });
    return count;
}
@end
