//
//  TFDownloadModel.m
//  Pods
//
//  Created by Fengtf on 2018/3/22.
//

#import "TFDownloadModel.h"

@implementation TFDownloadModel

- (instancetype)init {
    if (self = [super init]) {
        _progress = [[TFDownloadProgress alloc]init];
        _urlType = UrlHttp;
    }
    return self;
}

- (NSString *)filePath {
    NSString *lastPath = self.urlType == UrlHttp ? [NSString stringWithFormat:@"%@.mp4", self.title] : self.title;
    NSString *firstPath = [[self getDownBasePath] stringByAppendingPathComponent:@"File"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    if(![fileManager fileExistsAtPath:firstPath]) {
        [fileManager createDirectoryAtPath:firstPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return [firstPath stringByAppendingPathComponent:lastPath];
}

- (NSString *)tempPath {
    NSString *lastPath = self.urlType == UrlHttp ? [NSString stringWithFormat:@"%@.mp4", self.title] : self.title;
    NSString *firstPath = [[self getDownBasePath] stringByAppendingPathComponent:@"Temp"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    if(![fileManager fileExistsAtPath:firstPath]) {
        [fileManager createDirectoryAtPath:firstPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return [firstPath stringByAppendingPathComponent:lastPath];
}

//- (NSString *)

-(NSString *)getDownBasePath{
    NSString *pathstr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    pathstr = [pathstr stringByAppendingPathComponent:@"Downloads"]; //Downloads
    return pathstr;
}


@end



@implementation TFDownloadProgress

@end
