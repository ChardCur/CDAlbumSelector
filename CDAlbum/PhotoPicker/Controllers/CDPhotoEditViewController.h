//
//  CDPhotoEditViewController.h
//  CDAlbum
//
//  Created by hlzq on 2022/3/16.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class CDPhotoEditViewController;
NS_ASSUME_NONNULL_BEGIN

@protocol CDPhotoEditViewControllerDelegate <NSObject>

- (void)editViewController:(CDPhotoEditViewController *)controller didEditImage:(UIImage *)image;

@end

@interface CDPhotoEditViewController : UIViewController

- (instancetype)initWithAsset:(PHAsset *)asset;

@property (nonatomic, weak) id<CDPhotoEditViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
