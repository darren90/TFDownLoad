//
//  TFViewController.m
//  TFDownLoad
//
//  Created by 1005052145@qq.com on 03/18/2018.
//  Copyright (c) 2018 1005052145@qq.com. All rights reserved.
//

#import "TFViewController.h"
#import "TFDownloadManager.h"
#import "TFDownloadModel.h"

@interface TFViewController ()

@end

@implementation TFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	 
}

- (IBAction)downloadAction:(id)sender {
    NSString *url = @"http://vt1.doubanio.com/201803230748/18f5a85faaadddb6440e34ef8aaaec84/view/movie/M/302240680.mp4";
    url = @"http://101.44.1.113/hotfiles/2214000006FF7C5C/101.44.1.10/files/5214000006FF7C5C/down.sandai.net/thunder9/Thunder9.1.47.1020.exe";
    TFDownloadModel *model = [TFDownloadModel new];
    model.downloadUrl = url;
    model.title = @"302240680";
    [[TFDownloadManager manager] startDownload:model];
}

- (IBAction)pauseAction:(id)sender {
    
}

- (IBAction)continueAction:(id)sender {
    
}



@end
