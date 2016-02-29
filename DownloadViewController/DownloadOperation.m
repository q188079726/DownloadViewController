//
//  DownloadOperation.m
//  DownloadViewController
//
//  Created by 李硕 on 16/2/24.
//  Copyright © 2016年 李硕. All rights reserved.
//

#import "DownloadOperation.h"
#import "DownloadQueueController.h"
#import "MD5.h"


@interface DownloadOperation ()
@property (nonatomic, weak) NSURLSession *session;
@end

@implementation DownloadOperation
#pragma mark - init Method
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self initWithURLString:[aDecoder decodeObjectForKey:@"URLString"]];
    if (self) {
        NSString *file = [aDecoder decodeObjectForKey:@"fileName"];
        if (file) {
            self.fileName = file;
        } else {
            self.fileName = [[file componentsSeparatedByString:@"/"] lastObject];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.URLString forKey:@"URLString"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
}

+ (instancetype)downloadOperationWithURLString:(NSString *)URLString{
    
    return [[DownloadOperation alloc] initWithURLString:URLString];
}

- (instancetype)initWithURLString:(NSString *)URLString {
    self = [super init];
    if (self) {
        
        self.URLString = URLString;
    }
    return self;
}

- (NSURLSessionDownloadTask *)downloadTask {
    if (!_downloadTask) {
        
        NSData *resumeData = [NSData dataWithContentsOfFile:self.resumeDataPath];
        if (resumeData) {
            
            _downloadTask = [self.session downloadTaskWithResumeData:resumeData];
        }
        
        if (!_downloadTask) {
            _downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:self.URLString]];
        }
    }
    return _downloadTask;
}

- (NSProgress *)progress {
    if (!_progress) {
        _progress = [[NSProgress alloc] init];
    }
    return _progress;
}

- (NSURLSession *)session {
    if (!_session) {
        _session = [DownloadQueueController sharedQueueController].session;
    }
    return _session;
}

- (NSString *)resumeDataPath {
    NSString *tempFilePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[self.URLString MD5String]]];
    return tempFilePath;
}

#pragma mark - Logig Method
- (void)resume {
    [self.downloadTask resume];
}

- (void)pause {
    if (self.downloadTask) {
        [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        }];
        self.downloadTask = nil;
    }
}
- (void)cancel {
    if (self.downloadTask) {
        [self.downloadTask cancel];
        self.downloadTask = nil;
    }
}

- (void)forcedRedownload {
    [self cancel];
    
    [DownloadOperation deleteResumeDataFromPath:self.resumeDataPath];

    [self resume];
}

#pragma mark - Operation Method

+ (void)deleteResumeDataFromPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *err;
        [fileManager removeItemAtPath:path error:&err];
        if (err) {
            NSLog(@"删除临时文件失败:%@",err);
        }
    }
}

@end




