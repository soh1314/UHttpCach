//
//  ViewController.m
//  UHttpCach
//
//  Created by 刘仰清 on 16/2/17.
//  Copyright © 2016年 刘仰清. All rights reserved.
//

#import "ViewController.h"
#import "UHttper.h"
#import "LYEaseDownloader.h"
#import "UIImageView+WebCache.h"
#import "LYEaseDownloadManager.h"
#define weatherUrl @"http://app.zhfzm.com/zouyizou_app/actionDispatcher.do?reqUrl=weather&reqMethod=queryWeather&areaId=3201&cityId=3201"
#define imageUrl @"http://b.hiphotos.baidu.com/image/pic/item/fc1f4134970a304e9ce8639bd6c8a786c8175c8d.jpg"
@interface ViewController ()<LYEaseDownloaderDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadData];
    [self downloadImage];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)loadData
{
    UHttper * httper = [UHttper manager];
    [httper HttperGet:weatherUrl HttperOption:3 Success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"success");
    } Failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
    }];
    
}
- (void)downloadImage
{
    NSString * libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)lastObject];
    NSString * downloadPath = [libPath stringByAppendingPathComponent:@"com.LYEase.com"];
    NSLog(@"%@",downloadPath);
    LYEaseDownloadManager * manager = [LYEaseDownloadManager sharedInstance];
    [manager startDownloadWithURL:[NSURL URLWithString:imageUrl] customPath:downloadPath delegate:self];
    
}

#pragma mark - TCBlobDownloaderDelegate
- (void)download:(LYEaseDownloader *)blobDownload
didFinishWithSuccess:(BOOL)downloadFinished
          atPath:(NSString *)pathToFile
{
    NSLog(@"%@",pathToFile);

        UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        [self.view addSubview:image];
        
    [image sd_setImageWithURL:[NSURL fileURLWithPath:pathToFile]];


    
}
- (void)download:(LYEaseDownloader *)blobDownload
  didReceiveData:(uint64_t)receivedLength
         onTotal:(uint64_t)totalLength
        progress:(float)progress
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
