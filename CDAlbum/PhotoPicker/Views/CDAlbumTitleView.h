//
//  CDAlbumTitleView.h
//  CDAlbum
//
//  Created by hlzq on 2022/3/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDAlbumTitleView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *arrowButton;

- (instancetype)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
