//
//  DatabaseTool.m
//  Diancai1
//
//  Created by user on 14-3-11.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "DatabaseTool.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

//下载
#import "DownLoadModel.h"
#import "FileModel.h"
#import "CommonHelper.h"

static FMDatabase *_db;
//order by id desc:降序 asc：升序
@implementation DatabaseTool

+ (void)initialize
{
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES) firstObject];
    NSString* sqlPath = [NSString stringWithFormat:@"%@/rrmj.sqlite",cachesPath];
    NSLog(@"--sqlPath:%@",sqlPath);
    _db = [[FMDatabase alloc] initWithPath:sqlPath];
    
    if (![_db open]) {
        [_db close];
        NSLog(@"打开数据库失败");
    }
    
    [_db setShouldCacheStatements:YES];
 
    //1：新下载  uniquenName 主键
    if (![_db tableExists:@"fileModel"]) {
        [_db executeUpdate:@"CREATE TABLE if not exists fileModel (id integer primary key autoincrement,uniquenName TEXT,movieId TEXT,episode integer,fileName TEXT,title TEXT,fileURL TEXT,iconUrl TEXT,targetPath TEXT,tempPath TEXT,filesize TEXT,filerecievesize TEXT,basepath TEXT,time TEXT,isHadDown integer,urlType integer)"];
    }
      
    [_db close];
}

#pragma mark - 下载2.0
/*******************************5 -- 新 - 下载2.0****************************************/
+(BOOL)addFileModelWithModel:(FileModel *)model
{
    if (![_db open]) {
        [_db close];
        NSAssert(NO, @"数据库打开失败");
        return NO;
    }
    [_db setShouldCacheStatements:YES];
    
    if (model == nil || model.uniquenName == nil || model.uniquenName.length == 0) {
        NSLog(@"加入下载列表失败-ID为空");
        return NO;
    }
 
    //1:判断是否已经加入到数据库中
    int count = [_db intForQuery:@"SELECT COUNT(uniquenName) FROM fileModel where uniquenName = ?;",model.uniquenName];
    
    if (count >= 1) {
        NSLog(@"-已经在下载列表中--");
        return NO;
    }
    //2:存储
    BOOL result = [_db executeUpdate:@"insert into fileModel (uniquenName,movieId,episode,fileName,fileURL,targetPath,tempPath,filesize,filerecievesize ,basepath,time,isHadDown,iconUrl,title,urlType) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",model.uniquenName,model.movieId,@(model.episode),model.fileName,model.fileURL,model.targetPath,model.tempPath,model.fileSize,model.fileReceivedSize,kDownDomanPath,model.time,@(NO),model.iconUrl,model.title,@(model.urlType)];
    
    [_db close];
    if (result) {

    }else{
        NSLog(@"加入下载列表失败");
    }
    return result;
}

/**
 *  根据是否下载完毕取出所有的数据
 *
 *  @param isDowned YES：已经下载，NO：未下载
 *
 *  @return 装有FileModel的模型
 */
+(NSArray *)getFileModeArray:(BOOL)isHadDown
{
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败");
        return nil;
    }
    
    [_db setShouldCacheStatements:YES];
     
    FMResultSet *rs = [_db executeQuery:@"SELECT * FROM fileModel where isHadDown = ? order by id asc;",@(isHadDown)];
