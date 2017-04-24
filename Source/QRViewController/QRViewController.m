//
//  QRViewController.m
//  edX
//
//  Created by Elite Edu on 16/12/21.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "QRViewController.h"

@interface QRViewController ()<UIAlertViewDelegate>

@property (nonatomic,strong) UIImageView *qrImage;
@property (nonatomic,strong) UITextView *messageTextView;
@property (nonatomic,strong) UITextView *titleTextView;
@property (nonatomic,strong) UIButton *wechatButton;
@property (nonatomic,strong) UIAlertView *alert;

@property (nonatomic,strong) UIScrollView *scrollView;

@end

@implementation QRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = NSLocalizedString(@"CLASS_TITLE", nil);
    
    [self configView];
    [self setConstraint];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePress:)];
    pressGesture.minimumPressDuration = 0.5;
    [self.qrImage addGestureRecognizer:pressGesture];
}

- (void)handlePress:(UILongPressGestureRecognizer *)pressGesture {
    if (!self.alert) {
        self.alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REMINDER", nil) message:NSLocalizedString(@"SAVE_QR_IMAGE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [self.alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self saveImageToPhotos];
    }
    
    self.alert = nil;
}

#pragma mark - 保存到相册
- (void)saveImageToPhotos {
    UIImageWriteToSavedPhotosAlbum(self.qrImage.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo:(void *) contextInfo {
    
    NSString *msg = NSLocalizedString(@"SAVE_QR_IMAGE_SUCCESS", nil);
    if(error != NULL){
        msg = NSLocalizedString(@"SAVE_QR_IMAGE_FAIL", nil);
    }
    [self.view makeToast:msg duration:1.08 position:CSToastPositionCenter];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.titleTextView resignFirstResponder];
    [self.messageTextView resignFirstResponder];
}

#pragma mark - 复制
- (void)wechatButtonAction:(UIButton *)sender {
    UIPasteboard *pastBoard = [UIPasteboard generalPasteboard];
    pastBoard.string = @"eliteu0831";
    
    [self.view makeToast:NSLocalizedString(@"COPY_SUCCESS", nil) duration:1.08 position:CSToastPositionTop];
}

#pragma mark - UI
- (void)configView {
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.contentSize = CGSizeMake(TDWidth, TDHeight);
    
    [self.view addSubview:self.scrollView];
    
    self.titleTextView = [self setLabelAttibute:@"加入英荔班级，寻找学习共鸣!" withString:nil];
    self.titleTextView.textAlignment = NSTextAlignmentCenter;
    self.titleTextView.font = [UIFont fontWithName:@"OpenSans" size:16];
    [self.scrollView addSubview:self.titleTextView];
    
    self.qrImage = [[UIImageView alloc] init];
    self.qrImage.layer.masksToBounds = YES;
    self.qrImage.layer.cornerRadius = 8.0;
    self.qrImage.userInteractionEnabled = YES;
    self.qrImage.image = [UIImage imageNamed:@"wetchatQR"];
    [self.scrollView addSubview:self.qrImage];
    
    self.messageTextView = [self setLabelAttibute:@"各抒己见，尽情吐露学习中的点滴感想、小成就。与英荔教授、助教一起探讨课程相关话题，最大化知识吸收。\n\n加入课程后请添加英荔教育微信：\n方法一：直接添加微信ID：eliteu0831；\n方法二：长按图片保存二维码至相册。打开微信“扫一扫”，点击右上角，从相册选取二维码并添加。\n添加时附上“课程名+登录账号”完成验证，进入班级。" withString:@"eliteu0831"];
    [self.scrollView addSubview:self.messageTextView];
    
    self.wechatButton = [[UIButton alloc] init];
    self.wechatButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.wechatButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    [self.wechatButton setTitle:NSLocalizedString(@"COPY_WECHAT_NUMBER", nil) forState:UIControlStateNormal];
    self.wechatButton.layer.cornerRadius = 10.0;
    [self.wechatButton addTarget:self action:@selector(wechatButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.wechatButton];
}

- (UITextView *)setLabelAttibute:(NSString *)text withString:(NSString *)string {
    UITextView *messageTextView = [[UITextView alloc] init];
    messageTextView.font = [UIFont fontWithName:@"OpenSans" size:14];
    messageTextView.textColor = [UIColor colorWithHexString:colorHexStr9];
    messageTextView.editable = NO;
    messageTextView.showsVerticalScrollIndicator = NO;
    messageTextView.scrollEnabled = NO;
    
    if (string.length > 0) {
        NSRange range = [text rangeOfString:string];
        if (range.location != NSNotFound) {
            NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:colorHexStr9],NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:14]}];
            NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:colorHexStr1],NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:14]}];
            [str1 replaceCharactersInRange:range withAttributedString:str2];
            messageTextView.attributedText = str1;
        } else {
            messageTextView.text = text;
        }
    } else {
        messageTextView.text = text;
    }
    return messageTextView;
}

#pragma mark - 布局
- (void)setConstraint {
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(self.view);
    }];
    
    [self.titleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView.mas_top).offset(18);
        make.left.mas_equalTo(self.scrollView.mas_left).offset(18);
        make.width.mas_equalTo(TDWidth - 36);
    }];

    [self.qrImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollView.mas_centerX);
        make.top.mas_equalTo(self.titleTextView.mas_bottom).offset(3);
        make.size.mas_equalTo(CGSizeMake(TDWidth * 0.59, TDWidth * 0.59));
    }];
    
    CGSize size = [self.messageTextView.text boundingRectWithSize:CGSizeMake(TDWidth - 36, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:14]} context:nil].size;
    [self.messageTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.qrImage.mas_bottom).offset(18);
        make.left.mas_equalTo(self.scrollView.mas_left).offset(18);
        make.width.mas_equalTo(TDWidth - 36);
        make.bottom.mas_equalTo(self.scrollView).offset(0);
        make.height.mas_equalTo(size.height + 28);
    }];
    
    CGSize size1 = [NSLocalizedString(@"COPY_WECHAT_NUMBER", nil) boundingRectWithSize:CGSizeMake(TDWidth - 36, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:12]} context:nil].size;
    [self.wechatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollView.mas_centerX);
        make.top.mas_equalTo(self.qrImage.mas_bottom).offset(-8);
        make.size.mas_equalTo(CGSizeMake(size1.width + 18, 20));
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
