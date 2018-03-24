//
//  TFDownloadManager.m
//  FBSnapshotTestCase
//
//  Created by Fengtf on 2018/3/22.
//

#import "TFDownloadManager.h"

@interface TFDownloadManager () <NSURLSessionDownloadDelegate>
// 文件管理
@property (nonatomic, strong) NSFileManager *fileManager;
// 缓存文件目录
//@property (nonatomic, strong) NSString *downloadDirectory;

// >>>>>>>>>>>>>>>>>>>>>>>>>>  session info
// 下载seesion会话
@property (nonatomic, strong) NSURLSession *session;
// 下载模型字典 key = url
@property (nonatomic, strong) NSMutableDictionary *downloadingModelDic;
// 等待中的模型
@property (nonatomic, strong) NSMutableArray<TFDownloadModel *> *waitingModels;
// 下载中的模型
@property (nonatomic, strong) NSMutableArray<TFDownloadModel *> *downloadingModels;
// 下载中 + 等待中的模型
@property (nonatomic, strong) NSMutableArray<TFDownloadModel *> *downloadAllModels;
// 回调代理的队列
@property (strong, nonatomic) NSOperationQueue *queue;

// 最大下载数
@property (nonatomic, assign) NSInteger maxDownloadCount;

// 全部并发 默认NO, 当YES时，忽略maxDownloadCount
@property (nonatomic, assign) BOOL isBatchDownload;

/* 用于计数 -- 不让进度调用的方法过于频繁 */
@property (nonatomic,assign)NSInteger timesCount;


/** 保存上次的下载信息 */
@property (nonatomic, strong) NSData *resumeData;

@end

#define IS_IOS8ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
#define IS_IOS10ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)

@implementation TFDownloadManager

+ (TFDownloadManager *)manager {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if(self = [super init]) {
        _maxDownloadCount = 1;

    }
    return self;
}


- (void)startDownload:(TFDownloadModel *)downloadModel {
    if(downloadModel.downloadUrl.length == 0){
        NSLog(@"下载地址不可以为空");
        return;
    }
    
    //查看是否已经下载完毕
    
    //验证是否已经在下载
    if(downloadModel.task && downloadModel.task.state == NSURLSessionTaskStateRunning) {
        [self downloadModel:downloadModel progress:nil state:TFDownloadStateRunning error:nil];
        return;
    }
    
    //添加数据库
    //TODO -
    [self resumeDownload:downloadModel];
}

- (void)resumeDownload:(TFDownloadModel *)downloadModel {
    if (downloadModel.downloadUrl.length == 0) return;
    if (![self canResumeDownload:downloadModel]) return;
    
    
    NSString *tempPath = @"";
    NSString *filePath = @"";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:downloadModel.downloadUrl]];

    // 不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", [self fileSizeWithDownloadModel:downloadModel]];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    // 创建流
//    downloadModel.stream = [NSOutputStream outputStreamToFileAtPath:downloadModel.tempPath append:YES];
    
    // 创建一个Data任务
    downloadModel.task = [self.session downloadTaskWithRequest:request];
    downloadModel.task.taskDescription = downloadModel.downloadUrl;
    [downloadModel.task resume];
    [self downloadModel:downloadModel progress:nil state:TFDownloadStateRunning error:nil];
}

- (BOOL)canResumeDownload:(TFDownloadModel *)downloadModel {
    @synchronized (self) {
        if (self.downloadingModels.count >= _maxDownloadCount ) {
            if ([self.waitingModels indexOfObject:downloadModel] == NSNotFound) {
                [self.waitingModels addObject:downloadModel];
                if ([self.downloadAllModels indexOfObject:downloadModel] == NSNotFound) {
                    [self.downloadAllModels addObject:downloadModel];
                }
            }
            [self downloadModel:downloadModel progress:nil state:TFDownloadStateReadying error:nil];
            return NO;
        }
        if ([self.waitingModels indexOfObject:downloadModel] != NSNotFound) {
            [self.waitingModels removeObject:downloadModel];
        }
        
        if ([self.downloadingModels indexOfObject:downloadModel] == NSNotFound) {
            [self.downloadingModels addObject:downloadModel];
        }
        
        if ([self.downloadAllModels indexOfObject:downloadModel] == NSNotFound) {
            [self.downloadAllModels addObject:downloadModel];
        }
        return YES;
    }
}



// 自动下载下一个等待队列任务
- (void)willResumeNextDowload:(TFDownloadModel *)downloadModel {
    @synchronized (self) {
        [self.downloadingModels removeObject:downloadModel];
        // 还有未下载的
        if (self.waitingModels.count > 0) {
            TFDownloadModel *model =  [self.waitingModels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state==%d", TFDownloadStateReadying]].firstObject;
            [self resumeDownload:model];
        }
    }
}

// 获取文件大小 -- 获取已缓存的文件大小，如果已经存在已缓存的文件，就追加，没有就从头开始下载
- (long long)fileSizeWithDownloadModel:(TFDownloadModel *)downloadModel{
    NSString *filePath = downloadModel.tempPath;
    if (![self.fileManager fileExistsAtPath:filePath]) return 0;
    return [[self.fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
}


#pragma mark - private

- (void)downloadModel:(TFDownloadModel *)downloadModel progress:(TFDownloadProgress *)progress state:(TFDownloadState)state error:(NSError *)error {
    downloadModel.state = state;
    if(self.delegate && [self.delegate respondsToSelector:@selector(downloadModel:didUpdateProgress:error:)]){
        [self.delegate downloadModel:downloadModel didUpdateProgress:progress error:error];
    }
    
    if (downloadModel.updateBlock) {
        downloadModel.updateBlock(progress, state, error);
    }
}


#pragma mark - NSURLSessionDownloadDelegate

//  1 - 监听文件下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"%@",downloadTask);

}
// 恢复下载
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"%@",downloadTask);
//    downloadTask.user   
 
}
// 5 - 下载成功
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"%@",location.absoluteString);
}
// 6 - 下载完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    self.resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
    NSLog(@"didCompleteWithError : %@",task);
    NSLog(@"resumeData : %@",self.resumeData);

}



#pragma mark - Getter

- (NSMutableArray<TFDownloadModel *> *)downloadingModels {
    if (!_downloadingModels) {
        _downloadingModels = [NSMutableArray array];
    }
    return _downloadingModels;
}

- (NSMutableArray<TFDownloadModel *> *)waitingModels {
    if (!_waitingModels) {
        _waitingModels = [NSMutableArray array];
    }
    return _waitingModels;
}

- (NSMutableArray<TFDownloadModel *> *)downloadAllModels {
    if (!_downloadAllModels) {
        _downloadAllModels = [NSMutableArray array];
    }
    return _downloadAllModels;
}

- (NSURLSession *)session {
    if (!_session) {
        if (IS_IOS8ORLATER) {
            NSURLSessionConfiguration *configure = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"DownloadSessionManager.backgroundConfigure"];
            _session = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:self.queue];
        }else{
            _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfiguration:@"DownloadSessionManager.backgroundConfigure"]delegate:self delegateQueue:self.queue];
        }
    }
    return _session;
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc]init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return _queue;
}

@end
