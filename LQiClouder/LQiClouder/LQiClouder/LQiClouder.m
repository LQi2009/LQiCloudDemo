//
//  LQiClouder.m
//  LQiClouder
//
//  Created by NewTV on 2022/6/30.
//

#import "LQiClouder.h"

@implementation LQiClouder

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
    
    LQDocument *localDoc = [[LQDocument alloc]initWithFileURL:localUrl];
    LQDocument *iCloudDoc = [[LQDocument alloc]initWithFileURL:iCloudUrl];
    
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
    
    LQDocument *localDoc = [[LQDocument alloc]initWithFileURL:localUrl];
    LQDocument *iCloudDoc = [[LQDocument alloc]initWithFileURL:iCloudUrl];
    
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

static NSString *fileName = @"userData.db";
@implementation LQDocument

// 将要保存的数据转换为NSData
// 用于保存文件时提供给 UIDocument 要保存的数据，
- (id)contentsForType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError {
    
    NSLog(@"typeName == %@", typeName);
    
    if (self.wrapper == nil) {
        self.wrapper =[[NSFileWrapper alloc]initDirectoryWithFileWrappers:@{}];
    }
    
    NSDictionary *wrappers = [self.wrapper fileWrappers];
    
    if ([wrappers objectForKey:fileName] == nil && self.data != nil) {
        
        NSFileWrapper *textWrap = [[NSFileWrapper alloc]initRegularFileWithContents:self.data];
        [textWrap setPreferredFilename:fileName];
        [self.wrapper addFileWrapper:textWrap];
    }
    
    return self.wrapper;
}

// 获取已保存数据
// 用于 UIDocument 成功打开文件后，我们将数据解析成我们需要的文件内容，然后再保存起来
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError {
    
    // 这个NSFileWrapper对象是a parent
    self.wrapper = (NSFileWrapper*)contents;
    
    NSDictionary *fileWrappers = self.wrapper.fileWrappers;
    // 获取child fileWrapper 这里才能获取到我们保存的内容
    NSFileWrapper *textWrap = [fileWrappers objectForKey:fileName];
    
    // 获取保存的内容
    if (textWrap.regularFile) {
        
        self.data = textWrap.regularFileContents;
    }

    return YES;
}
@end
