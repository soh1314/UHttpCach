//
//  ViewController.m
//  UHttpCach
//
//  Created by 刘仰清 on 16/2/17.
//  Copyright © 2016年 刘仰清. All rights reserved.
//

#import "ViewController.h"
#import "UHttper.h"
#define weatherUrl @"http://app.zhfzm.com/zouyizou_app/actionDispatcher.do?reqUrl=weather&reqMethod=queryWeather&areaId=3201&cityId=3201"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
