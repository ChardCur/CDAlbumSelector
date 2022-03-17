//
//  CDPhotoSelectorController.h
//  CDAlbum
//
//  Created by hlzq on 2022/3/14.
//

#import <UIKit/UIKit.h>

typedef void(^didEditImageBlock)(UIImage * _Nullable editImage);

NS_ASSUME_NONNULL_BEGIN

@interface CDPhotoSelectorController : UIViewController

@property (nonatomic, copy) didEditImageBlock editCompletion;

@end

NS_ASSUME_NONNULL_END
