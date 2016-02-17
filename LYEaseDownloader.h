//
//  LYEaseDownloader.h
//  UHttpCach
//
//  Created by 刘仰清 on 16/2/17.
//  Copyright © 2016年 刘仰清. All rights reserved.
//
#define NO_LOG
#if defined(DEBUG) && !defined(NO_LOG)
#define TCLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define TCLog(format, ...)
#endif
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,LYEaseDownloadState)
{
    LYEaseDownloadStateReady = 0,
    LYEaseDownloadStateDownloading,
    LYEaseDownloadStateDone,
    LYEaseDownloadStateCancelled,
    LYEaseDownloadStateFailed
};
typedef NS_ENUM(NSUInteger, LYEaseDownloaderError) {
    LYEaseDownloadErrorInvalidURL = 0,
    LYEaseDownloadErrorHTTPError,
    LYEaseDownloadErrorNotEnoughFreeDiskSpace
};
@protocol LYEaseDownloaderDelegate;
@interface LYEaseDownloader : NSOperation <NSURLConnectionDelegate>
@property (nonatomic, unsafe_unretained) id<LYEaseDownloaderDelegate> delegate;
@property (nonatomic, copy, readonly) NSString *pathToDownloadDirectory;
@property (nonatomic, copy, readonly, getter = pathToFile) NSString *pathToFile;

@property (nonatomic, copy, readonly) NSURL *downloadURL;
@property (nonatomic, strong, readonly) NSMutableURLRequest *fileRequest;
@property (nonatomic, copy, getter = fileName) NSString *fileName;
@property (nonatomic, assign, readonly) NSInteger speedRate;
@property (nonatomic, assign, readonly, getter = remainingTime) NSInteger remainingTime;
@property (nonatomic, assign, readonly, getter = progress) float progress;
@property (nonatomic, assign, readonly) LYEaseDownloadState state;

- (instancetype)initWithURL:(NSURL *)url
               downloadPath:(NSString *)pathToDL
                   delegate:(id<LYEaseDownloaderDelegate>)delegateOrNil;
- (instancetype)initWithURL:(NSURL *)url
               downloadPath:(NSString *)pathToDL
              firstResponse:(void (^)(NSURLResponse *response))firstResponseBlock
                   progress:(void (^)(uint64_t receivedLength, uint64_t totalLength, NSInteger remainingTime, float progress))progressBlock
                      error:(void (^)(NSError *error))errorBlock
                   complete:(void (^)(BOOL downloadFinished, NSString *pathToFile))completeBlock;

- (void)cancelDownloadAndRemoveFile:(BOOL)remove;

- (void)addDependentDownload:(LYEaseDownloader *)download;
@end

@protocol LYEaseDownloaderDelegate <NSObject>
@optional
- (void)download:(LYEaseDownloader *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response;

- (void)download:(LYEaseDownloader *)blobDownload
                    didReceiveData:(uint64_t)receivedLength
                            onTotal:(uint64_t)totalLength
                                    progress:(float)progress;

- (void)download:(LYEaseDownloader *)blobDownload
                                        didStopWithError:(NSError *)error;
- (void)download:(LYEaseDownloader *)blobDownload
                                        didFinishWithSuccess:(BOOL)downloadFinished
                                        atPath:(NSString *)pathToFile;
@end
