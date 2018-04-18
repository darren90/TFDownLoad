//
//  TFDownloadManager.m
//  FBSnapshotTestCase
//
//  Created by Fengtf on 2018/3/22.
//

#import "TFDownloadManager.h"
#import "TFDownloadTools.h"

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

- (void)startAllDownloadTasks {
    //TODO---
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
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:downloadModel.downloadUrl]];

    // 不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%lld-", [self fileSizeWithDownloadModel:downloadModel]];
    [request setValue:range forHTTPHeaderField:@"Range"];
        
    // 创建一个Data任务
    downloadModel.task = [self.session downloadTaskWithRequest:request];
    downloadModel.task.taskDescription = downloadModel.downloadUrl;
    downloadModel.downloadDate = [NSDate date];
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
            if (![self.downloadingModels containsObject:downloadModel]) {
                [self.downloadingModels addObject:downloadModel];
            }
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
        
//        TFDownloadModel *model =  [self.downloadingModels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"downloadUrl==%@", downloadModel.downloadUrl]].firstObject;
//        if (model) {
//            [self.downloadingModels addObject:model];
//            return YES;
//        } else {
//            return NO;
//        }
    }
}


// 暂停下载
- (void)suspendload:(TFDownloadModel *)downloadModel {
    [self downloadModel:downloadModel progress:nil state:TFDownloadStateSuspended error:nil];
    
    //suspend  无错误返回
    [(NSURLSessionDownloadTask *)downloadModel.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
//        [self saveTempFile:downloadModel.tempPath resumeData:resumeData];
    }];
    [self.downloadingModels removeAllObjects];
    
    [self willAutoResumeNextDowload];
}

// 暂停所有的下载
-(void)suspendAllTasks {
    if (!self.downloadAllModels) return;
    if (!self.downloadingModels || self.downloadingModels.count == 0) return;
    
    [self.downloadingModels removeAllObjects];
    
    for (TFDownloadModel *downloadModel in self.downloadAllModels) {
        [downloadModel.task suspend];
//      [DatabaseTool updateDownTotalSize:downloadModel];
        [self downloadModel:downloadModel progress:nil state:TFDownloadStateSuspended error:nil];
    }
}

// 取消下载 是否删除resumeData
- (void)cancleWithDownloadModel:(TFDownloadModel *)downloadModel clearResumeData:(BOOL)clearResumeData {
    if (!downloadModel || !downloadModel.task) {
        return;
    }
    
    @synchronized(self){
        [self.downloadingModels removeObject:downloadModel];
//        self.waitingModels
    }

    [downloadModel.task suspend];
    
    if (clearResumeData) {
//        清楚本地文件
    }
}

// 删除下载
- (void)deleteDownload:(TFDownloadModel *)downloadModel {
    if (!downloadModel || !downloadModel.task) {
        return;
    }
    
    downloadModel.task.taskDescription = nil;
    [downloadModel.task cancel];
    downloadModel.task = nil;
    
    if ([self.downloadingModels containsObject:downloadModel]) {
        [self.downloadingModels removeObject:downloadModel];
    }
    //开始未下载的
    if (self.waitingModels.count > 0) {
        TFDownloadModel *model =  [self.waitingModels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state==%d", TFDownloadStateReadying]].firstObject;
        [self resumeDownload:model];
    }
//    [self willResumeNextDowload:downloadModel];

//    [DatabaseTool delFileModelWithUniquenName:downloadModel.uniquenName];
}

// 批量删除
- (void)deleteDownloads:(NSArray *)array {
    if (!array.count) return;
    
    for (TFDownloadModel *model in array) {
        [self deleteDownload:model];
    }
    
    //开始未下载的
    if (self.waitingModels.count > 0) {
        TFDownloadModel *model =  [self.waitingModels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state==%d", TFDownloadStateReadying]].firstObject;
        [self resumeDownload:model];
    }
}

// 删除所有的下载
-(void)deleteAllTasks {
    [self deleteDownloads:self.downloadAllModels];
}

//开启下载引擎
-(void)startEngine {
    
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



#pragma mark - private

- (void)downloadModel:(TFDownloadModel *)downloadModel progress:(TFDownloadProgress *)progress state:(TFDownloadState)state error:(NSError *)error {
    downloadModel.state = state;
    progress = progress == nil ? downloadModel.progress : progress;
    dispatch_async(dispatch_get_main_queue(), ^(){
        if(self.delegate && [self.delegate respondsToSelector:@selector(downloadModel:didUpdateProgress:error:)]){
            [self.delegate downloadModel:downloadModel didUpdateProgress:progress error:error];
        }
        
        if (downloadModel.updateBlock) {
            downloadModel.updateBlock(progress, state, error);
        }
    });
}


#pragma mark - NSURLSessionDownloadDelegate

//  1 - 监听文件下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"didWriteData - %@",downloadTask);
    TFDownloadModel *downloadModel = [self downLoadingModelForURLString:downloadTask.taskDescription];
    if(!downloadModel) {
        return;
    }
    
    float progress = (double)totalBytesWritten/totalBytesExpectedToWrite;
    
    int64_t resumeBytesWritten = downloadModel.progress.resumeBytesWritten;
    
    NSTimeInterval downloadTime = -1 * [downloadModel.downloadDate timeIntervalSinceNow];
    float speed = (totalBytesWritten - resumeBytesWritten) / downloadTime / 1024.0 / 1024.0;
    
    int64_t remainingContentLength = totalBytesExpectedToWrite - totalBytesWritten;
    int remainingTime = ceilf(remainingContentLength / speed);
    
    downloadModel.progress.bytesWritten = bytesWritten;
    downloadModel.progress.totalBytesWritten = totalBytesWritten;
    downloadModel.progress.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
    downloadModel.progress.progress = progress;
    downloadModel.progress.speed = speed;
    downloadModel.progress.remainingTime = remainingTime;
 
    [self downloadModel:downloadModel progress:downloadModel.progress state:TFDownloadStateRunning error:nil];
}
// 恢复下载
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"didResumeAtOffset - %@",downloadTask);
//    downloadTask.user   
 
}
// 5 - 下载成功
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"didFinishDownloadingToURL - %@",location.absoluteString);
    TFDownloadModel *downloadModel = [self downLoadingModelForURLString:downloadTask.taskDescription];
    [self moveFileAtURL:location toPath:downloadModel.filePath];
}
// 6 - 下载完成 调用cancle的时候也走这个方法
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
    NSLog(@"didCompleteWithError : %@" ,task);
    NSLog(@"resumeData : %@" ,@(resumeData.length));
    
    TFDownloadModel *downloadModel = [self downLoadingModelForURLString:task.taskDescription];
    if (!downloadModel) {   return;  }
    
    if (resumeData) {
        [self saveTempFile:downloadModel.tempPath resumeData:resumeData];
    }
    
    [self.downloadingModels removeObject:downloadModel];
    
    // 关闭流
    downloadModel.task = nil;
    
    if (error) {
        [self downloadModel:downloadModel progress:nil state:TFDownloadStateSuspended error:error];
    } else {
        [self downloadcomplate:downloadModel];
    }
    //开启下一个
    [self willAutoResumeNextDowload];
}

