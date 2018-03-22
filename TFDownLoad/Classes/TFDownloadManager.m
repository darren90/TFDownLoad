//
//  TFDownloadManager.m
//  FBSnapshotTestCase
//
//  Created by Fengtf on 2018/3/22.
//

#import "TFDownloadManager.h"

@interface TFDownloadManager ()
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
@property (nonatomic, strong) NSMutableArray *waitingDownloadModels;
// 下载中的模型
@property (nonatomic, strong) NSMutableArray *downloadingModels;
// 下载中 + 等待中的模型 只读
@property (nonatomic, strong) NSMutableArray *downloadAllModels;
// 回调代理的队列
@property (strong, nonatomic) NSOperationQueue *queue;

// 最大下载数
@property (nonatomic, assign) NSInteger maxDownloadCount;

// 全部并发 默认NO, 当YES时，忽略maxDownloadCount
@property (nonatomic, assign) BOOL isBatchDownload;

/* 用于计数 -- 不让进度调用的方法过于频繁 */
@property (nonatomic,assign)NSInteger timesCount;

@end


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




- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc]init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return _queue;
}

@end
