//
//  CDAlbumListView.h
//  CDAlbum
//
//  Created by hlzq on 2022/3/15.
//

#import <UIKit/UIKit.h>

static CGFloat const albumListCellHeight = 50;

typedef void(^AlbumListViewSelectBlock)(NSInteger index);

@class CDAlbumListView;

NS_ASSUME_NONNULL_BEGIN

@interface CDAlbumListView : UIView

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UILabel *associatedLabel;// 关联文本视图
@property (nonatomic, strong) UIButton *associatedBtn;// 关联按钮
@property (nonatomic, copy) AlbumListViewSelectBlock selectBlock;

- (void)show:(void(^)(void))completion;
- (void)dismiss:(void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
