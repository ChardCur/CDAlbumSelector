//
//  CDAssetManager.h
//  CDAlbum
//
//  Created by hlzq on 2022/3/14.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "CDAlbumModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDAssetManager : NSObject

@property (nonatomic, strong) UIViewController *fromViewController;

+ (CDAssetManager *)shared;
- (void)checkPhotoAuthorization;
// 获取所有相册模型
+ (void)fetchAllAlbumsCompletion:(void(^)(NSArray<CDAlbumModel *> *albums))completion;

/// 异步请求 Asset 的展示图
/// @param targetSize 指定返回展示的大小
/// @param networkAccessAllowed 允许网络请求
/// @param progressHandler 存在iCloud上并且允许了网络请求才有回调，不在主线程上执行
/// @param completion 完成请求后调用的 block，只会回调一次
+ (PHImageRequestID)requestPreviewImageForAsset:(PHAsset *)asset
                                     targetSize:(CGSize)targetSize
                           networkAccessAllowed:(BOOL)networkAccessAllowed
                                progressHandler:(PHAssetImageProgressHandler _Nullable)progressHandler
                                     completion:(void (^ _Nullable)(UIImage *result, NSDictionary<NSString *, id> *info))completion;

@end

NS_ASSUME_NONNULL_END
