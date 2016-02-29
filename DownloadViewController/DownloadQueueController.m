//
//  DownloadQueueController.m
//  DownloadViewController
//
//  Created by 李硕 on 16/2/24.
//  Copyright © 2016年 李硕. All rights reserved.
//

#import "DownloadQueueController.h"

#define DOWNLOAD_ID @"cn.com.crc.lishuo"

NSString *const DownloadQueueDidSuccessDownloadNotification = @"DownloadQueueDidSuccessDownloadNotification ";
NSString *const DownloadQueueDidFailureDownloadNotification = @"DownloadQueueDidFailureDownloadNotification ";
NSString *const DownloadQueueWillRefreshProgressNotification =@"DownloadQueueWillRefreshProgressNotification";
NSString *const DownloadQueueUserInfoDownloadURLStringKey = @"URLString";

NSString *const DownloadQueueUserInfoDownloadDataKey = @"downloadData";
NSString *const DownloadQueueUserInfoDownloadErrorKey = @"error";
NSString *const DownloadQueueUserInfoDownloadProgressKey = @"progress";

@interface DownloadQueueController () <NSURLSessionDownloadDelegate>
@end

@implementation DownloadQueueController
#pragma mark - init Method
static DownloadQueueController *_dlqc;

+ (instancetype)sharedQueueController {
    if (!_dlqc) {
        _dlqc = [[DownloadQueueController alloc] init];
    }
    return _dlqc;
}

+ (instancetype)alloc {
    if (!_dlqc) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _dlqc = [super alloc];
        });
    }
    return _dlqc;
}

- (instancetype)init {
    self = [super init];
    if (self) {

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.downloadOperationQueue];
            [userDef setObject:data forKey:DOWNLOAD_ID];
            [userDef synchronize];
        }];
    }
    return self;
}

- (NSMutableDictionary *)downloadOperationQueue {
    if (!_downloadOperationQueue) {
        NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:DOWNLOAD_ID];
        if (data) {
            NSDictionary *tempDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            _downloadOperationQueue = [NSMutableDictionary dictionaryWithDictionary:tempDict];
        } else {
            _downloadOperationQueue = [NSMutableDictionary dictionary];
        }
    }
    return _downloadOperationQueue;
}

- (void)setSuccessBlock:(void (^)(NSString *, NSData *))block {
    self.successBlock = block;
}

- (void)setFailureBlock:(void (^)(NSString *, NSError *))block {
    self.failureBlock = block;
}

- (void)setProgressBlock:(void (^)(NSString *, NSProgress *))block {
    self.progressBlock = block;
}
#pragma mark - 在这里配置session
- (NSURLSession *)session {
    if (!_session) {
        
        //        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:DOWNLOAD_ID];
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}
#pragma mark - Logic Method
- (void)addDownloadRecord:(DownloadOperation *)operation {
    [self.downloadOperationQueue setObject:operation forKey:operation.URLString];
}

- (void)deleteDownloadRecord:(DownloadOperation *)operation {
    [self.downloadOperationQueue removeObjectForKey:operation.URLString];
    operation = nil;
}

- (void)deleteDownloadCacheFile:(DownloadOperation *)operation {
    [DownloadOperation deleteResumeDataFromPath:operation.resumeDataPath];
}

#pragma mark - Operation Method
- (void)startDownload:(NSString *)URLString {
    DownloadOperation *operation = [self.downloadOperationQueue objectForKey:URLString];
    if (!operation) {
        operation = [DownloadOperation downloadOperationWithURLString:URLString];
        [self addDownloadRecord:operation];
    }
    [operation resume];
}

- (void)stopDownload:(NSString *)URLString {
    DownloadOperation *operation = [self.downloadOperationQueue objectForKey:URLString];
    if (operation) {
        [operation pause];
    }
}

- (void)redownload:(NSString *)URLString {
    DownloadOperation *operation = [self.downloadOperationQueue objectForKey:URLString];
    if (operation) {
        [operation forcedRedownload];
    } else {
        [self startDownload:URLString];
    }
}

- (void)deleteDownload:(NSString *)URLString {
    DownloadOperation *operation = [self.downloadOperationQueue objectForKey:URLString];
    if (operation) {
        [operation cancel];
        [self deleteDownloadCacheFile:operation];
        [self deleteDownloadRecord:operation];
    }
}

- (void)startAllDownloads {
    for (NSString *URLString in self.downloadOperationQueue.allKeys) {
        [self startDownload:URLString];
    }
}
- (void)stopAllDownloads {
    for (NSString *URLString in self.downloadOperationQueue.allKeys) {
        [self stopDownload:URLString];
    }
}
- (void)deleteAllDownloads {
    for (NSString *URLString in self.downloadOperationQueue.allKeys) {
        [self deleteDownload:URLString];
    }
}

#pragma mark -- NSURLSessionDelegate Method
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
}

#pragma mark - NSURLSessionTaskDelegate Method
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (error) {
            NSLog(@"didCompleteWithError:%@",error);
            NSString *URLString = task.currentRequest.URL.absoluteString;
            if (URLString == nil) {
                return ;
            }
            DownloadOperation *operation = [self.downloadOperationQueue objectForKey:URLString];
            NSData *resumeData = [[error userInfo] objectForKey:NSURLSessionDownloadTaskResumeData];
            if (resumeData) {
                [resumeData writeToFile:operation.resumeDataPath atomically:NO];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DownloadQueueDidFailureDownloadNotification object:nil userInfo:@{DownloadQueueUserInfoDownloadErrorKey:error,DownloadQueueUserInfoDownloadURLStringKey:URLString}];
        }
    });
}

#pragma mark -- NSURLSessionDownloadTaskDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSString *URLString = downloadTask.currentRequest.URL.absoluteString;
        NSData *downloadData = [NSData dataWithContentsOfURL:location];
        NSString *finalPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
        NSLog(@"下载完成,url:%@  保存地址为:%@",URLString,finalPath);
        [downloadData writeToFile:finalPath atomically:NO];
        
       
        if (downloadData) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DownloadQueueDidFailureDownloadNotification object:nil userInfo:@{DownloadQueueUserInfoDownloadDataKey:downloadData,DownloadQueueUserInfoDownloadURLStringKey:URLString}];
        } else {
            NSError *err = [NSError errorWithDomain:DOWNLOAD_ID code:-1 userInfo:@{@"reason":@"下载完成,但是无法读取data"}];
            [[NSNotificationCenter defaultCenter] postNotificationName:DownloadQueueDidFailureDownloadNotification object:nil userInfo:@{DownloadQueueUserInfoDownloadErrorKey:err,DownloadQueueUserInfoDownloadURLStringKey:URLString}];
        }
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"%d downloading:%lld/%lld",downloadTask.taskIdentifier,totalBytesWritten,totalBytesExpectedToWrite);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *URLString = downloadTask.currentRequest.URL.absoluteString;
        if (URLString == nil) {
            return ;
        }
        
        DownloadOperation *operation = [self.downloadOperationQueue objectForKey:URLString];
        if (!operation) {
            NSLog(@"获取进度条的task失败!!!,%@",downloadTask.currentRequest.URL);
            return;
        }
        operation.progress.totalUnitCount = totalBytesExpectedToWrite;
        operation.progress.completedUnitCount = totalBytesWritten;

        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadQueueWillRefreshProgressNotification object:nil userInfo:@{DownloadQueueUserInfoDownloadProgressKey:operation.progress,DownloadQueueUserInfoDownloadURLStringKey:URLString}];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"didresumeAtOffset%lld",fileOffset);
}
@end
