//
//  DownloadViewController.m
//  DownloadViewController
//
//  Created by 李硕 on 16/2/24.
//  Copyright © 2016年 李硕. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadOperation.h"
#import "DownloadTableViewCell.h"
#define DOWNLOADCELL_ID @"DownloadTableViewCell"
@interface DownloadViewController () <UITableViewDataSource,UITableViewDelegate, DownloadTableViewCellDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) DownloadQueueController *controller;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation DownloadViewController
- (DownloadQueueController *)controller {
    if (!_controller) {
        _controller = [DownloadQueueController sharedQueueController];
    }
    return _controller;
}

- (NSArray *)dataSource {
    return self.controller.downloadOperationQueue.allKeys;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
    self.tableView.allowsSelectionDuringEditing = YES;
    [self.tableView registerNib:[UINib nibWithNibName:DOWNLOADCELL_ID bundle:[NSBundle mainBundle]] forCellReuseIdentifier:DOWNLOADCELL_ID];
    
    [self addObserver:self.controller forKeyPath:@"downloadOperationQueue" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:DownloadQueueWillRefreshProgressNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        NSString *url = [note.userInfo objectForKey:DownloadQueueUserInfoDownloadURLStringKey];
        NSProgress *progress = [note.userInfo objectForKey:DownloadQueueUserInfoDownloadProgressKey];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:url] inSection:0];
        
        DownloadTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.progress.text = progress.localizedDescription;
        
    }];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DOWNLOADCELL_ID forIndexPath:indexPath];
    
    cell.delegate = self;
    NSString *urlString = [self.dataSource objectAtIndex:indexPath.row];
    cell.name.text = [[urlString componentsSeparatedByString:@"/"] lastObject];
    cell.URLString = urlString;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //后续在这里删除某个下载
        [self.controller deleteDownload:[self.dataSource objectAtIndex:indexPath.row]];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Event Method
//临时实用button的click 后续修改设计
- (IBAction)resumeAll:(id)sender {
    [self.controller startAllDownloads];
}

- (IBAction)pauseAll:(id)sender {
    [self.controller stopAllDownloads];
}

- (IBAction)deleteAll:(id)sender {
    [self.controller deleteAllDownloads];
    [self.tableView reloadData];
}

#pragma mark - DownloadCellDelegate Method
- (void)downloadCellStartDownload:(NSString *)URLString {
    [self.controller startDownload:URLString];
}

- (void)downloadCellStopDownload:(NSString *)URLString {
    [self.controller stopDownload:URLString];
}

- (void)downloadCellRestartDownload:(NSString *)URLString {
    [self.controller redownload:URLString];
}
@end
