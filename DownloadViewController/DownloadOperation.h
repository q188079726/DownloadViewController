//
//  DownloadOperation.h
//  DownloadViewController
//
//  Created by 李硕 on 16/2/24.
//  Copyright © 2016年 李硕. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface DownloadOperation : NSObject <NSCoding>

@property (nonatomic, strong) NSString *URLString;
@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, weak) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSProgress *progress;

@property (nonatomic,readonly)NSString *resumeDataPath;

+ (instancetype)downloadOperationWithURLString:(NSString *)URLString;
- (instancetype)initWithURLString:(NSString *)URLString;

- (void)resume;//开始或继续下载,可以继续则继续不能继续则开始新的下载
- (void)pause;//暂停,下次可以恢复继续下载
- (void)cancel;
- (void)forcedRedownload;//强制重新下载,不管之前是否有缓存(其实就是删除resumeData再开始)

+ (void)deleteResumeDataFromPath:(NSString *)path;//取消下载下次只能从新下载(实际上是删除resumeData,下次无法恢复一定会从新下载.至于临时文件,不用管,系统会处理)

@end
