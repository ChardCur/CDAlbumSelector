//
//  CDAlbumModel.m
//  CDAlbum
//
//  Created by hlzq on 2022/3/15.
//

#import "CDAlbumModel.h"

@implementation CDAlbumModel

- (instancetype)initWithCollection:(PHAssetCollection *)collection {
    self = [super init];
    if (self) {
        self.albumName = collection.localizedTitle;
    }
    return self;
}

@end
