//
//  FilesDownManage.m
//  MovieDownloadManager
//
//  Created by Fengtf on 15/11/4.
//  Copyright © 2015年 ftf. All rights reserved.
//

#import "FilesDownManage.h"
#import "Reachability.h"

//最大并发数
#define MAXLINES  (1)

#define TEMPPATH [CommonHelper getTempFolderPathWithBasepath:_basepath]

@interface FilesDownManage()

@property (nonatomic,strong) ASIHTTPRequest *request;

@property(nonatomic,copy)NSString *basepath;

@end

@implementation FilesDownManage

static   FilesDownManage *sharedFilesDownManage = nil;

/**
 *  根据文件名字，得出文件的下载完毕的保存路径
 *
 *  @param name 文件的保存名字
 *
 *  @return 文件的真实路径
 */
-(NSString *)getTargetPath:(NSString *)name
{
    NSString *path = @"Video";
    path= [CommonHelper getTargetPathWithBasepath:_basepath subpath:path];//--/DownLoad/video
    path = [path stringByAppendingPathComponent:name];//--/DownLoad/video/4646
    
    return path;
}
/**
 *  根据文件名字，得出文件的临时的保存路径
 *
 *  @param name 文件的保存名字
 *
 *  @return 文件的临时路径
 */
-(NSString *)getTempPath:(NSString *)name
{
    NSString *tempPath= [TEMPPATH stringByAppendingPathComponent:name];//--/Documents/DownLoad/Temp
    return tempPath;
}

#pragma mark - 存储数据
-(void)saveDownloadFile:(FileModel*)fileinfo{
    BOOL result = [DatabaseTool addFileModelWithModel:fileinfo];
    NSLog(@"-save result--:%d",result);
}

-(void)beginRequest:(FileModel *)fileInfo isBeginDown:(BOOL)isBeginDown
{
    for(ASIHTTPRequest *tempRequest in self.downinglist)  {
        if([[[self getRequestUrlStr:tempRequest] lastPathComponent] isEqualToString:[fileInfo.fileURL lastPathComponent]])  {
            if ([tempRequest isExecuting] && isBeginDown) {
                return;
            }else if ([tempRequest isExecuting] && !isBeginDown)  {//开始下载
                [tempRequest setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];
                [tempRequest cancel];
                self.request = nil;
                [self.downloadDelegate updateCellProgress:tempRequest];
                return;
            }
        }
    }
    
    [self saveDownloadFile:fileInfo];
    
    //NSLog(@"targetPath %@",fileInfo.targetPath);
    //按照获取的文件名获取临时文件的大小，即已下载的大小
    
    fileInfo.isFirstReceived=YES;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSData *fileData=[fileManager contentsAtPath:[self getTempPath:fileInfo.fileName]];
    NSInteger receivedDataLength=[fileData length];
    fileInfo.fileReceivedSize=[NSString stringWithFormat:@"%ld",(long)receivedDataLength];
    
    NSLog(@"start down::已经下载：%@",fileInfo.fileReceivedSize);
    
#pragma mark - 启用ASIHTTPRequest进行下载请求
     ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:fileInfo.fileURL]];
 
    request.delegate=self;
    [request setDownloadDestinationPath:[self getTargetPath:fileInfo.fileName]];
    [request setTemporaryFileDownloadPath:[self getTempPath:fileInfo.fileName]];
    [request setDownloadProgressDelegate:self];
    [request setNumberOfTimesToRetryOnTimeout:2];
    // [request setShouldContinueWhenAppEntersBackground:YES];
    //    [request setDownloadProgressDelegate:downCell.progress];//设置进度条的代理,这里由于下载是在AppDelegate里进行的全局下载，所以没有使用自带的进度条委托，这里自己设置了一个委托，用于更新UI
    [request setAllowResumeForFileDownloads:YES];//支持断点续传
    
    [request setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];//设置上下文的文件基本信息
    [request setTimeOutSeconds:30.0f];
    if (isBeginDown) {
        if (self.request == nil) {
            self.request = request;
            [request startAsynchronous];
        }else{
            fileInfo.isDownloading = NO;
            fileInfo.willDownloading = YES;
        }
    }
    
    //如果文件重复下载或暂停、继续，则把队列中的请求删除，重新添加
    BOOL exit = NO;
    for(ASIHTTPRequest *tempRequest in self.downinglist)  {
        //地址存在重定向问题，ASIHTTPRequest 中有一个url和originalURL 连个不同
        if([[[self getRequestUrlStr:tempRequest] lastPathComponent] isEqualToString:[fileInfo.fileURL lastPathComponent]]) {
            [self.downinglist replaceObjectAtIndex:[_downinglist indexOfObject:tempRequest] withObject:request];
            
            exit = YES;
            break;
        }
    }
    
    if (!exit) {
        [self.downinglist addObject:request];
        NSLog(@"EXIT!!!!---::%@",[request.url absoluteString]);
    }
    [self.downloadDelegate updateCellProgress:request];
}