//    uniquenName,movieId,episode,fileName,fileURL,targetPath,tempPath,filesize,filerecievesize ,basepath,basepath,time,isHadDown,iconUrl,title
    NSMutableArray * array = [NSMutableArray array];
    while (rs.next) {
        FileModel *file = [[FileModel alloc]init];
        file.fileName = [rs stringForColumn:@"fileName"];
        file.fileURL = [rs stringForColumn:@"fileURL"];
        file.fileSize = [rs stringForColumn:@"filesize"];
        file.fileReceivedSize = [rs stringForColumn:@"filerecievesize"];
        NSString*  path1= [CommonHelper getTargetPathWithBasepath:@"Downloads" subpath:@"Video"];
        path1 = [path1 stringByAppendingPathComponent:file.fileName];
        file.targetPath = path1;
        NSString*  path2= [CommonHelper getTempFolderPathWithBasepath:@"Downloads"];
        NSString *tempfilePath= [path2 stringByAppendingPathComponent: file.fileName];
        file.tempPath = tempfilePath;
        file.time = [rs stringForColumn:@"time"];
        file.iconUrl = [rs stringForColumn:@"iconUrl"];
        file.isHadDown  = [rs boolForColumn:@"isHadDown"];
        file.uniquenName = [rs stringForColumn:@"uniquenName"];
        file.title = [rs stringForColumn:@"title"];
        file.movieId = [rs stringForColumn:@"movieId"];
        file.episode = [rs intForColumn:@"episode"];
        file.urlType = [rs intForColumn:@"urlType"];
        
        file.isDownloading=NO;
        file.isDownloading = NO;
        file.willDownloading = NO;
        // file.isFirstReceived = YES;
        file.error = NO;
        
        NSData *fileData=[[NSFileManager defaultManager ] contentsAtPath:file.tempPath];
        NSInteger receivedDataLength=[fileData length];//获取已经下载的部分文件的大小
        file.fileReceivedSize=[NSString stringWithFormat:@"%ld",(long)receivedDataLength];        
        [array addObject:file];
    }
    [rs close];
    [_db close];
    return array;
}

+(void)updateFilesModeWhenDownFinish:(NSArray *)array
{
    if (array == nil || array.count == 0) {
        return;
    }
    for (FileModel *model in array) {
        [self updateFileModeWhenDownFinish:model];
    }
}


/**
 *  针对获取到真正的文件总大小的时候，更新文件的总大小
 *
 *  @param model FileModel模型
 *
 *  @return 是否更新成功
 */
+(BOOL)updateFileModeTotalSize:(FileModel *)model
{
    if (model.uniquenName == nil || model.uniquenName.length == 0) {
        NSLog(@"MovieId为空，跟新下载完毕列表失败");
        return NO;
    }
    
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败");
        return NO;
    }
    [_db setShouldCacheStatements:YES];
 
    int count = [_db intForQuery:@"SELECT COUNT(1) FROM fileModel where isHadDown = ? and uniquenName = ?;",@(NO),model.uniquenName];
    if (count == 0) {
        NSLog(@"没有剧集记录，无法更新");
        return NO;
    }
    
    BOOL result = false ;
    if (model.fileSize != nil || model.fileSize.length != 0 || [model.fileSize longLongValue] != 0) {
        result = [_db executeUpdate:@"update fileModel set filesize =? where uniquenName = ?;",model.fileSize,model.uniquenName];
    }
    [_db close];
    if (!result) {
        NSLog(@"---更改数据库信息失败---");
    }
    
    return result;
}

/**
 *  下载完毕更新数据库
 *
 *  @param model FileModel模型
 *
 *  @return 是否更新成功
 */
+(BOOL)updateFileModeWhenDownFinish:(FileModel *)model
{
    if (model.uniquenName == nil || model.uniquenName.length == 0) {
//        [IanAlert alertError:@"MovieId为空，跟新下载完毕列表失败"];
        return NO;
    }
    
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败");
        return NO;
    }
    [_db setShouldCacheStatements:YES];
    /**
     NSDictionary *filedic = [NSDictionary dictionaryWithObjectsAndKeys:fileinfo.fileName,@"filename",fileinfo.time,@"time",fileinfo.fileSize,@"filesize",fileinfo.targetPath,@"filepath",imagedata,@"fileimage", nil];
     */
    int count = [_db intForQuery:@"SELECT COUNT(1) FROM fileModel where isHadDown = ? and uniquenName = ?;",@(NO),model.uniquenName];
    if (count == 0) {
        NSLog(@"没有剧集记录，无法更新");
        return NO;
    }
 
    BOOL result = false ;
