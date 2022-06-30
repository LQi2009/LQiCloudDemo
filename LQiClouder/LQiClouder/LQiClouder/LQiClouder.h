//
//  LQiClouder.h
//  LQiClouder
//
//  Created by NewTV on 2022/6/30.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface LQDocument : UIDocument

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSFileWrapper *wrapper;
@end

typedef void(^loadBlock)(BOOL success);

typedef void(^downloadBlock)(id obj);

@interface LQiClouder : NSObject

+ (BOOL)iCloudEnable;
+ (NSURL *)iCloudFilePathByName:(NSString *)name;
+ (NSURL *)localFileUrl:(NSString *)fileName;

+ (void)uploadToiCloud:(NSString *)name localFile:(NSString *)localFile callBack:(loadBlock)block ;

+ (void)downloadFromiCloud:(NSString*)name localfile:(NSString*)localFile callBack:(downloadBlock)block ;
@end

NS_ASSUME_NONNULL_END
