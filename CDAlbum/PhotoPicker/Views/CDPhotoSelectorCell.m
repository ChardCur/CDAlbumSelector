//
//  CDPhotoSelectorCell.m
//  CDAlbum
//
//  Created by hlzq on 2022/3/14.
//

#import "CDPhotoSelectorCell.h"

@implementation CDPhotoSelectorCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        
        UIImageView *photoImageView = [[UIImageView alloc] init];
        photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        photoImageView.layer.masksToBounds = YES;
        [self addSubview:photoImageView];
        self.photoImageView = photoImageView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.photoImageView.frame = self.bounds;
    self.titleLabel.frame = CGRectMake((self.frame.size.width - 100) * 0.5, (self.frame.size.height - 100) * 0.5, 100, 100);
}

@end
