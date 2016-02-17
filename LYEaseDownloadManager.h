//
//  LYEaseDownloadManager.h
//  UHttpCach
//
//  Created by 刘仰清 on 16/2/17.
//  Copyright © 2016年 刘仰清. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LYEaseDownloader;
@protocol LYEaseDownloaderDelegate;
@interface LYEaseDownloadManager : NSObject
@property (nonatomic, copy) NSString *defaultDownloadPath;


@property (nonatomic, assign) NSUInteger downloadCount;

@property (nonatomic, assign) NSUInteger currentDownloadsCount;

+ (instancetype)sharedInstance;


- (LYEaseDownloader *)startDownloadWithURL:(NSURL *)url
                                customPath:(NSString *)customPathOrNil
                                  delegate:(id<LYEaseDownloaderDelegate>)delegateOrNil;

- (LYEaseDownloader *)startDownloadWithURL:(NSURL *)url
                                customPath:(NSString *)customPathOrNil
                             firstResponse:(void (^)(NSURLResponse *response))firstResponseBlock
                                  progress:(void (^)(uint64_t receivedLength, uint64_t totalLength, NSInteger remainingTime, float progress))progressBlock
                                     error:(void (^)(NSError *error))errorBlock
                                  complete:(void (^)(BOOL downloadFinished, NSString *pathToFile))completeBlock;


- (void)startDownload:(LYEaseDownloader *)download;


- (void)setOperationQueueName:(NSString *)name;


- (BOOL)setDefaultDownloadPath:(NSString *)pathToDL error:(NSError *__autoreleasing *)error;

- (void)setMaxConcurrentDownloads:(NSInteger)max;

- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove;
@end
