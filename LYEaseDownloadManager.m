//
//  LYEaseDownloadManager.m
//  UHttpCach
//
//  Created by 刘仰清 on 16/2/17.
//  Copyright © 2016年 刘仰清. All rights reserved.
//

#import "LYEaseDownloadManager.h"
#import "LYEaseDownloader.h"
@interface LYEaseDownloadManager ()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation LYEaseDownloadManager
@dynamic downloadCount;
@dynamic currentDownloadsCount;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.defaultDownloadPath = [NSString stringWithString:NSTemporaryDirectory()];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static id sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[[self class] alloc] init];
        [sharedManager setOperationQueueName:@"LYEaseDownloadManager_SharedInstance_Queue"];
    });
    return sharedManager;
}


#pragma mark - TCBlobDownloader Management


- (LYEaseDownloader *)startDownloadWithURL:(NSURL *)url
                                customPath:(NSString *)customPathOrNil
                                  delegate:(id<LYEaseDownloaderDelegate>)delegateOrNil
{
    NSString *downloadPath = customPathOrNil ? customPathOrNil : self.defaultDownloadPath;
    
    LYEaseDownloader *downloader = [[LYEaseDownloader alloc] initWithURL:url
                                                            downloadPath:downloadPath
                                                                delegate:delegateOrNil];
    [self.operationQueue addOperation:downloader];
    
    return downloader;
}

- (LYEaseDownloader *)startDownloadWithURL:(NSURL *)url
                                customPath:(NSString *)customPathOrNil
                             firstResponse:(void (^)(NSURLResponse *response))firstResponseBlock
                                  progress:(void (^)(uint64_t receivedLength, uint64_t totalLength, NSInteger remainingTime, float progress))progressBlock
                                     error:(void (^)(NSError *error))errorBlock
                                  complete:(void (^)(BOOL downloadFinished, NSString *pathToFile))completeBlock
{
    NSString *downloadPath = customPathOrNil ? customPathOrNil : self.defaultDownloadPath;
    
    LYEaseDownloader *downloader = [[LYEaseDownloader alloc] initWithURL:url
                                                            downloadPath:downloadPath
                                                           firstResponse:firstResponseBlock
                                                                progress:progressBlock
                                                                   error:errorBlock
                                                                complete:completeBlock];
    [self.operationQueue addOperation:downloader];
    
    return downloader;
}

- (void)startDownload:(LYEaseDownloader *)download
{
    [self.operationQueue addOperation:download];
}

- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove
{
    for (LYEaseDownloader *blob in [self.operationQueue operations]) {
        [blob cancelDownloadAndRemoveFile:remove];
    }
}


#pragma mark - Custom Setters


- (void)setOperationQueueName:(NSString *)name
{
    [self.operationQueue setName:name];
}

- (BOOL)setDefaultDownloadPath:(NSString *)pathToDL error:(NSError *__autoreleasing *)error
{
    if ([[NSFileManager defaultManager] createDirectoryAtPath:pathToDL
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:error]) {
        _defaultDownloadPath = pathToDL;
        return YES;
    } else {
        return NO;
    }
}

- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrent
{
    [self.operationQueue setMaxConcurrentOperationCount:maxConcurrent];
}


#pragma mark - Custom Getters


- (NSUInteger)downloadCount
{
    return [self.operationQueue operationCount];
}

- (NSUInteger)currentDownloadsCount
{
    NSUInteger count = 0;
    for (LYEaseDownloader *blob in [self.operationQueue operations]) {
        if (blob.state == LYEaseDownloadStateDownloading) {
            count++;
        }
    }
    
    return count;
}

@end
