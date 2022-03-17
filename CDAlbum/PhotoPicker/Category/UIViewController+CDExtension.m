//
//  UIViewController+CDExtension.m
//  CDAlbum
//
//  Created by hlzq on 2022/3/16.
//

#import "UIViewController+CDExtension.h"
#import "CDAssetManager.h"

@implementation UIViewController (CDExtension)

- (void)cd_presentPhotoSelectorViewController {
    [CDAssetManager shared].fromViewController = self;
    [[CDAssetManager shared] checkPhotoAuthorization];
}

@end
