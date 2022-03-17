//
//  CDPhotoEditViewController.m
//  CDAlbum
//
//  Created by hlzq on 2022/3/16.
//

#import "CDPhotoEditViewController.h"
#import "CDAssetManager.h"

@interface CDPhotoEditViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIVisualEffectView *effectView;

@property (nonatomic, assign) CGRect cropRect;

@end

@implementation CDPhotoEditViewController

- (instancetype)initWithAsset:(PHAsset *)asset {
    self = [super init];
    if (self) {
        self.asset = asset;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupNavButton];
    [self setupUI];
    [self fetchImage];
}

#pragma mark - ui
- (void)setupUI {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.delegate = self;
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.maximumZoomScale = 5;
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:imageView];
    self.imageView = imageView;
    
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    maskView.userInteractionEnabled = NO;
    maskView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:maskView];
    self.maskView = maskView;
    
    [self transparentCutRoundArea];
}

- (void)setupNavButton {
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 29)];
    doneButton.layer.cornerRadius = 2;
    doneButton.backgroundColor = [UIColor colorWithRed:239/255.0 green:64/255.0 blue:52/255.0 alpha:1.0];
    [doneButton setTitle:@"确定" forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [doneButton addTarget:self action:@selector(handleDone) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 29)];
    cancelButton.backgroundColor = [UIColor clearColor];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [cancelButton addTarget:self action:@selector(handlCancel) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self setTransparentNavigationUltimate];
}

#pragma mark - private
- (void)transparentCutRoundArea {
    CGFloat cropW = self.view.frame.size.width - 30;
    CGFloat cropY = (self.view.frame.size.height - cropW) * 0.5;
    CGRect cropRect = CGRectMake(15, cropY, cropW, cropW);
    self.cropRect = cropRect;
    
    CGFloat arcX = cropRect.origin.x + cropRect.size.width * 0.5;
    CGFloat arcY = cropRect.origin.y + cropRect.size.height * 0.5;
    
    CGFloat arcRadius = cropW * 0.5;
    
    //圆形透明区域
    UIBezierPath *alphaPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(arcX, arcY) radius:arcRadius startAngle:0 endAngle:2 * M_PI clockwise:NO];
    [alphaPath appendPath:arcPath];
    CAShapeLayer  *layer = [CAShapeLayer layer];
    layer.path = alphaPath.CGPath;
    layer.fillRule = kCAFillRuleEvenOdd;
    self.maskView.layer.mask = layer;
    
    //裁剪框
    UIBezierPath *cropPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(arcX, arcY) radius:arcRadius+1 startAngle:0 endAngle:2 * M_PI clockwise:NO];
    CAShapeLayer *cropLayer = [CAShapeLayer layer];
    cropLayer.path = cropPath.CGPath;
    cropLayer.strokeColor = [UIColor whiteColor].CGColor;
    cropLayer.fillColor = [UIColor whiteColor].CGColor;
    [self.maskView.layer addSublayer:cropLayer];
}

- (void)setTransparentNavigationUltimate {
    //navigation标题文字颜色
    NSDictionary *dic = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                          NSFontAttributeName : [UIFont systemFontOfSize:18]};
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *barApp = [UINavigationBarAppearance new];
        barApp.backgroundColor = [UIColor clearColor];
        barApp.titleTextAttributes = dic;
        barApp.backgroundEffect = nil;
        barApp.shadowColor = nil;
        self.navigationController.navigationBar.scrollEdgeAppearance = nil;
        self.navigationController.navigationBar.standardAppearance = barApp;
    }else{
        self.navigationController.navigationBar.titleTextAttributes = dic;
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    }
    //透明
    self.navigationController.navigationBar.translucent = YES;
    //navigation控件颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (UIImage *)getClipedImage {
    //图片大小和当前imageView的缩放比例
    CGFloat scaleRatio = _imageView.image.size.width / _imageView.frame.size.width ;
    //scrollView的缩放比例，即是ImageView的缩放比例
    CGFloat scrollScale = self.scrollView.zoomScale;
    //裁剪框的 左上、右上和左下三个点在初始ImageView上的坐标位置（注意：转换后的坐标为原始ImageView的坐标计算的，而非缩放后的）
    CGPoint leftTopPoint =  [self.view  convertPoint:_cropRect.origin toView:_imageView];
    CGPoint rightTopPoint = [self.view convertPoint:CGPointMake(_cropRect.origin.x + _cropRect.size.width, _cropRect.origin.y) toView:_imageView];
    CGPoint leftBottomPoint = [self.view convertPoint:CGPointMake(_cropRect.origin.x, _cropRect.origin.y + _cropRect.size.height) toView:_imageView];
    
    //计算三个点在缩放后imageView上的坐标
    leftTopPoint = CGPointMake(leftTopPoint.x * scrollScale, leftTopPoint.y*scrollScale);
    rightTopPoint = CGPointMake(rightTopPoint.x * scrollScale, rightTopPoint.y*scrollScale);
    leftBottomPoint = CGPointMake(leftBottomPoint.x * scrollScale, leftBottomPoint.y*scrollScale);
    
    //计算裁剪区域在原始图片上的位置
    CGFloat width = (rightTopPoint.x - leftTopPoint.x )* scaleRatio;
    CGFloat height = (leftBottomPoint.y - leftTopPoint.y) *scaleRatio;
    CGRect myImageRect = CGRectMake(leftTopPoint.x * scaleRatio, leftTopPoint.y*scaleRatio, width, height);
    
    //裁剪图片
    CGImageRef imageRef = self.imageView.image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    UIGraphicsBeginImageContextWithOptions(myImageRect.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, CGRectMake(0, 0, myImageRect.size.width, myImageRect.size.height), subImageRef);
    
    UIImage *clipedImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