- (void)willAutoResumeNextDowload {
    @synchronized (self) {
        // 还有未下载的
        if (self.waitingModels.count > 0) {
            TFDownloadModel *model =  [self.waitingModels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state==%d", TFDownloadStateReadying]].firstObject;
            [self resumeDownload:model];
        }
    }
}

#pragma mark -- 下载完成
//下载完成后的一些处理方法
-(void)downloadcomplate:(TFDownloadModel *)downloadModel {
    [self downloadModel:downloadModel progress:nil state:TFDownloadStateCompleted error:nil];
    [self.downloadAllModels removeObject:downloadModel];//下载完毕后，移除总数组，
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDidCompleted:)]) {
        [self.delegate downloadDidCompleted:downloadModel];
    }

    // 下载完成
//    [DatabaseTool updateDownModeWhenDownFinish:downloadModel];
}

#pragma mark - Tools

- (void)moveFileAtURL:(NSURL *)srcURL toPath:(NSString *)dstPath {
    if (!dstPath) {
        NSLog(@"error filePath is nil!");
        return;
    }
    NSError *error = nil;
    if ([self.fileManager fileExistsAtPath:dstPath] ) {
        [self.fileManager removeItemAtPath:dstPath error:&error];
        if (error) {
            NSLog(@"removeItem error %@",error);
        }
    }
    
    NSURL *dstURL = [NSURL fileURLWithPath:dstPath];
    [self.fileManager moveItemAtURL:srcURL toURL:dstURL error:&error];
    if (error){
        NSLog(@"moveItem error:%@",error);
    }
}

- (void)saveTempFile:(NSString *)tempPath resumeData:(NSData *)resumeData{
    if (tempPath.length == 0 || !resumeData) {
        NSLog(@"error filePath is nil!");
        return;
    }
    NSError *error = nil;
    if ([self.fileManager fileExistsAtPath:tempPath] ) {
        [self.fileManager removeItemAtPath:tempPath error:&error];
        if (error) {
            NSLog(@"removeItem error %@",error);
        }
    }
    [self.fileManager createFileAtPath:tempPath contents:resumeData attributes:nil];
}

// 获取文件大小 -- 获取已缓存的文件大小，如果已经存在已缓存的文件，就追加，没有就从头开始下载
- (long long)fileSizeWithDownloadModel:(TFDownloadModel *)downloadModel{
    NSString *filePath = downloadModel.tempPath;
    if (![self.fileManager fileExistsAtPath:filePath]) return 0;
    return [[self.fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
}

// 获取下载模型
- (TFDownloadModel *)downLoadingModelForURLString:(NSString *)URLString {
    TFDownloadModel *model = [self.downloadingModelDic objectForKey:URLString];
    model =  [self.downloadingModels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"downloadUrl==%@", URLString]].firstObject;
    return model;
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


- (NSFileManager *)fileManager {
    if (!_fileManager) {
        _fileManager = [[NSFileManager alloc]init];
    }
    return _fileManager;
}

- (NSMutableArray<TFDownloadModel *> *)downloadAllModels {
    if (!_downloadAllModels) {
        _downloadAllModels = [NSMutableArray array];
    }
    return _downloadAllModels;
}

- (NSMutableDictionary *)downloadingModelDic {
    if (!_downloadingModelDic) {
        _downloadingModelDic = [NSMutableDictionary dictionary];
    }
    return _downloadingModelDic;
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
