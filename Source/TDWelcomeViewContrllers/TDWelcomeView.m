//
//  TDWelcomeView.m
//  edX
//
//  Created by Elite Edu on 2017/11/27.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDWelcomeView.h"

@interface TDWelcomeView ()

@property (nonatomic,strong) UIImageView *launchImage;

@end

@implementation TDWelcomeView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    }
    return self;
}

- (void)startShowWelcome {
    
    [self configView];
    [self setViewConstrait];
}

- (void)configView {
    
    self.launchImage = [[UIImageView alloc] init];
    self.launchImage.image = [UIImage imageNamed:@"launch_image"];
    [self addSubview:self.launchImage];
}

- (void)setViewConstrait {
    
    [self.launchImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(self);
    }];
}


@end
