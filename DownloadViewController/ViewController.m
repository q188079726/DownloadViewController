//
//  ViewController.m
//  DownloadViewController
//
//  Created by 李硕 on 16/2/26.
//  Copyright © 2016年 李硕. All rights reserved.
//

#import "ViewController.h"
#import "DownloadQueueController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIProgressView *pro1;
@property (strong, nonatomic) IBOutlet UIProgressView *pro2;
@property (strong, nonatomic) IBOutlet UIProgressView *pro3;
@property (strong, nonatomic) IBOutlet UIProgressView *pro4;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserverForName:DownloadQueueDidSuccessDownloadNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"finish:%@",[note.userInfo objectForKey:DownloadQueueUserInfoDownloadURLStringKey]);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:DownloadQueueDidFailureDownloadNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"error:%@---%@",[note.userInfo objectForKey:DownloadQueueUserInfoDownloadURLStringKey],[note.userInfo objectForKey:DownloadQueueUserInfoDownloadErrorKey]);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:DownloadQueueWillRefreshProgressNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        NSString *url = [note.userInfo objectForKey:DownloadQueueUserInfoDownloadURLStringKey];
        NSProgress *progress = [note.userInfo objectForKey:DownloadQueueUserInfoDownloadProgressKey];
        if ([url isEqualToString:@"http://dldir1.qq.com/qqfile/qq/QQ8.1/17216/QQ8.1.exe"]) {
            //qq
            self.pro1.progress = progress.fractionCompleted;
            
        } else if ([url isEqualToString:@"http://dldir1.qq.com/music/clntupate/QQMusicForYQQ.exe"]) {
            //music
            self.pro2.progress = progress.fractionCompleted;
            
        } else if ([url isEqualToString:@"http://dl_dir2.qq.com/invc/xfspeed/qdesk/versetup/QDeskSetup_25_1277.exe"]) {
            //desk
            self.pro3.progress = progress.fractionCompleted;
            
        } else if ([url isEqualToString:@"http://dldir1.qq.com/invc/cyclone/QQDownload_Setup_48_773_400.exe"]) {
            //xuanfeng
            self.pro4.progress = progress.fractionCompleted;
        }
    }];
}


//    http://dl_dir2.qq.com/invc/xfspeed/qdesk/versetup/QDeskSetup_25_1277.exe
//    http://dldir1.qq.com/music/clntupate/QQMusicForYQQ.exe
//http://dldir1.qq.com/qqfile/qq/QQ8.1/17216/QQ8.1.exe

//    http://dldir1.qq.com/invc/cyclone/QQDownload_Setup_48_773_400.exe


- (IBAction)downloadQQ:(id)sender {
    [[DownloadQueueController sharedQueueController] startDownload:@"http://dldir1.qq.com/qqfile/qq/QQ8.1/17216/QQ8.1.exe"];
    
}
- (IBAction)stopQQ:(id)sender {
    [[DownloadQueueController sharedQueueController] stopDownload:@"http://dldir1.qq.com/qqfile/qq/QQ8.1/17216/QQ8.1.exe"];
}
- (IBAction)redownloadQQ:(id)sender {
    [[DownloadQueueController sharedQueueController] redownload:@"http://dldir1.qq.com/qqfile/qq/QQ8.1/17216/QQ8.1.exe"];
}



- (IBAction)downloadMusic:(id)sender {
    [[DownloadQueueController sharedQueueController] startDownload:@"http://dldir1.qq.com/music/clntupate/QQMusicForYQQ.exe"];
}
- (IBAction)stopMusic:(id)sender {
    [[DownloadQueueController sharedQueueController] stopDownload:@"http://dldir1.qq.com/music/clntupate/QQMusicForYQQ.exe"];
}
- (IBAction)redownMusic:(id)sender {
    [[DownloadQueueController sharedQueueController] redownload:@"http://dl_dir2.qq.com/invc/xfspeed/qdesk/versetup/QDeskSetup_25_1277.exe"];
}





- (IBAction)downloadDesk:(id)sender {
    [[DownloadQueueController sharedQueueController] startDownload:@"http://dl_dir2.qq.com/invc/xfspeed/qdesk/versetup/QDeskSetup_25_1277.exe"];
}
- (IBAction)stopDesk:(id)sender {
    [[DownloadQueueController sharedQueueController] stopDownload:@"http://dl_dir2.qq.com/invc/xfspeed/qdesk/versetup/QDeskSetup_25_1277.exe"];
}
- (IBAction)redownDesk:(id)sender {
    [[DownloadQueueController sharedQueueController] redownload:@"http://dl_dir2.qq.com/invc/xfspeed/qdesk/versetup/QDeskSetup_25_1277.exe"];
}




- (IBAction)downloadxuanfeng:(id)sender {
    [[DownloadQueueController sharedQueueController] startDownload:@"http://dldir1.qq.com/invc/cyclone/QQDownload_Setup_48_773_400.exe"];
}
- (IBAction)stopxuanfeng:(id)sender {
    [[DownloadQueueController sharedQueueController] stopDownload:@"http://dldir1.qq.com/invc/cyclone/QQDownload_Setup_48_773_400.exe"];
}
- (IBAction)redownxuanfeng:(id)sender {
    [[DownloadQueueController sharedQueueController] redownload:@"http://dldir1.qq.com/invc/cyclone/QQDownload_Setup_48_773_400.exe"];

}




- (IBAction)gotoDownloadManager:(id)sender {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"DownloadViewController"] animated:YES];
}

@end
