//
//  CDAssetManager.m
//  CDAlbum
//
//  Created by hlzq on 2022/3/14.
//

#import "CDAssetManager.h"
#import "CDPhotoNavigationController.h"
#import "CDPhotoSelectorController.h"

@interface CDAssetManager ()

@property (nonatomic, strong) PHFetchOptions *fetchOptions;

@end

@implementation CDAssetManager

+ (CDAssetManager *)shared {
    static CDAssetManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CDAssetManager alloc] init];
    });
    return manager;
}

- (void)checkPhotoAuthorization {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                [self presentCustomNavigationController];
                break;
            case PHAuthorizationStatusDenied || PHAuthorizationStatusRestricted:
                [self showAlert];
                break;
            default:
                break;
        }
    }];
}

- (void)showAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"相册未授权, 前往设置进行授权" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }];
        [alert addAction:cancelAction];
        [alert addAction:setAction];
    });
}

- (void)presentCustomNavigationController {
    dispatch_async(dispatch_get_main_queue(), ^{
        CDPhotoSelectorController *vc = [[CDPhotoSelectorController alloc] init];
        CDPhotoNavigationController *nav = [[CDPhotoNavigationController alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        nav.modalPresentationCapturesStatusBarAppearance = YES;
        [self.fromViewController presentViewController:nav animated:YES completion:nil];
    });
}

#pragma mark - getter
- (PHFetchOptions *)fetchOptions {
    if (!_fetchOptions) {
        _fetchOptions = [[PHFetchOptions alloc] init];
        _fetchOptions.fetchLimit = 30;
        _fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    }
    return _fetchOptions;
}

#pragma mark - loadData
+ (void)fetchAllAlbumsCompletion:(void(^)(NSArray<CDAlbumModel *> *albums))completion {
    PHFetchOptions *fetchOptions = [CDAssetManager shared].fetchOptions;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *tmp = [NSMutableArray array];
//        NSLog(@"begin");
        [self enumerateAllAlbumsWithOptions:nil usingBlock:^(PHAssetCollection *collection) {
            PHFetchResult *albumPhotos = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
            if (albumPhotos.count) {
                CDAlbumModel *aModel = [[CDAlbumModel alloc] initWithCollection:collection];
                NSMutableArray *tmpImages = [NSMutableArray array];
                NSMutableArray *tmpAssets = [NSMutableArray array];
                [albumPhotos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CGSize targetSize = CGSizeMake(100, 100);
                    PHImageRequestOptions *reqOption = [[PHImageRequestOptions alloc] init];
                    reqOption.synchronous = YES;
                    [[PHImageManager defaultManager] requestImageForAsset:obj targetSize:targetSize contentMode:PHImageContentModeAspectFill options:reqOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//                        NSLog(@" --album enum-- %@", @(idx));
                        if (result) {
                            [tmpImages addObject:result];
                            [tmpAssets addObject:(PHAsset *)obj];
                        }
                        if (idx == albumPhotos.count - 1) {
                            aModel.images = tmpImages.copy;
                            aModel.assets = tmpAssets.copy;
                        }
                    }];
                }];
                [tmp addObject:aModel];
            }
//            NSLog(@"end");
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(tmp.copy);
//                NSLog(@"complete");
            }
        });
    });
}

#pragma mark - asset func
/// 获取智能相册
+ (PHFetchResult<PHAssetCollection *> *)fetchSmartAlbumsWithOptions:(PHFetchOptions * _Nullable)options {
    return [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:options];
}

/// 获取用户创建的相册
+ (PHFetchResult<PHAssetCollection *> *)fetchUserAlbumsWithOptions:(PHFetchOptions * _Nullable)options {
    return [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:options];
}

/// 获取所有相册
+ (void)enumerateAllAlbumsWithOptions:(PHFetchOptions * _Nullable)options
                           usingBlock:(void (^)(PHAssetCollection *collection))enumerationBlock {
    PHFetchResult *smartAlbums = [self fetchSmartAlbumsWithOptions:options];
    PHFetchResult *userAlbums = [self fetchUserAlbumsWithOptions:options];
    NSArray *allAlbum = [NSArray arrayWithObjects:smartAlbums, userAlbums, nil];
    for (PHFetchResult *result in allAlbum) {
        for (PHAssetCollection *collection in result) {
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            if (collection.estimatedAssetCount <= 0) continue;
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) continue;
            if (collection.assetCollectionSubtype == 215) continue;
            if (collection.assetCollectionSubtype == 212) continue;
            if (collection.assetCollectionSubtype == 204) continue;
            if (collection.assetCollectionSubtype == 1000000201) continue;
            if (enumerationBlock) {
                enumerationBlock(collection);
            }
        }
    }
}

/// 请求获取image
/// @param asset 需要获取的资源
/// @param targetSize 指定返回的大小
/// @param contentMode 内容模式
/// @param options 选项
/// @param completion 完成请求后调用的 block
+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset
                              targetSize:(CGSize)targetSize
                             contentMode:(PHImageContentMode)contentMode
                                 options:(PHImageRequestOptions *)options
                              completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion {
    if (!asset) {
        completion(nil, nil);
        return -1;
    }
    return [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:contentMode options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result, info);
            });
        }
    }];
}

/// 异步请求 Asset 的展示图
/// @param targetSize 指定返回展示的大小
/// @param networkAccessAllowed 允许网络请求
/// @param progressHandler 存在iCloud上并且允许了网络请求才有回调，不在主线程上执行
/// @param completion 完成请求后调用的 block，只会回调一次
+ (PHImageRequestID)requestPreviewImageForAsset:(PHAsset *)asset
                                     targetSize:(CGSize)targetSize
                           networkAccessAllowed:(BOOL)networkAccessAllowed
                                progressHandler:(PHAssetImageProgressHandler _Nullable)progressHandler
                                     completion:(void (^ _Nullable)(UIImage *result, NSDictionary<NSString *, id> *info))completion {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = networkAccessAllowed;
    options.progressHandler = progressHandler;
    return [self requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options completion:^(UIImage * _Nonnull result, NSDictionary<NSString *,id> * _Nonnull info) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result, info);
            });
        }
    }];
}

@end