-(NSString *)getRequestUrlStr:(ASIHTTPRequest *)tempRequest
{
    NSString *judgeUrl = @"";
    if (tempRequest.originalURL.absoluteString != nil || tempRequest.originalURL.absoluteString.length != 0) {
        judgeUrl = tempRequest.originalURL.absoluteString;
    }else{
        judgeUrl = tempRequest.url.absoluteString;
    }
    
    return judgeUrl;
}

#pragma mark - 重新进行下载
-(void)resumeRequest:(ASIHTTPRequest *)request{
    if(self.request){
        [self.request cancel];
        self.request = nil;
    }
    NSInteger max = MAXLINES;
    FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    NSInteger downingcount =0;
    NSInteger indexmax =-1;
    for (FileModel *file in _filelist) {
        if (file.isDownloading) {
            downingcount++;
            if (downingcount==max) {
                indexmax = [_filelist indexOfObject:file];
            }
        }
    }//此时下载中数目是否是最大，并获得最大时的位置Index
    if (downingcount == max) {
        FileModel *file  = [_filelist objectAtIndex:indexmax];
        if (file.isDownloading) {
            file.isDownloading = NO;
            file.willDownloading = YES;
        }
    }//中止一个进程使其进入等待
    for (FileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.isDownloading = YES;
            file.willDownloading = NO;
            file.error = NO;
        }
    }//重新开始此下载
    [self startLoad];
}

#pragma mark - 停止下载
-(void)stopRequest:(ASIHTTPRequest *)request{
    NSInteger max = MAXLINES;
    if([request isExecuting]) {
        [request cancel];
    }
    if (self.request) {
        [self.request cancel];
        self.request = nil;
    }
    FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    for (FileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.isDownloading = NO;
            file.willDownloading = NO;
            break;
        }
    }
    NSInteger downingcount =0;
    
    for (FileModel *file in _filelist) {
        if (file.isDownloading) {
            downingcount++;
        }
    }
    if (downingcount<max) {
        for (FileModel *file in _filelist) {
            if (!file.isDownloading&&file.willDownloading){
                file.isDownloading = YES;
                file.willDownloading = NO;
                break;
            }
        }
    }
    
    [self startLoad];
}

#pragma mark - 删除下载的操作
-(void)deleteRequest:(ASIHTTPRequest *)request{
    bool isexecuting = NO;
    if([request isExecuting])  {
        [request cancel];
        isexecuting = YES;
    }
    if(self.request){
        [self.request cancel];
        self.request = nil;
    }
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    FileModel *fileInfo=(FileModel*)[request.userInfo objectForKey:@"File"];
    NSString *path = [self getTempPath:fileInfo.fileName];
    
    [DatabaseTool delFileModelWithUniquenName:fileInfo.fileName];//删除数据库记录
    [fileManager removeItemAtPath:path error:&error]; //删除临时文件
 
    if(!error)  {
        NSLog(@"%@",[error description]);
    }
    
    NSInteger delindex =-1;
    for (FileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            delindex = [_filelist indexOfObject:file];
            break;
        }
    }
    if (delindex!=NSNotFound)
        [_filelist removeObjectAtIndex:delindex];
    
    [_downinglist removeObject:request];
    
    if (isexecuting) {
        // [self startWaitingRequest];
        [self startLoad];
    }
}

-(void)clearAllFinished{
    [_finishedlist removeAllObjects];
}

-(void)clearAllRquests{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    for (ASIHTTPRequest *request in _downinglist) {
        if([request isExecuting])
            [request cancel];
        FileModel *fileInfo=(FileModel*)[request.userInfo objectForKey:@"File"];
        NSString *path= [self getTempPath:fileInfo.fileName];
        [DatabaseTool delFileModelWithUniquenName:fileInfo.fileName];//删除数据库记录
        [fileManager removeItemAtPath:path error:&error];
 
        if(!error)  {
            NSLog(@"%@",[error description]);
        }
        
    }
    [_downinglist removeAllObjects];
    [_filelist removeAllObjects];
}

/**
 *  加载所有的未下载的文件
 */
#pragma mark - 加载未下载的文件文件
-(void)loadTempfiles
{
    self.basepath = kDownDomanPath ;//@"DownLoads";
    NSArray *array = [DatabaseTool getFileModeArray:NO];//拿到未下载的数据
    [_filelist addObjectsFromArray:array];
    [self startLoad];
}
/**
 *  加载所有的已经下载完毕的文件
 */
