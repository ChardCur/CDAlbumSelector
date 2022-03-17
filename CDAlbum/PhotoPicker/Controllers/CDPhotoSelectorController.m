//
//  CDPhotoSelectorController.m
//  CDAlbum
//
//  Created by hlzq on 2022/3/14.
//

#import "CDPhotoSelectorController.h"
#import "CDAssetManager.h"
#import "CDPhotoSelectorCell.h"
#import "CDAlbumListView.h"
#import "CDAlbumTitleView.h"
#import "CDPhotoEditViewController.h"

static NSString *const photoSelectorCellId = @"cellId";
static CGFloat const itemSpace = 2;
static CGFloat const sectionSpace = 4;

@interface CDPhotoSelectorController () <UICollectionViewDataSource, UICollectionViewDelegate, CDPhotoEditViewControllerDelegate>

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *albums;
@property (nonatomic, strong) CDAlbumModel *albumModel;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CDAlbumListView *albumListView;
@property (nonatomic, strong) CDAlbumTitleView *titleView;

@end

@implementation CDPhotoSelectorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.collectionView];
    [self setupNavButton];
    
    [self fetchAlbums];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat ablumY = self.view.safeAreaInsets.top;
    self.albumListView.frame = CGRectMake(0, ablumY, self.view.frame.size.width, self.view.frame.size.height - ablumY);
}

- (void)dealloc {
    NSLog(@"dead");
}

- (void)fetchAlbums {
    [CDAssetManager fetchAllAlbumsCompletion:^(NSArray<CDAlbumModel *> * _Nonnull albums) {
        self.albums = albums;
        
        CDAlbumModel *aModel = albums[0];
        self.titleView.titleLabel.text = aModel.albumName;
        
        if (aModel.images.count) {
            self.images = aModel.images;
            [self.collectionView reloadData];
        }
        
        CGRect tmpRect = self.albumListView.frame;
        tmpRect.size.height = albumListCellHeight * albums.count;
        self.albumListView.frame = tmpRect;
        
        self.albumListView.dataArray = albums;
        self.albumModel = aModel;
    }];
}

#pragma mark - getter
- (NSArray *)images {
    if (!_images) {
        _images = [NSArray array];
    }
    return _images;
}

- (NSArray *)albums {
    if (!_albums) {
        _albums = [NSArray array];
    }
    return _albums;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(CGFLOAT_MIN, CGFLOAT_MIN);
        layout.minimumLineSpacing = itemSpace;
        layout.minimumInteritemSpacing = itemSpace;
        layout.sectionInset = UIEdgeInsetsMake(itemSpace, 0, 0, 0);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = YES;
        
        [_collectionView registerClass:[CDPhotoSelectorCell class] forCellWithReuseIdentifier:photoSelectorCellId];
    }
    return _collectionView;
}

#pragma mark - collectionview delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CDPhotoSelectorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:photoSelectorCellId forIndexPath:indexPath];
    cell.photoImageView.image = self.images[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"select %@", @(indexPath.item));
    PHAsset *asset = self.albumModel.assets[indexPath.item];
    CDPhotoEditViewController *editViewController = [[CDPhotoEditViewController alloc] initWithAsset:asset];
    editViewController.delegate = self;
    [self.navigationController pushViewController:editViewController animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (self.view.frame.size.width - itemSpace * 2 - sectionSpace * 2) / 3;
    return CGSizeMake(width, width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(sectionSpace, sectionSpace, sectionSpace, sectionSpace);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return itemSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return itemSpace;
}

#pragma mark - CDPhotoEditViewControllerDelegate
- (void)editViewController:(CDPhotoEditViewController *)controller didEditImage:(UIImage *)image {
    NSLog(@"image: %@", image);
    // 临时用下
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noty" object:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private
- (void)setupNavButton {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(handleCancel)];
    self.navigationItem.leftBarButtonItem = item;
    
    CDAlbumTitleView *titleView = [[CDAlbumTitleView alloc] initWithFrame:CGRectMake(0, 0, 100, 45) target:self action:@selector(titleViewClicked:)];
    self.navigationItem.titleView = titleView;
    self.titleView = titleView;
    
    CDAlbumListView *albumListView = [[CDAlbumListView alloc] initWithFrame:self.view.bounds];
    albumListView.associatedBtn = titleView.arrowButton;
    albumListView.associatedLabel = titleView.titleLabel;
    [self.view addSubview:albumListView];
    self.albumListView = albumListView;
    
    __weak typeof(self) weakSelf = self;
    self.albumListView.selectBlock = ^(NSInteger index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        CDAlbumModel *aModel = strongSelf.albums[index];
        strongSelf.images = aModel.images;
        [strongSelf.collectionView reloadData];
        strongSelf.albumModel = aModel;
    };
}

#pragma mark - actions
- (void)handleCancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)titleViewClicked:(UIButton *)button {
    if (!button.selected) {
        [self.albumListView show:^{ button.selected = YES; }];
    }else {
        [self.albumListView dismiss:^{ button.selected = NO; }];
    }
}

@end
