//
//  TDCutImageViewController.m
//  edX
//
//  Created by Elite Edu on 17/2/16.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDCutImageViewController.h"
#import "UIImage+Crop.h"

@interface TDCutImageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIImage * originalImage;

@end

@implementation TDCutImageViewController

- (instancetype)initWithImage:(UIImage *)originalImage delegate:(id)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.originalImage = originalImage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configView];
    [self userInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - UI
- (void)configView {
    
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat height = (TDHeight - TDWidth)/2.0;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, height ,TDWidth,TDWidth)];
    
    self.scrollView.bouncesZoom = YES;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 3;
    self.scrollView.zoomScale = 1;
    self.scrollView.delegate = self;
    
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    self.scrollView.layer.masksToBounds = NO;
    self.scrollView.layer.borderWidth = 1.5;
    self.scrollView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    if (self.ovalClip) {
        self.scrollView.layer.cornerRadius = TDWidth / 2.0; //是scrollView变为圆形的
    }
    
    self.view.layer.masksToBounds = YES;
    if (self.originalImage) {
        
        self.imageView = [[UIImageView alloc] initWithImage:self.originalImage];
        CGFloat imageHeight = self.originalImage.size.height * (TDWidth / self.originalImage.size.width);
        CGFloat imageWidth = TDWidth;
        
        if (imageHeight < TDWidth) {
            imageHeight = TDWidth;
            imageWidth = (self.originalImage.size.width / self.originalImage.size.height) * TDWidth;
        }
        self.imageView.frame = CGRectMake(0,0, imageWidth, imageHeight);
        self.imageView.userInteractionEnabled = YES;
        [self.scrollView addSubview:self.imageView];
        
        CGFloat imageY = (imageHeight - self.view.bounds.size.width) / 2.0;
        self.scrollView.contentSize = CGSizeMake(imageWidth, imageHeight);
        self.scrollView.contentOffset = CGPointMake(0, imageY);
        [self.view addSubview:self.scrollView];
    }
}

- (void)userInterface {
    
    CGRect cropframe = self.scrollView.frame;
    
    //贝塞尔曲线
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds cornerRadius:0];
    UIBezierPath *cropPath = [UIBezierPath bezierPathWithRoundedRect:cropframe cornerRadius:0];
    
    if (self.ovalClip) {
        cropPath = [UIBezierPath bezierPathWithOvalInRect:cropframe];
    }
    [path appendPath:cropPath];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor colorWithRed:.0 green:.0 blue:.0 alpha:0.5].CGColor;
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.path = path.CGPath;
    [self.view.layer addSublayer:layer]; //框
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 46, self.view.bounds.size.width, 46)];
    view.backgroundColor = [UIColor colorWithRed:30 / 255.0 green:30 / 255.0 blue:30 / 255.0 alpha:0.7];
    [self.view addSubview:view];
    
    UIButton * canncelBtn = [self setButtonConstrant:TDLocalizeSelect(@"CANCEL", nil)];
    canncelBtn.frame = CGRectMake(0, 0, 60, 44);
    [canncelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:canncelBtn];
    
    UIButton *doneBtn = [self setButtonConstrant:TDLocalizeSelect(@"DONE", nil)];
    doneBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 0, 60, 44);
    [doneBtn addTarget:self action:@selector(doneBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:doneBtn];
}

- (UIButton *)setButtonConstrant:(NSString *)title {
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [doneBtn setTitle:title forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return doneBtn;
}

#pragma mark -- UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //调整位置
    CGRect imageViewFrame = self.imageView.frame;
    
    CGRect scrollBounds = CGRectMake(0, 0, TDWidth, TDWidth);
    
    if (imageViewFrame.size.height > scrollBounds.size.height) {
        imageViewFrame.origin.y = 0.0f;
    } else {
        imageViewFrame.origin.y = (scrollBounds.size.height - imageViewFrame.size.height) / 2.0;
    }
    
    if (imageViewFrame.size.width < scrollBounds.size.width) {
        imageViewFrame.origin.x = (scrollBounds.size.width - imageViewFrame.size.width) /2.0;
    } else {
        imageViewFrame.origin.x = 0.0f;
    }
    
    self.imageView.frame = imageViewFrame;
}

- (UIImage *)cropImage {
    
    CGPoint offset = self.scrollView.contentOffset;
    CGFloat zoom = self.imageView.frame.size.width / self.originalImage.size.width; //图片缩放比例
    zoom = zoom / [UIScreen mainScreen].scale; //视网膜屏幕倍数相关
    
    CGFloat width = self.scrollView.frame.size.width;
    CGFloat height = self.scrollView.frame.size.height;
    if (self.imageView.frame.size.height < self.scrollView.frame.size.height) { //太胖了,取中间部分
        offset = CGPointMake(offset.x + (width - self.imageView.frame.size.height) / 2.0, 0);
        width = height = self.imageView.frame.size.height;
    }
    
    CGRect rect = CGRectMake(offset.x / zoom, offset.y / zoom, width / zoom, height / zoom);
    CGImageRef imageRef =CGImageCreateWithImageInRect([self.originalImage CGImage], rect);
    UIImage *image = [[UIImage alloc]initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    if (self.ovalClip) {
        image = [image ovalClip];
    }
    return image;
}

#pragma mark - 确定
- (void)doneBtnClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cropImageDidFinishedWithImage:)]) { //用来判断是否有以某个名字命名的方法
        [self.delegate cropImageDidFinishedWithImage:[self cropImage]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 取消
- (void)cancelBtnClick {
    
    switch (self.whereFrom) {
        case TDPhotoCutFromHeader:
            if (self.cancelHandle) {
                self.cancelHandle();
            }
            break;
        case TDPhotoCutFromAuthen:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
}

#pragma mark - UIStatusBarStyle
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
