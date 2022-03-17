//
//  ViewController.m
//  CDAlbum
//
//  Created by hlzq on 2022/3/14.
//

#import "ViewController.h"
#import "UIViewController+CDExtension.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNoty:) name:@"noty" object:nil];
}

- (void)getNoty:(NSNotification *)noty {
    UIImage *image = noty.object;
    self.imageView.image = image;
}

- (IBAction)clicked:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择" message:@"自己挑自己选" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self cd_presentPhotoSelectorViewController];
    }];
    [alert addAction:albumAction];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cameraAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
