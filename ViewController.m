//
//  ViewController.m
//  LZiCloudDemo
//
//  Created by Artron_LQQ on 2016/12/1.
//  Copyright © 2016年 Artup. All rights reserved.
//

#import "ViewController.h"
#import "LZiCloud.h"

#import "LZDocument.h"
#import "LZiCloudDocument.h"

@interface ViewController ()
{
    UIImageView *imageView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *download = [UIButton buttonWithType:UIButtonTypeCustom];
    download.frame = CGRectMake(20, 40, 120, 40);
    download.backgroundColor = [UIColor greenColor];
    [download setTitle:@"从iCloud下载" forState:UIControlStateNormal];
    [download addTarget:self action:@selector(downloadBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:download];
    
    UIButton *upload = [UIButton buttonWithType:UIButtonTypeCustom];
    upload.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 140, 40, 120, 40);
    upload.backgroundColor = [UIColor greenColor];
    [upload setTitle:@"上传至iCloud" forState:UIControlStateNormal];
    [upload addTarget:self action:@selector(uploadBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:upload];
    
    
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 100, CGRectGetWidth(self.view.frame) - 20, 300)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:imageView];
    
    
    
    [self iCloudDocumentTest];
    
}

- (void)downloadBtn:(UIButton *)btn {
    
    [LZiCloudDocument downloadFromiCloud:@"userData" localfile:@"userData" callBack:^(NSData* obj) {
        
        imageView.image = [UIImage imageWithData:obj];
    }];
    
#pragma mark: LZiCloud
    
//    [LZiCloud downloadFromiCloudWithBlock:^(id obj) {
//        
//        UIImage *im = [UIImage imageWithData:obj];
//        imageView.image = im;
//    }];
}

- (void)uploadBtn:(UIButton *)btn {
    
    [LZiCloudDocument uploadToiCloud:@"userData" localFile:@"userData" callBack:^(BOOL success) {
        
                if (success) {
                    NSLog(@"success upload to iCloud");
                }
    }];
    
#pragma mark: LZiCloud
    
//    UIImage *img = [UIImage imageNamed:@"5fdf8db1cb134954979ddf0d564e9258d0094ad3.jpg"];
//    NSData *da = UIImageJPEGRepresentation(img, 1);
//        [LZiCloud uploadToiCloud:da resultBlock:^(NSError *error) {
//    
//            NSLog(@"%@",error);
//        }];
}

- (void)iCloudDocumentTest {
    
    UIImage *img = [UIImage imageNamed:@"5fdf8db1cb134954979ddf0d564e9258d0094ad3.jpg"];
    
    NSData *da = UIImageJPEGRepresentation(img, 1.0);
        LZDocument *doc = [[LZDocument alloc]initWithFileURL:[LZiCloudDocument localFileUrl:@"userData"]];
        doc.data =da;
        [doc saveToURL:[LZiCloudDocument localFileUrl:@"userData"] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"success");
            }
        }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
