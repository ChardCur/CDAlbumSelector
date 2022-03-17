//
//  CDAlbumTitleView.m
//  CDAlbum
//
//  Created by hlzq on 2022/3/15.
//

#import "CDAlbumTitleView.h"

@implementation CDAlbumTitleView

- (instancetype)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UIButton *arrowButton = [[UIButton alloc] init];
        [arrowButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
        [arrowButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:arrowButton];
        self.arrowButton = arrowButton;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat btnW = 20;
    CGFloat titleW = self.frame.size.width - btnW;
    self.titleLabel.frame = CGRectMake(0, 0, titleW, self.frame.size.height);
    self.arrowButton.frame = CGRectMake(titleW, 0, btnW, self.frame.size.height);
}

@end