//    //是否需要圆形图片
//    if (self.isRound) {
//        //将图片裁剪成圆形
//        subImage = [self clipCircularImage:subImage];
//    }
    return clipedImage;
}

- (void)addBlurOnMask {
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = self.maskView.bounds;
    self.effectView = effectView;
    
    [self.maskView addSubview:effectView];
    [self.maskView sendSubviewToBack:effectView];
}

- (void)removeBlurFromMask {
    [self.effectView removeFromSuperview];
}

#pragma mark - fetch image
- (void)fetchImage {
    CGSize targetSize = PHImageManagerMaximumSize;
    [CDAssetManager requestPreviewImageForAsset:self.asset targetSize:targetSize networkAccessAllowed:YES progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        
    } completion:^(UIImage * _Nonnull result, NSDictionary<NSString *,id> * _Nonnull info) {
        if (result) {
            self.imageView.image = result;
            // 设置imageView的frame
            CGFloat imageRatio = result.size.width / result.size.height;
            CGFloat viewH = self.view.frame.size.width / imageRatio;
            CGFloat viewW = self.view.frame.size.width;
            CGFloat viewY = (self.view.frame.size.height - viewH) * 0.5;
            self.imageView.frame = CGRectMake(0, viewY, viewW, viewH);
            CGFloat scale;
            if (imageRatio > 1) {
                scale = self.cropRect.size.height / viewH;
            }else {
                scale = self.cropRect.size.width / viewW;
            }
            self.scrollView.minimumZoomScale = scale;
            [self.scrollView setZoomScale:scale animated:YES];
        }
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //等比例放大图片以后，让放大后的ImageView保持在ScrollView的中央
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _imageView.center =CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,scrollView.contentSize.height * 0.5 + offsetY);

    //设置scrollView的contentSize，最小为self.view.frame
    CGFloat scrollW = (scrollView.contentSize.width >= self.view.frame.size.width) ? scrollView.contentSize.width : self.view.frame.size.width;
    CGFloat scrollH = (scrollView.contentSize.height >= self.view.frame.size.height) ? scrollView.contentSize.height : self.view.frame.size.height;
    [scrollView setContentSize:CGSizeMake(scrollW, scrollH)];
    
    //设置scrollView的contentInset
    CGFloat imageWidth = _imageView.frame.size.width;
    CGFloat imageHeight = _imageView.frame.size.height;
    CGFloat cropWidth = _cropRect.size.width;
    CGFloat cropHeight = _cropRect.size.height;
    
    CGFloat leftRightInset = 0.f,topBottomInset = 0.f;
    
    //imageview的大小和裁剪框大小的三种情况，保证imageview最多能滑动到裁剪框的边缘
    if (imageWidth <= cropWidth) {
        leftRightInset = 0;
    }else if (imageWidth >= cropWidth && imageWidth <= self.view.frame.size.width) {
        leftRightInset = (imageWidth - cropWidth) * 0.5;
    }else {
        leftRightInset = (self.view.frame.size.width - _cropRect.size.width) * 0.5;
    }
    
    if (imageHeight <= cropHeight) {
        topBottomInset = 0;
    }else if (imageHeight >= cropHeight && imageHeight <= self.view.frame.size.height) {
        topBottomInset = (imageHeight - cropHeight) * 0.5;
    }else {
        topBottomInset = (self.view.frame.size.height - _cropRect.size.height) * 0.5;
    }
    [self.scrollView setContentInset:UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset)];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeBlurFromMask];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self addBlurOnMask];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [self removeBlurFromMask];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self addBlurOnMask];
}

#pragma mark - actions
- (void)handleDone {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editViewController:didEditImage:)]) {
        [self.delegate editViewController:self didEditImage:[self getClipedImage]];
    }
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handlCancel {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