-(void)loadFinishedfiles
{
    NSArray *array = [DatabaseTool getFileModeArray:YES];//拿到未下载的数据
    [_finishedlist addObjectsFromArray:array];
}
/**
 *  下载完毕 写文件
 */
-(void)saveFinishedFile{
    //[_finishedList addObject:file];
    if (_finishedlist==nil || _finishedlist.count == 0) {
        return;
    }
    [DatabaseTool updateFilesModeWhenDownFinish:_finishedlist];
    
}
-(void)deleteFinishFile:(FileModel *)selectFile{
    [_finishedlist removeObject:selectFile];
    
}

#pragma mark -- 入口 --
-(void)downFileUrl:(ContentModel *)model
{
    [self downFileUrl:model.downUrl fileName:model.uniquenName title:model.title iconUrl:model.iconUrl];
}
/**
 *  加入下载列表--进行下载
 *
 *  @param downUrl     下载的链接
 *  @param uniquenName 唯一的名字（保存文件用）
 *  @param title     列表展示用的名字（展示下载及已完成列表用）
 *  @param iconUrl     图片名字
 */
-(void)downFileUrl:(NSString *)downUrl fileName:(NSString *)fileName title:(NSString *)title iconUrl:(NSString *)iconUrl
{

    //如果是重新下载，则说明肯定该文件已经被下载完，或者有临时文件正在留着，所以检查一下这两个地方，存在则删除掉
    NSString *name = fileName;//存储硬盘上的的名字
 
    if (_fileInfo!=nil) {
        _fileInfo = nil;
    }
    _fileInfo = [[FileModel alloc]init];
    _fileInfo.fileName = name;
    _fileInfo.fileURL = downUrl;
    _fileInfo.iconUrl = iconUrl;
    _fileInfo.title = title;
    if ([_fileInfo.fileURL containsString:@"m3u8"]) {
        _fileInfo.urlType = FileUrlM3u8;
    }else{
        _fileInfo.urlType = FileUrlHttp;
    }
    
    _fileInfo.isDownloading=YES;
    _fileInfo.willDownloading = YES;
    _fileInfo.error = NO;
    _fileInfo.isFirstReceived = YES;
    
    BOOL result = [DatabaseTool isFileModelInDB:fileName];///已经下载过一次
    if(result){//已经下载过一次该音乐
        NSLog(@"--该文件已下载，是否重新下载？--");
        return;
    }
    
    //若不存在文件和临时文件，则是新的下载
    [self.filelist addObject:_fileInfo];
    
    [self startLoad];
    if(self.VCdelegate!=nil && [self.VCdelegate respondsToSelector:@selector(allowNextRequest)]) {
        [self.VCdelegate allowNextRequest];
    }else{
        NSLog(@"--该文件成功添加到下载队列--");
        return;
    }
    return;
}

#pragma mark - 开始下载
-(void)startLoad{
    NSInteger num = 0;
    NSInteger max = MAXLINES;
    for (FileModel *file in _filelist) {
        if (!file.error) {
            if (file.isDownloading==YES) {
                file.willDownloading = NO;
                
                if (num>max) {
                    file.isDownloading = NO;
                    file.willDownloading = YES;
                }else
                    num++;
            }
        }
    }
    if (num<max) {
        for (FileModel *file in _filelist) {
            if (!file.error) {
                if (!file.isDownloading&&file.willDownloading) {
                    num++;
                    if (num>max) {
                        break;
                    }
                    file.isDownloading = YES;
                    file.willDownloading = NO;
                }
            }
        }
        
    }
    for (FileModel *file in _filelist) {
        if (!file.error) {
            if (file.isDownloading==YES) {
                [self beginRequest:file isBeginDown:YES];
            }else
                [self beginRequest:file isBeginDown:NO];//暂定下载
        }
    }
}

#pragma mark -- init methods --
-(id)initWithBasepath:(NSString *)basepath TargetPathArr:(NSArray *)targetpaths{
    self.basepath = basepath;
 
    _filelist = [NSMutableArray array];
    _downinglist = [NSMutableArray array];
    _finishedlist = [NSMutableArray array];
    return  [self init];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        if (self.basepath!=nil) {
            [self loadFinishedfiles];
            [self loadTempfiles];
        }
    }
    return self;
}
-(void)cleanLastInfo{
    for (ASIHTTPRequest *request in _downinglist) {
        if([request isExecuting])
            [request cancel];
    }
    [self saveFinishedFile];
    [_downinglist removeAllObjects];
    [_finishedlist removeAllObjects];
    [_filelist removeAllObjects];
    
}
+(FilesDownManage *) sharedFilesDownManageWithBasepath:(NSString *)basepath
                                         TargetPathArr:(NSArray *)targetpaths{
    @synchronized(self){
        if (sharedFilesDownManage == nil) {
            sharedFilesDownManage = [[self alloc] initWithBasepath: basepath TargetPathArr:targetpaths];
        }
    }
    if (![sharedFilesDownManage.basepath isEqualToString:basepath]) {
        
        [sharedFilesDownManage cleanLastInfo];
        sharedFilesDownManage.basepath = basepath;
        [sharedFilesDownManage loadTempfiles];
        [sharedFilesDownManage loadFinishedfiles];
    }
    sharedFilesDownManage.basepath = basepath;
//    sharedFilesDownManage.targetPathArray =[NSMutableArray arrayWithArray:targetpaths];
    return  sharedFilesDownManage;
}

