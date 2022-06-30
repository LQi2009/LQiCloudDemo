//
//  LQiCloudManager.m
//  LQiClouder
//
//  Created by NewTV on 2022/6/30.
//

#import "LQiCloudManager.h"

static NSString *__containerIdentifier = nil;
#define LQiCloudDefaulteFileName @"defaulteFileData"
#define LQiCloudErrorDomain @"LQiCloudErrorDomain"
#define LQiCloudTempDataName @"iCloudTemp.data"

@implementation LQiCloudManager

+ (void) configContainerIdentifier:(NSString *__nullable) containerID {
    __containerIdentifier = containerID;
}

+ (BOOL)iCloudEnable {
    
    // 获得文件管理器
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // 判断iCloud是否可用
    // 参数传nil表示使用默认容器
    NSURL *url = [manager URLForUbiquityContainerIdentifier:__containerIdentifier];
    // 如果URL不为nil, 则表示可用
    if (url != nil) {
        
        return YES;
    }
    
    NSLog(@"iCloud 不可用");
    return NO;
}

+ (void) upload:(id)file complete:(LQiCloudUploadHandler)block {
    
    [self upload:file fileName:LQiCloudDefaulteFileName complete:block];
    
}

+ (void) upload:(id)file fileName:(NSString *)fileName complete:(LQiCloudUploadHandler)block {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        if ([file isKindOfClass:[NSData class]]) {
            [self _uploadData:file fileName:fileName complete:block];
        } else if ([NSJSONSerialization isValidJSONObject:file]) {
            // NSArray、NSDictionary 等JSON对象
            NSError *error = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:file options:0 error:&error];
            if (data && !error) {
                [self _uploadData:data fileName:fileName complete:block];
            } else {
                NSError *error = [NSError errorWithDomain:LQiCloudErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"获取存储数据失败，请检查文件是否可用"}];
                if (block) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(error);
                    });
                }
            }
        } else if ([file isKindOfClass:[NSURL class]]) {
            NSData *data = [NSData dataWithContentsOfURL:file];
            if (data) {
                [self _uploadData:data fileName:fileName complete:block];
            } else {
                NSError *error = [NSError errorWithDomain:LQiCloudErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"获取存储数据失败，请检查文件是否可用"}];
                if (block) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(error);
                    });
                }
            }
        } else if ([file isKindOfClass:[NSString class]]) {
            
            NSData *data = [NSData dataWithContentsOfFile:file];
            if (!data) {
                NSString *str = (NSString *)file;
                data = [str dataUsingEncoding:NSUTF8StringEncoding];
            }
            
            if (data) {
                [self _uploadData:data fileName:fileName complete:block];
            } else {
                NSError *error = [NSError errorWithDomain:LQiCloudErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"获取存储数据失败，请检查文件是否可用"}];
                if (block) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(error);
                    });
                }
            }
        } else {
            NSError *error = [NSError errorWithDomain:LQiCloudErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"不支持的数据类型"}];
            if (block) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(error);
                });
            }
        }
    });
}

// private method
+ (void) _uploadData:(NSData *) data fileName:(NSString *)fileName complete:(LQiCloudUploadHandler)block {
    
    if (!data) {
        NSError *error = [NSError errorWithDomain:LQiCloudErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"获取存储数据失败，请检查文件是否可用"}];
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
        return;
    }
    
    NSURL *iCloudUrl = [self iCloudFileURLWithName:fileName];
    if (!iCloudUrl) {
        
        NSError *error = [NSError errorWithDomain:LQiCloudErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"获取iCloud存储路径失败，请检查文件名称或者iCloud是否可用"}];
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
        return;
    }
    
    NSFileManager *manager  = [NSFileManager defaultManager];
    
    // 判断iCloud里该文件是否存在
    if ([manager isUbiquitousItemAtURL:iCloudUrl]) {
        
        NSError *error = nil;
        [data writeToURL:iCloudUrl options:NSDataWritingAtomic error:&error];
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
        return;
    }
    
    NSString *localPath = [self localFilePathWithName:LQiCloudTempDataName];
    
    [data writeToFile:localPath atomically:YES];
    
    if (![manager fileExistsAtPath:localPath]) {
        NSError *error = [NSError errorWithDomain:LQiCloudErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"文件写入本地失败，请检查数据后重试"}];
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
        return;
    }
    
    NSURL *localURL = [NSURL fileURLWithPath:localPath];
    
    NSError *error = nil;
    [manager setUbiquitous:YES itemAtURL:localURL destinationURL:iCloudUrl error:&error];
    [manager removeItemAtURL:localURL error:nil];
    
    if (block) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error);
        });
    }
}

