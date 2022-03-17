//
//  CDAlbumModel.h
//  CDAlbum
//
//  Created by hlzq on 2022/3/15.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDAlbumModel : NSObject

/// 相册名称
@property (nonatomic, copy) NSString *albumName;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray<PHAsset *> *assets;

- (instancetype)initWithCollection:(PHAssetCollection *)collection;

@end

NS_ASSUME_NONNULL_END
