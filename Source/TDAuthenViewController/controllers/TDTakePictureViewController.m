//
//  TDTakePictureViewController.m
//  edX
//
//  Created by Ben on 2017/4/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDTakePictureViewController.h"
#import "TDUserInformationViewController.h"
#import "TDCutImageViewController.h"

#import "TDTakePitureView.h"
#import "UIImage+Crop.h"
#import "NSString+OEXFormatting.h"

@interface TDTakePictureViewController () <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) TDTakePitureView *authenPhotoView;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) UIImagePickerController *imagePicker;

@end

@implementation TDTakePictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    self.titleViewLabel.text = TDLocalizeSelect(@"AUTHENTICATION_MESSAGE", nil);
    
    [self setViewConstraint];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - 选取相片
- (void)selectWayToGetPhoto {
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront; //前置
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGFloat height = image.size.height * (TDWidth / image.size.width);
    UIImage *orImage = [image resizeImageWithSize:CGSizeMake(TDWidth, height)];
    
    //截图页面
    TDCutImageViewController *cutViewController = [[TDCutImageViewController alloc] initWithImage:orImage delegate:self];
    cutViewController.ovalClip = NO;
    cutViewController.whereFrom = TDPhotoCutFromAuthen;
    [self.navigationController pushViewController:cutViewController animated:YES];
    
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil]; //退回imagePicker
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- CropImageDelegate
- (void)cropImageDidFinishedWithImage:(UIImage *)image {
    self.image = image;
    self.authenPhotoView.imageView.image = image;
    [self finishTakePhoto];
}

#pragma mark - 拍照完成
- (void)finishTakePhoto {
    self.authenPhotoView.imageButton.hidden = YES;
    self.authenPhotoView.buttonView.userInteractionEnabled = YES;
    self.authenPhotoView.resetButton.alpha = 1;
    self.authenPhotoView.nextButton.alpha = 1;
}

#pragma mark - action
- (void)imageButtonAction:(UIButton *)sender { //拍照
    TDBaseToolModel *model = [[TDBaseToolModel alloc] init];
    BOOL isAuthen = [model judgeCameraOrAlbumUserAllow:1];
    
    isAuthen ? [self selectWayToGetPhoto] : [self showAlertView:1];
}

- (void)showAlertView:(NSInteger)type {
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDic));
    NSString *appName = infoDic[@"CFBundleDisplayName"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:TDLocalizeSelect(@"SYSTEM_WARING", nil)
                                                        message:[TDLocalizeSelect(@"ALLOW_USE_CAMERA_TEXT", nil) oex_formatWithParameters:@{@"name": appName}]
                                                       delegate:self
                                              cancelButtonTitle:TDLocalizeSelect(@"CANCEL", nil)
                                              otherButtonTitles:TDLocalizeSelect(@"OK", nil), nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self gotoPhoneSystemSetting];
    }
}

- (void)gotoPhoneSystemSetting {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)resetButtonAction:(UIButton *)sender { //重拍
    [self selectWayToGetPhoto];
}

- (void)nextButtonAction:(UIButton *)sender { //下一步
    
    if (self.whereFrom == TDAuthenFromProfile) {
        TDTakePictureViewController *secondView = [[TDTakePictureViewController alloc] init];
        secondView.whereFrom = TDAuthenFromPhoto;
        secondView.faceImage = self.image;
        secondView.username = self.username;
        [self.navigationController pushViewController:secondView animated:YES];
        
    } else {
        TDUserInformationViewController *thirdView = [[TDUserInformationViewController alloc] init];
        thirdView.username = self.username;
        thirdView.faceImage = self.faceImage;
        thirdView.identifyImage = self.authenPhotoView.imageView.image;
        [self.navigationController pushViewController:thirdView animated:YES];
    }
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.authenPhotoView = [[TDTakePitureView alloc] init];
    self.authenPhotoView.type = self.whereFrom == TDAuthenFromProfile ? TDPhotoTypeFace : TDPhotoTypeIdentify;
    [self.authenPhotoView.imageButton addTarget:self action:@selector(imageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.authenPhotoView.resetButton addTarget:self action:@selector(resetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.authenPhotoView.nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.authenPhotoView];
    
    [self.authenPhotoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}

#pragma mark - UIStatusBarStyle
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