+ (void) downloadWithComplete:(LQiCloudDownloadHandler)block {
    
    [self download:LQiCloudDefaulteFileName complete:block];
}

+ (void) download:(NSString *)name complete:(LQiCloudDownloadHandler)block {
    
    NSURL *iCloudUrl = [self iCloudFileURLWithName:name];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        if ([self downloadFileIfNotAvailable:iCloudUrl]) {
            
            // 先尝试转为数组
            NSArray *array = [[NSArray alloc]initWithContentsOfURL:iCloudUrl];
            
            if (array != nil) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    block(array);
                });
                
            } else {
                
                // 如果数组为nil, 再尝试转为字典
                NSDictionary *dic = [[NSDictionary alloc]initWithContentsOfURL:iCloudUrl];
                if (dic != nil) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        block(dic);
                    });
                } else {
                    // 如果字典为nil, 最后尝试转为NSData
                    NSData *data = [[NSData alloc]initWithContentsOfURL:iCloudUrl];
                    if (data != nil) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            block(data);
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            block(nil);
                        });
                    }
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                block(nil);
            });
        }
    });
}

// // 此方法是官方文档提供,用来检查文件状态并下载
+ (BOOL)downloadFileIfNotAvailable:(NSURL*)file {
    NSNumber*  isIniCloud = nil;
    
    if ([file getResourceValue:&isIniCloud forKey:NSURLIsUbiquitousItemKey error:nil]) {
        // If the item is in iCloud, see if it is downloaded.
        if ([isIniCloud boolValue]) {
            NSNumber*  isDownloaded = nil;
            if ([file getResourceValue:&isDownloaded forKey:NSURLUbiquitousItemDownloadingStatusKey error:nil]) {
                if ([isDownloaded boolValue])
                    return YES;
                
                // Download the file.
                NSFileManager*  fm = [NSFileManager defaultManager];
                if (![fm startDownloadingUbiquitousItemAtURL:file error:nil]) {
                    return NO;
                }
                return YES;
            }
        }
    }
    
    // Return YES as long as an explicit download was not started.
    return YES;
}

- (BOOL)downLoadData:(NSURL *)fileURL{
    
    NSNumber *isInCloud = nil;
    if ([fileURL getResourceValue:&isInCloud forKey:NSURLIsUbiquitousItemKey error:nil]){
        if ([isInCloud boolValue]) {
            NSNumber *isDownloaded = nil;
            if ([fileURL getResourceValue:&isDownloaded forKey:NSURLUbiquitousItemDownloadingStatusKey error:nil]){
                if ([isDownloaded boolValue]){
                    return YES;
                }
                NSError *error = nil;
                if([[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:fileURL error:&error]){
                    isDownloaded = nil;
                    [fileURL getResourceValue:&isDownloaded forKey:NSURLUbiquitousItemDownloadingStatusKey error:nil];
                    if([isDownloaded isEqual:NSURLUbiquitousItemDownloadingStatusNotDownloaded]){
                        return NO;
                    }
                }
            }
        }
    }
    return YES;
}

+ (NSURL *)iCloudFileURLWithName:(NSString *)name {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // 判断iCloud是否可用
    // 参数传nil表示使用默认容器
    NSURL *url = [manager URLForUbiquityContainerIdentifier:__containerIdentifier];
    
    if (url == nil) {
        
        return nil;
    }
    
    url = [url URLByAppendingPathComponent:@"Documents"];
    NSURL *iCloudPath = [NSURL URLWithString:name relativeToURL:url];
    
    return iCloudPath;
}

+ (NSString *)localFilePathWithName:(NSString *)name {
    
    // 得到本程序沙盒路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:name];
    
    return filePath;
}
@end
