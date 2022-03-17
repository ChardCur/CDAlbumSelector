//
//  CDAlbumListView.m
//  CDAlbum
//
//  Created by hlzq on 2022/3/15.
//

#import "CDAlbumListView.h"
#import "CDAlbumListCell.h"
#import "CDAlbumModel.h"

@interface CDAlbumListView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *backView;

@end

@implementation CDAlbumListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = [UIColor lightGrayColor];
        backView.alpha = 0;
        [backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewTaped)]];
        [self addSubview:backView];
        self.backView = backView;
        
        [self addSubview:self.tableView];
        
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backView.frame = self.bounds;
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.alpha = 0;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
#else
            if ((NO)) {
#endif
            }
        [_tableView registerClass:[CDAlbumListCell class] forCellReuseIdentifier:NSStringFromClass([CDAlbumListCell class])];
    }
    return _tableView;
}
    
#pragma mark - setter
- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, albumListCellHeight * dataArray.count);
    [self.tableView reloadData];
}
    
#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CDAlbumListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CDAlbumListCell class])];
    CDAlbumModel *model = self.dataArray[indexPath.row];
    cell.textLabel.text = model.albumName;
    return cell;
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectBlock) self.selectBlock(indexPath.row);
    [self dismiss:^{ if (self.associatedBtn) self.associatedBtn.selected = NO; }];
    if (self.associatedLabel) {
        CDAlbumModel *aModel = self.dataArray[indexPath.row];
        self.associatedLabel.text = aModel.albumName;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return albumListCellHeight;
}
    
#pragma mark - actions
- (void)backViewTaped {
    [self dismiss:^{ if (self.associatedBtn) self.associatedBtn.selected = NO; }];
}
    
#pragma mark - public
- (void)show:(void (^)(void))completion {
    self.hidden = NO;
    
    CGRect tmpRect = self.tableView.frame;
    tmpRect.origin.y = - albumListCellHeight * self.dataArray.count;
    self.tableView.frame = tmpRect;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backView.alpha = 1;
        self.tableView.alpha = 1;
        
        CGRect tmpRect = self.tableView.frame;
        tmpRect.origin.y = 0;
        self.tableView.frame = tmpRect;
        
    } completion:^(BOOL finished) {
        if (completion) completion();
    }];
}

- (void)dismiss:(void (^)(void))completion {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backView.alpha = 0;
        self.tableView.alpha = 0;
        
        CGRect tmpRect = self.tableView.frame;
        tmpRect.origin.y = - albumListCellHeight * self.dataArray.count;
        self.tableView.frame = tmpRect;
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
        if (completion) completion();
    }];
}

@end
