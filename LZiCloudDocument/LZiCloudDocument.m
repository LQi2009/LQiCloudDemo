//
//  LZiCloudDocument.m
//  LZiCloudDemo
//
//  Created by Artron_LQQ on 2016/12/2.
//  Copyright © 2016年 Artup. All rights reserved.
//

#import "LZiCloudDocument.h"
#import "LZDocument.h"

@implementation LZiCloudDocument

+ (BOOL)iCloudEnable {
    
    // 获得文件管理器
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // 判断iCloud是否可用
    // 参数传nil表示使用默认容器
    NSURL *url = [manager URLForUbiquityContainerIdentifier:nil];
    // 如果URL不为nil, 则表示可用
    if (url != nil) {
        
        return YES;
    }
    
    NSLog(@"iCloud 不可用");
    return NO;
}


+ (NSURL *)iCloudFilePathByName:(NSString *)name {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // 判断iCloud是否可用
    // 参数传nil表示使用默认容器
    NSURL *url = [manager URLForUbiquityContainerIdentifier:nil];
    
    if (url == nil) {
        
        return nil;
    }
    
    url = [url URLByAppendingPathComponent:@"Documents"];
    NSURL *iCloudPath = [NSURL URLWithString:name relativeToURL:url];
    
    return iCloudPath;
}

// 本地的文件路径生成URL
+ (NSURL *)localFileUrl:(NSString *)fileName {
    
    // 获取Documents目录
    NSURL *fileUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    // 拼接文件名称
    NSURL *url = [fileUrl URLByAppendingPathComponent:fileName];
    NSLog(@"%@", url);
    return url;
}

+ (void)uploadToiCloud:(NSString *)name localFile:(NSString *)localFile callBack:(loadBlock)block {
    
    NSURL *iCloudUrl = [self iCloudFilePathByName:name];
    NSURL *localUrl = [self localFileUrl:localFile];
    
    LZDocument *localDoc = [[LZDocument alloc]initWithFileURL:localUrl];
    LZDocument *iCloudDoc = [[LZDocument alloc]initWithFileURL:iCloudUrl];
    
    [localDoc openWithCompletionHandler:^(BOOL success) {
        if (success) {
            
            iCloudDoc.data = localDoc.data;
            [iCloudDoc saveToURL:iCloudUrl forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                
                [localDoc closeWithCompletionHandler:^(BOOL success) {
                    NSLog(@"关闭成功");
                }];
                NSLog(@">>>>> %@",[NSThread currentThread]);
                
                if (block) {
                    block(success);
                }
            }];
        }
    }];
}

+ (void)downloadFromiCloud:(NSString*)name localfile:(NSString*)localFile callBack:(downloadBlock)block {
    
    NSURL *iCloudUrl = [self iCloudFilePathByName:name];
    NSURL *localUrl = [self localFileUrl:localFile];
    
    LZDocument *localDoc = [[LZDocument alloc]initWithFileURL:localUrl];
    LZDocument *iCloudDoc = [[LZDocument alloc]initWithFileURL:iCloudUrl];
    
    [iCloudDoc openWithCompletionHandler:^(BOOL success) {
        if (success) {
            
            localDoc.data = iCloudDoc.data;
            [localDoc saveToURL:localUrl forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                
                [iCloudDoc closeWithCompletionHandler:^(BOOL success) {
                    NSLog(@"关闭成功");
                }];
                
                if (block) {
                    block(localDoc.data);
                }
            }];
        }
    }];
}
@end
