//
//  TFDownloadModel.h
//  Pods
//
//  Created by Fengtf on 2018/3/22.
//

#import <Foundation/Foundation.h>

// 下载状态
typedef NS_ENUM(NSUInteger, TFDownloadState) {
    TFRDownloadStateNone = 1,        // 未下载
    TFDownloadStateReadying,    // 等待下载
    TFDownloadStateRunning,     // 正在下载
    TFDownloadStateSuspended,   // 下载暂停
    TFDownloadStateCompleted,   // 下载完成
    TFDownloadStateFailed       // 下载失败
};

typedef NS_ENUM(NSUInteger, UrlType) {
    UrlHttp = 1,     // http下载链接
    UrlM3u8 = 2,     // m3u8下载链接
    UrlList = 3,     // m3u8下载链接
};

@class TFDownloadProgress;
// 进度更新block
//typedef void (^RRDownloadProgressBlock)(TTDownloadProgress *progress);
//// 状态更新block
//typedef void (^RRDownloadStateBlock)(RRDownloadState state,NSString *filePath, NSError *error);
typedef void (^TFDownloadUpdateBlock)(TFDownloadProgress *progress,TFDownloadState state, NSError *error);


@interface TFDownloadModel : NSObject

@property (nonatomic, copy) NSString *uniqueName;//唯一, movieId+episode
@property (nonatomic, copy) NSString *uniquenId;//剧集id
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic,assign)int episode;//第几集
@property (nonatomic, copy) NSString * title;
@property (nonatomic,copy) NSString * iconUrl;//剧照

@property (nonatomic,copy) NSString * webPlayUrl;/** WebPlayUrl地址 */
@property (nonatomic,copy) NSString * quality;/**  *  视频质量,eg：height ;  */
@property (nonatomic,assign)BOOL isHadDown;//是否已经下载完毕 - 下载完毕要更新为YES
@property (nonatomic,copy)NSString * fileSize;//总大小
@property (nonatomic,copy)NSString * fileReceivedSize;//已经接收到数据的大小
@property (nonatomic,assign)NSUInteger total_filesize;

@property (nonatomic,strong)NSArray * urlArray;
@property(nonatomic,copy)NSString *tempPath;    //临时下载地址
// 下载路径 如果设置了downloadDirectory，文件下载完成后会移动到这个目录，否则，在manager默认cache目录里
@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, assign) TFDownloadState state;

//下载更新block = 进度+状态
@property (nonatomic, copy) TFDownloadUpdateBlock updateBlock;


// 下载任务
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong ,readonly) TFDownloadProgress *progress;

// 下载时间
@property (nonatomic, strong) NSDate *downloadDate;

@property (nonatomic, assign) UrlType urlType;

@end




/**
 *  下载进度
 */
@interface TFDownloadProgress : NSObject

// 续传大小
@property (nonatomic, assign) int64_t resumeBytesWritten;
// 这次写入的数量
@property (nonatomic, assign) int64_t bytesWritten;
// 已下载的数量
@property (nonatomic, assign) int64_t totalBytesWritten;
// 文件的总大小
@property (nonatomic, assign) int64_t totalBytesExpectedToWrite;
// 下载进度
@property (nonatomic, assign) float progress;
// 下载速度  M/s
@property (nonatomic, assign) float speed;
// 下载剩余时间
@property (nonatomic, assign) int remainingTime;


@end



