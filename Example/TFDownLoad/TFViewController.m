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

@interface TFViewController () <TFDownloadDelegate>

@property (nonatomic, strong) TFDownloadModel *downloadModel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UITextView *logView;

@property (nonatomic, strong) NSMutableString *logStr;
;

@end

@implementation TFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	 
    self.logStr = [NSMutableString string];
    self.logView.layoutManager.allowsNonContiguousLayout= NO;
}

- (IBAction)downloadAction:(id)sender {
    NSString *url = @"http://vt1.doubanio.com/201803230748/18f5a85faaadddb6440e34ef8aaaec84/view/movie/M/302240680.mp4";
    url = @"http://101.44.1.113/hotfiles/2214000006FF7C5C/101.44.1.10/files/5214000006FF7C5C/down.sandai.net/thunder9/Thunder9.1.47.1020.exe";
    TFDownloadModel *model = [TFDownloadModel new];
    model.downloadUrl = url;
    model.title = @"302240681";
    self.downloadModel = model;
    [[TFDownloadManager manager] startDownload:model];
    [TFDownloadManager manager].delegate = self;
}

- (IBAction)pauseAction:(id)sender {
    [[TFDownloadManager manager] suspendload:self.downloadModel];
}

- (IBAction)continueAction:(id)sender {
    [[TFDownloadManager manager] startDownload:self.downloadModel];
}



// 更新下载进度
- (void)downloadModel:(TFDownloadModel *)downloadModel didUpdateProgress:(TFDownloadProgress *)progress error:(NSError *)error {
    self.progressView.progress = progress.progress;
    
    self.logStr = [NSMutableString string];
    
    [self.logStr appendString:[NSString stringWithFormat:@"文件的总大小 : %@ \n", @(progress.totalBytesExpectedToWrite)]];
    [self.logStr appendString:[NSString stringWithFormat:@"已下载的数量 : %@ \n", @(progress.totalBytesWritten)]];
    [self.logStr appendString:[NSString stringWithFormat:@"下载进度 : %@ \n", @(progress.progress)]];
    [self.logStr appendString:[NSString stringWithFormat:@"下载速度 : %@ M/s \n", @(progress.speed)]];
    [self.logStr appendString:[NSString stringWithFormat:@"下载剩余时间 : %@ \n", @(progress.remainingTime)]];
    [self.logStr appendString:@"\n"];
    [self.logStr appendString:@"----------------------  \n"];
    [self.logStr appendString:@"\n"];
    
    self.logView.text = self.logStr;
//    [self.logView scrollRectToVisible:self.logView.frame animated:YES];
     self.logView.selectedRange = NSMakeRange( self.logView.text.length - 1, 0);
//    self.logView.layoutManager.allowsNonContiguousLayout = NO;
}

// 下载完毕
- (void)downloadDidCompleted:(TFDownloadModel *)downloadModel {
    
}


@end
