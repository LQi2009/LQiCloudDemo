//
//  LZiCloudDocument.h
//  LZiCloudDemo
//
//  Created by Artron_LQQ on 2016/12/2.
//  Copyright © 2016年 Artup. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^loadBlock)(BOOL success);

typedef void(^downloadBlock)(id obj);

@interface LZiCloudDocument : NSObject

+ (BOOL)iCloudEnable;
+ (NSURL *)iCloudFilePathByName:(NSString *)name;
+ (NSURL *)localFileUrl:(NSString *)fileName;

+ (void)uploadToiCloud:(NSString *)name localFile:(NSString *)localFile callBack:(loadBlock)block ;

+ (void)downloadFromiCloud:(NSString*)name localfile:(NSString*)localFile callBack:(downloadBlock)block ;
@end