//    if (model.fileName != nil || model.fileName.length != 0) {
//        result = [_db executeUpdate:@"update fileModel set title =?  where uniquenName = ?;",model.title,model.uniquenName];
//    }
    
    if (model.fileSize != nil || model.fileSize.length != 0 || [model.fileSize longLongValue] != 0) {
        result = [_db executeUpdate:@"update fileModel set filesize =? ,isHadDown=? where uniquenName = ?;",model.fileSize,@(YES),model.uniquenName];
    }
//    if (model.iconUrl != nil || model.iconUrl.length != 0) {
//        result = [_db executeUpdate:@"update fileModel set iconUrl = ? where uniquenName = ?;",model.iconUrl,model.uniquenName];
//    }
//    if (model.fileURL != nil || model.fileURL.length != 0) {
//        result = [_db executeUpdate:@"update fileModel set fileURL = ? where uniquenName = ?;",model.fileURL,model.uniquenName];
//    }
    [_db close];
    if (!result) {
        NSLog(@"---更改数据库信息失败---");
    }
    
    return result;
}

/**
 *  这个剧是否在下载列表
 *
 *  @param uniquenName uniquenName ： MovieId+epsiode
 *
 *  @return YES：存在 ； NO：不存在
 */
+(BOOL)isFileModelInDB:(NSString *)uniquenName
{
    if (uniquenName == nil || uniquenName.length == 0) {
        NSLog(@"剧集id为空，跟新下载完毕列表失败");
        return NO;
    }
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败");
        return nil;
    }
    [_db setShouldCacheStatements:YES];
    int count = [_db intForQuery:@"SELECT COUNT(uniquenName) FROM fileModel where uniquenName = ?;",uniquenName];
    [_db close];
    if (count == 0) {
        return NO;
    }else{
        return YES;
    }
}

/**
 *  读取那些剧被下载 -- 不包括详细信息（只取到那些剧集被下载即可）
 *
 *  @return 下载完毕的剧集Array
 */
+(NSArray *)getFileModelsHadDownLoad
{
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败");
        return nil;
    }
    
    [_db setShouldCacheStatements:YES];
    FMResultSet *rs = [_db executeQuery:@"SELECT DISTINCT title,movieId,iconUrl from fileModel where isHadDown = ? order by id desc;",@(YES)];
    NSMutableArray * array = [NSMutableArray array];
    while (rs.next) {
//        DownedSeriesModel *model = [[DownedSeriesModel alloc]init];
//        model.title = [rs stringForColumn:@"title"] ;
//        model.movieId = [rs stringForColumn:@"movieId"];
//        model.iconUrl = [rs stringForColumn:@"iconUrl"];
//        model.seriesCount = [self getFileModelCountWithMovieId:model.movieId];
//        [array addObject:model];
    }
    [rs close];
    [_db close];
    return array;
}

/**
 *  找出某一部剧一共下载了几部
 *
 *  @param MovieId 剧集id
 *
 *  @return 下载次数
 */
+(int)getFileModelCountWithMovieId:(NSString *)MovieId
{
    if (![_db open]) {
        [_db close];   NSLog(@"数据库打开失败");  return 0; }
    
    [_db setShouldCacheStatements:YES];
    
    int count = [_db intForQuery:@"SELECT COUNT(movieId) FROM fileModel where isHadDown = 1 and movieId = ?;",MovieId];
    return (int)count;
}


/**
 *  根据剧集id，找到已经下载的那些剧
 *
 *  @param movieId 剧集id
 *
 *  @return 装有FileModel的数组
 */