+(FilesDownManage *) sharedFilesDownManage{
    @synchronized(self){
        if (sharedFilesDownManage == nil) {
            sharedFilesDownManage = [[self alloc] init];
        }
    }
    return  sharedFilesDownManage;
}
+(id) allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (sharedFilesDownManage == nil) {
            sharedFilesDownManage = [super allocWithZone:zone];
            return  sharedFilesDownManage;
        }
    }
    return nil;
}

#pragma mark -- ASIHttpRequest回调委托 --

//出错了，如果是等待超时，则继续下载
-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error=[request error];
    NSLog(@"ASIHttpRequest出错了!%@",error);
    if (error.code==4) {
        return;
    }
    if ([request isExecuting]) {
        [request cancel];
    }
    FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    fileInfo.isDownloading = NO;
    fileInfo.willDownloading = NO;
    fileInfo.error = YES;
    for (FileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.isDownloading = NO;
            file.willDownloading = NO;
            file.error = YES;
        }
    }
    [self.downloadDelegate updateCellProgress:request];
}

-(void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"http--下载，开始啦!");
    NSLog(@"code1:%d",[request responseStatusCode]);
}

-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"http--下载，收到回复啦!");
      NSLog(@"code2:%d",[request responseStatusCode]);
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
    int httpCode = [request responseStatusCode];
    if (httpCode == 424) {
        fileInfo.error = YES;
        fileInfo.isDownloading = NO;
        if([self.downloadDelegate respondsToSelector:@selector(updateCellProgress:)]){
            [self.downloadDelegate updateCellProgress:request];
        }
        return;
    }
    
    NSString *len = [responseHeaders objectForKey:@"Content-Length"];
    NSLog(@"http--didReceiveResponseHeaders--：%@,%@,%@",fileInfo.fileSize,fileInfo.fileReceivedSize,len);
    //这个信息头，首次收到的为总大小，那么后来续传时收到的大小为肯定小于或等于首次的值，则忽略
    if ([len longLongValue] == 0 || [fileInfo.fileSize longLongValue]> [len longLongValue]){
        return;
    }else {
        fileInfo.fileSize = [NSString stringWithFormat:@"%lld",  [len longLongValue]];
        [DatabaseTool updateFileModeTotalSize:fileInfo];
    }
}

-(void)setProgress:(float)newProgress
{
//    NSLog(@"--http--deleg--progress-%f",newProgress);
}

-(void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
//    NSLog(@"-http--didReceiveBytes：%@,%lld",fileInfo.fileReceivedSize,bytes);
    if (fileInfo.isFirstReceived) {
        fileInfo.isFirstReceived=NO;
        fileInfo.fileReceivedSize =[NSString stringWithFormat:@"%lld",bytes];
    }else if(!fileInfo.isFirstReceived) {
        fileInfo.fileReceivedSize=[NSString stringWithFormat:@"%lld",[fileInfo.fileReceivedSize longLongValue]+bytes];
    }
    if([self.downloadDelegate respondsToSelector:@selector(updateCellProgress:)]){
        [self.downloadDelegate updateCellProgress:request];
    }
}
#pragma mark - 下载完毕
//将正在下载的文件请求ASIHttpRequest从队列里移除，并将其配置文件删除掉,然后向已下载列表里添加该文件对象
-(void)requestFinished:(ASIHTTPRequest *)request
{
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
    if (fileInfo.error) {
        return;
    }
    
    NSLog(@"---：%@下载结束---error:%@",fileInfo.fileName,request.error);
    
    [_finishedlist addObject:fileInfo];
 
    [_filelist removeObject:fileInfo];
    [_downinglist removeObject:request];
    
    if([request isExecuting]) {
        [request cancel];
    }
    self.request = nil;
    
    [self saveFinishedFile];
    [self startLoad];
    
    if([self.downloadDelegate respondsToSelector:@selector(finishedDownload:)])  {
        [self.downloadDelegate finishedDownload:request];
    }
}
 
-(void)restartAllRquests{
    for (ASIHTTPRequest *request in _downinglist) {
        if([request isExecuting])
            [request cancel];
    }
    [self startLoad];
}
@end
