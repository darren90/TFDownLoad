//
//  FileModel.h
//  MovieDownloadManager
//
//  Created by Fengtf on 15/11/4.
//  Copyright © 2015年 ftf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class DownLoadModel;

typedef enum {//url类型
    FileUrlM3u8 = 1,     // m3u8下载链接
    FileUrlHttp = 2,     // http下载链接
} FileUrlType;

@interface FileModel : NSObject
//@property (nonatomic,assign) float size;
//@property (nonatomic, strong) NSDate * addTime;
///** m3u8 类型的下载地址 + http类型的下载地址 */
//@property (nonatomic,copy)NSString * downUrl;
///** 下载类型 存放DownLoadType */
//@property (nonatomic,assign)int downType;
///** 地址是否是有效的 */
//@property (nonatomic,assign)BOOL isInvalid;
///** 下载状态:正在下载/未下载/下载完毕 */
//@property (nonatomic,assign)int downLoadState;

/** 唯一 */
@property (nonatomic, copy) NSString * uniquenName;//唯一, movieId+episode
@property (nonatomic, copy) NSString * movieId;//剧集id
@property (nonatomic,assign)int episode;//第几集
@property (nonatomic, copy) NSString * title;
@property (nonatomic,copy)NSString * iconUrl;//剧照
@property (nonatomic,assign)BOOL isHadDown;//是否已经下载完毕 - 下载完毕要更新为YES
@property (nonatomic,assign)int urlType;//存储FileUrlType
@property (nonatomic,assign)float progress;//进度

@property(nonatomic,copy)NSString *fileName;//下载文件存储的的名字//XXX.mp4
@property(nonatomic,copy)NSString *fileSize;//总大小
@property(nonatomic,copy)NSString *fileReceivedSize;
@property(nonatomic,assign)BOOL isFirstReceived;//是否是第一次接受数据，如果是则不累加第一次返回的数据长度，之后变累加
@property(nonatomic,copy)NSString *fileURL;
@property(nonatomic,copy)NSString *time;
@property(nonatomic,assign)BOOL isDownloading;//是否正在下载
@property(nonatomic,assign)BOOL willDownloading;
@property(nonatomic,assign)BOOL error;

@property(nonatomic,copy)NSString *targetPath;
@property(nonatomic,copy)NSString *tempPath;

//@property (nonatomic,strong)DownLoadModel * downloadModel;
//@property(nonatomic,copy)NSString *fileType; // 0:@"Video" ;1:@"Audio";2:@"Image";3:@"File"4:Record
//@property(nonatomic,copy)NSString *usrname;
//@property(nonatomic,assign) BOOL post;//上传 - 用处不大
//@property (nonatomic,copy)NSString *fileUploadSize;//上传
//@property(nonatomic,copy)NSString *postUrl;
//@property(nonatomic,copy)NSString *fileID;
//@property(nonatomic,strong)NSMutableData *fileReceivedData;//接受的数据
//@property(nonatomic,assign)BOOL isP2P;//是否是p2p下载
//@property(nonatomic,assign) int PostPointer;
//@property(nonatomic,copy)NSString *MD5;
@end