+(NSArray *)getDownLoadFileModelWithMovidId:(NSString *)movieId
{
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败");
        return nil;
    }
    
    [_db setShouldCacheStatements:YES];
    FMResultSet *rs = [_db executeQuery:@"SELECT * FROM fileModel where movieId = ? and isHadDown = 1  order by episode asc;",movieId];
    
    NSMutableArray * array = [NSMutableArray array];
    while (rs.next) {
        FileModel *file = [[FileModel alloc]init];
        file.fileName = [rs stringForColumn:@"fileName"];
        file.fileURL = [rs stringForColumn:@"fileURL"];
        file.fileSize = [rs stringForColumn:@"filesize"];
        file.fileReceivedSize = [rs stringForColumn:@"filerecievesize"];
        NSString*  path1= [CommonHelper getTargetPathWithBasepath:kDownDomanPath subpath:@"Video"];
        path1 = [path1 stringByAppendingPathComponent:file.fileName];
        file.targetPath = path1;
        NSString*  path2= [CommonHelper getTempFolderPathWithBasepath:kDownDomanPath];
        NSString *tempfilePath= [path2 stringByAppendingPathComponent: file.fileName];
        file.tempPath = tempfilePath;
        file.iconUrl = [rs stringForColumn:@"iconUrl"];
        file.uniquenName = [rs stringForColumn:@"uniquenName"];
        file.title = [rs stringForColumn:@"title"];
        file.movieId = [rs stringForColumn:@"movieId"];
        file.episode = [rs intForColumn:@"episode"];
        file.urlType = [rs intForColumn:@"urlType"];
        [array addObject:file];
    }
    [rs close];
    [_db close];
    return array;
}

/**
 *  是否这部剧已经下载完毕
 *
 *  @param uniquenName 剧集Id
 *
 *  @return YES:下载完毕 ； NO：没有下载完毕
 */
+(BOOL)isThisHadLoaded:(NSString *)movieID episode:(int)episode
{
    if (movieID ==  nil || movieID.length == 0) {
        return NO;
    }
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败");
        return NO;
    }
    
    NSUInteger count = [_db intForQuery:@"SELECT COUNT(1) FROM fileModel where movieId = ? and episode = ?;",movieID,@(episode)];
    [_db close];
    
    if (count  == 0) {
        return NO;
    }else{
        return YES;
    }
}

/**
 *  根据uniquenName删除已经下载的剧 -- 只会删除一个
 *
 *  @param uniquenName MovieId+eposide
 *
 *  @return YES:成功；NO：失败
 */
+(BOOL)delFileModelWithUniquenName:(NSString *)uniquenName
{
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败！");
        return NO;
    }
    [_db setShouldCacheStatements:YES];
    BOOL result = [_db executeUpdate:@"DELETE FROM fileModel where uniquenName = ?",uniquenName];
    [_db close];
    return result;
}
 
/**
 *  根据MovieId删除已经下载的剧 -- 会删除多个
 *
 *  @param movieId 剧集Id
 *
 *  @return YES:成功；NO：失败
 */
+(BOOL)delFileModelsWithMovieId:(NSString *)movieId
{
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败！");
        return NO;
    }
    [_db setShouldCacheStatements:YES];
    BOOL result = [_db executeUpdate:@"DELETE FROM fileModel where movieId = ? and isHadDown = ?",movieId ,@(YES)];
    [_db close];
    return result;
}

/**
 *  是否这部剧已经下载完毕
 *
 *  @param uniquenName 剧集Id
 *
 *  @return YES:下载完毕 ； NO：没有下载完毕
 */
+(NSDictionary *)isHadDowned:(NSString *)movieID episode:(int)episode
{
    int urlType = 0;
    
    if (movieID ==  nil || movieID.length == 0) {
        return @{@"isHad" : @(NO) , @"urlType" : @(0)};
    }
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败");
        return @{@"isHad" : @(NO) , @"urlType" : @(0)};
    }
    
    int count = [_db intForQuery:@"SELECT COUNT(uniquenName) FROM fileModel where movieId = ? and isHadDown = ? and episode = ?;",movieID,@(YES),@(episode)];
    if (count == 0) {
        [_db close];
        return @{@"isHad" : @(NO) , @"urlType" : @(0)};
    }else{
        FMResultSet *rs = [_db executeQuery:@"select urlType from fileModel where movieId = ? and episode = ? order by id desc",movieID,@(episode)];
        while (rs.next) {
            urlType  = [rs intForColumn:@"urlType"];
        }
        [_db close];
        return @{@"isHad" : @(YES) , @"urlType" : @(urlType)};
    }
}

/*******************************5 -- 新 - 下载****************************************/


 
@end



