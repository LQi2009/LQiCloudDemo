//
//  LQiCloudManager.h
//  LQiClouder
//
//  Created by NewTV on 2022/6/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^LQiCloudUploadHandler)(NSError *__nullable error);
typedef void(^LQiCloudDownloadHandler)(id __nullable obj);
@interface LQiCloudManager : NSObject

/// 设置使用容器ID
/// 即：Capabilities-->iCloud-->Containers中点击+新增的容器名称
/// 如果未设置，或设置为nil，则使用默认的容器
+ (void) configContainerIdentifier:(NSString *__nullable) containerID ;

/// iCloud 是否可用
+ (BOOL)iCloudEnable;

/**
 上传到iCloud方法

 @param file 需要保存的文件, 可为NSArray, NSDictionary, NSData 或文件路径或URL
 @param fileName 保存在iCloud的名称
 @param block 上传结果回调
 */
+ (void) upload:(id)file fileName:(NSString *)fileName complete:(LQiCloudUploadHandler)block;

/**
 上传iCloud的方法, 使用默认的文件名存储

 @param file 需要保存的文件, 可为数组, 字典,或已保存在本地的文件路径或名称
 @param block 上传结果回调
 */
+ (void) upload:(id)file complete:(LQiCloudUploadHandler)block;

/**
 从iCloud获取保存的文件
 
 @param name 保存在iCloud的文件名称
 @param block 结果回调
 */
+ (void) download:(NSString *)name complete:(LQiCloudDownloadHandler)block ;

/**
 从iCloud获取保存的文件，使用默认的文件名
 
 @param block 返回保存的文件,可能为数组,字典或NSData
 */
+ (void) downloadWithComplete:(LQiCloudDownloadHandler)block;
@end

NS_ASSUME_NONNULL_END
