//
//  TDImageSelectView.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/10.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDImageSelectView.h"
#import "TDSelectImageModel.h"
#import "TDLongPressGestureRecognizer.h"
#import "TDTapGestureRecognizer.h"

#import "TDSelectImageModel.h"
#import "TDImageHandle.h"

#define button_width (TDWidth - 26 - 30) / 4

@interface TDImageSelectView ()

@end

@implementation TDImageSelectView

- (void)setImageArray:(NSArray *)imageArray {
    _imageArray = imageArray;
    
    [self imageViewHiddenHandle:imageArray.count];
    
    if (imageArray.count < 4) {
        self.firstButton.hidden = NO;
        
        [self.firstButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(imageArray.count * (button_width + 10));
            make.top.bottom.mas_equalTo(self);
            make.width.mas_equalTo(button_width);
        }];
        
    } else {
        self.firstButton.hidden = YES;
    }
    
    for (int i = 0; i < imageArray.count; i ++) {
        
        TDSelectImageModel *model = imageArray[i];
        switch (i) {
            case 0:
                [self getScreenSizeImage:model imageView:self.firstImage];
                break;
            case 1:
                [self getScreenSizeImage:model imageView:self.secondImage];;
                break;
            case 2:
                [self getScreenSizeImage:model imageView:self.thirdImage];;
                break;
            default:
                [self getScreenSizeImage:model imageView:self.fourthImage];;
                break;
        }
       
    }
}

- (void)getScreenSizeImage:(TDSelectImageModel *)model imageView:(UIImageView *)imageView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [model.asset thumbnail:CGSizeMake(TDWidth, TDHeight) resultHandler:^(UIImage *result, NSDictionary *info) {
            imageView.image = result;
            model.image = result;
        }];
    });
}

- (void)longpress:(TDLongPressGestureRecognizer *)longpress {
    NSLog(@"------>>> %ld",longpress.tag);
    if (self.deleteImageHandle) {
        self.deleteImageHandle(longpress.tag);
    }
}

- (void)tap:(TDTapGestureRecognizer *)tap {
    NSLog(@"------>>> %ld",tap.tag);
    if (self.tapImageHandle) {
        self.tapImageHandle(tap.tag);
    }
}

- (void)imageViewHiddenHandle:(NSInteger)count {
    
    switch (count) {
        case 0:
            self.firstImage.hidden = YES;
            self.secondImage.hidden = YES;
            self.thirdImage.hidden = YES;
            self.fourthImage.hidden = YES;
            break;
        case 1:
            self.firstImage.hidden = NO;
            self.secondImage.hidden = YES;
            self.thirdImage.hidden = YES;
            self.fourthImage.hidden = YES;
            break;
        case 2:
            self.firstImage.hidden = NO;
            self.secondImage.hidden = NO;
            self.thirdImage.hidden = YES;
            self.fourthImage.hidden = YES;
            break;
        case 3:
            self.firstImage.hidden = NO;
            self.secondImage.hidden = NO;
            self.thirdImage.hidden = NO;
            self.fourthImage.hidden = YES;
            break;
        default:
            self.firstImage.hidden = NO;
            self.secondImage.hidden = NO;
            self.thirdImage.hidden = NO;
            self.fourthImage.hidden = NO;
            break;
    }
}

- (void)configeView {
    
    self.firstButton = [[UIButton alloc] init];
    self.firstButton.contentMode = UIViewContentModeScaleAspectFill;
    [self.firstButton setImage:[UIImage imageNamed:@"add_black_image"] forState:UIControlStateNormal];
    [self addSubview:self.firstButton];
    
    self.firstImage = [self setImageStyle:0];
    [self addSubview:self.firstImage];
    
    self.secondImage = [self setImageStyle:1];
    [self addSubview:self.secondImage];
    
    self.thirdImage = [self setImageStyle:2];
    [self addSubview:self.thirdImage];
    
    self.fourthImage = [self setImageStyle:3];
    [self addSubview:self.fourthImage];
    
    [self imageViewHiddenHandle:0];
}

- (void)setViewConstraint {
    
    [self.firstButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(button_width);
    }];
    
    [self.firstImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(button_width);
    }];
    
    [self.secondImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(button_width);
        make.left.mas_equalTo(self.firstImage.mas_right).offset(10);
    }];
    
    [self.thirdImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(button_width);
        make.left.mas_equalTo(self.secondImage.mas_right).offset(10);
    }];
    
    [self.fourthImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(button_width);
        make.left.mas_equalTo(self.thirdImage.mas_right).offset(10);
    }];
}

- (UIImageView *)setImageStyle:(NSInteger)index {
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"image_loading"];
    imageView.userInteractionEnabled = YES;
    
    TDLongPressGestureRecognizer *longpress = [[TDLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpress:)];
    longpress.minimumPressDuration = 0.3;
    longpress.tag = index;
    
    TDTapGestureRecognizer *tap = [[TDTapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.tag = index;
    
    [imageView addGestureRecognizer:longpress];
    [imageView addGestureRecognizer:tap];
    
    return imageView;
}

@end

