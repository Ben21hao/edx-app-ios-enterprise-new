//
//  TDAssistantFootCell.m
//  edX
//
//  Created by Elite Edu on 17/2/13.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDAssistantFootCell.h"
#import "edX-Swift.h"

@interface TDAssistantFootCell ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIButton *enterButton;
@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,strong) UIButton *commentButton;
@property (nonatomic,strong) UIView *startView;
@property (nonatomic,strong) UIImageView *lineImage;//虚线

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) int timeNum;
@property (nonatomic,assign) BOOL isCanClick;

@property (nonatomic,strong) TDBaseToolModel *baseTool;

@end

@implementation TDAssistantFootCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.baseTool = [[TDBaseToolModel alloc] init];
        self.isCanClick = YES;
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)setWhereFrom:(NSInteger)whereFrom {
    _whereFrom = whereFrom;
    
    self.enterButton.hidden = YES;
    self.cancelButton.hidden = YES;
    self.commentButton.hidden = YES;
    self.startView.hidden = YES;
    
    if (_whereFrom == 1) {
        self.commentButton.hidden = NO;
        self.startView.hidden = NO;
    }
}

- (void)setModel:(TDAssistantServiceModel *)model {
    _model = model;
    
    [self dealWithData];
}

- (void)dealWithData {
    
    if (self.whereFrom == 0) {//待完成
        
        if ([self.model.order_type intValue] == 1) {
            [self dealWithTimeStr:self.model.service_begin_at nowTime:self.model.now_time];
            
        } else {
            self.enterButton.hidden = NO;
            [self.enterButton setTitle:TDLocalizeSelect(@"ENTER_CLASSROOM", nil) forState:UIControlStateNormal];
        }
        
    } else if (self.whereFrom == 1) {//已完成
        self.isComment = [self.model.is_comment intValue];
        
        if (self.isComment) {
            self.startView.hidden = NO;
            self.commentButton.hidden = YES;
            
            self.score = [self.model.comment_infomation.score intValue];;
            [self setStarView:self.score];
        } else {
            self.startView.hidden = YES;
            self.commentButton.hidden = NO;
        }
    }
}

/*
 时间处理规则
-- (取消) ---- 24小时前 ---- (倒计时) ---- 预约时间 ----- (进入教室) ------
 */
- (void)dealWithTimeStr:(NSString *)startTime nowTime:(NSString *)nowTime {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *str1 = [startTime substringToIndex:19];
    NSString *timeStr = [str1 stringByReplacingOccurrencesOfString:@"T" withString:@" "];

    NSDate *startDate = [formatter dateFromString:timeStr];//预约开始时间
    
    NSDate *nowDate = [formatter dateFromString:nowTime];;//当前时间
    
    NSTimeInterval nowInterval = [nowDate timeIntervalSince1970]*1;//手机系统时间
    NSTimeInterval startInterval = [startDate timeIntervalSince1970]*1;//课程结束时间
    
    self.timeNum = startInterval - nowInterval;
    
    NSDate *date = [nowDate earlierDate:startDate];//较早的时间

    if ([date isEqualToDate:nowDate]) {//当前时间为较早时间

        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(waitForTime) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
        self.enterButton.hidden = NO;
        self.isCanClick = NO;
        
        [self timeResultShow];
        
    } else {//当前时间已过开始时间
        self.enterButton.hidden = NO;
        [self.enterButton setTitle:TDLocalizeSelect(@"ENTER_CLASSROOM", nil) forState:UIControlStateNormal];
    }
    
//    NSLog(@"---==== >>>> %@ == %@ --> %f",startDate,now,interval);
}

- (NSDate *)getChinaTime:(NSDate *)date {//计算东八区的时间
    NSTimeZone* localTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];//获取本地时区(中国时区)
    NSInteger offset = [localTimeZone secondsFromGMTForDate:date];//计算世界时间与本地时区的时间偏差值
    NSDate *localDate = [date dateByAddingTimeInterval:offset];//世界时间＋偏差值 得出中国区时间
    return localDate;
}

- (void)waitForTime {
    
    self.timeNum -= 1;
    [self timeResultShow];
    
    if (self.timeNum <= 0) {
        [self.timer invalidate];
        self.isCanClick = YES;
        [self.enterButton setTitle:TDLocalizeSelect(@"ENTER_CLASSROOM", nil) forState:UIControlStateNormal];
    }
}

- (void)dealloc {
    [self.timer invalidate];
}

- (void)timeResultShow {
    
    int day = self.timeNum / (24 * 60 * 60);
    int hourNum = self.timeNum % (24 * 60 * 60);
    int hour = hourNum / (60 * 60);
    int muniteNum = self.timeNum % (60 * 60);
    int munite = muniteNum / 60;
    int second = self.timeNum % 60;
    
    NSString *dayStr = day == 0 ? @"00" : [NSString stringWithFormat:@"%d",day];
    
    NSString *hourStr = @"00";
    if (hour > 0) {
        hourStr = hour < 10 ?  [NSString stringWithFormat:@"0%d",hour] : [NSString stringWithFormat:@"%d",hour];
    }
    
    NSString *muniteStr = @"00";
    if (munite > 0) {
        muniteStr = munite < 10 ?  [NSString stringWithFormat:@"0%d",munite] : [NSString stringWithFormat:@"%d",munite];
    }
    
    NSString *secondStr = @"00";
    if (second > 0) {
        secondStr = second < 10 ? [NSString stringWithFormat:@"0%d",second] :[NSString stringWithFormat:@"%d",second];
    }
    
    NSString *str = [TDLocalizeSelect(@"TIME_COUNT_NUM", nil) oex_formatWithParameters:@{@"day" : dayStr, @"hour" : hourStr, @"min" : muniteStr, @"second" : secondStr}];
    [self.enterButton setTitle:str forState:UIControlStateNormal];
}

#pragma mark - 设置星星
- (void)setStarView:(int)fen {
    for (int i = 0 ; i < 5; i ++) {
        UIImageView *star = [[UIImageView alloc] init];
        star.image = [UIImage imageNamed:i < fen ? @"star1" : @"star11"];
        [self.startView addSubview:star];
        
        [star mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.startView.mas_left).offset(25 * i);
            make.centerY.mas_equalTo(self.startView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(19, 19));
        }];
    }
}

#pragma mark - buttonHandle
- (void)enterButtonAction:(UIButton *)sender {
    if (self.isCanClick) {
        if (self.endterButtonHandle) {
            self.endterButtonHandle();
        }
    }
}

- (void)cancelButtonAction:(UIButton *)sender {
    if (self.cancelButtonHandle) {
        self.cancelButtonHandle();
    }
}

- (void)commentButtonAction:(UIButton *)sender {
    if (self.commentButtonHandle) {
        self.commentButtonHandle();
    }
}

#pragma mark - UI
- (void)configView {
    
    self.bgView = [[UIView alloc] init];
    [self addSubview:self.bgView];
    
    self.enterButton = [self setButtonConstraint:TDLocalizeSelect(@"ENTER_CLASSROOM", nil) backGroundColor:colorHexStr1 titleColor:colorHexStr13];
    [self.enterButton addTarget:self action:@selector(enterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.enterButton];
    
    self.cancelButton = [self setButtonConstraint:TDLocalizeSelect(@"CANCEL", nil) backGroundColor:colorHexStr6 titleColor:colorHexStr9];
    [self.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.cancelButton];
    
    self.commentButton = [self setButtonConstraint:TDLocalizeSelect(@"RETE_TA", nil) backGroundColor:colorHexStr4 titleColor:colorHexStr13];
    [self.commentButton addTarget:self action:@selector(commentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.commentButton];
    
    self.startView = [[UIView alloc] init];
    [self.bgView addSubview:self.startView];
    
    self.lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, 2)];
    self.lineImage.image = [self.baseTool drawLineByImageView:self.lineImage withColor:colorHexStr7];
    [self.bgView addSubview:self.lineImage];
    
}

- (UIButton *)setButtonConstraint:(NSString *)title backGroundColor:(NSString *)color1 titleColor:(NSString *)color2 {
    
    UIButton *button   = [[UIButton alloc] init];
    button.backgroundColor = [UIColor colorWithHexString:color1];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:color2] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    button.layer.cornerRadius = 4.0;
    button.showsTouchWhenHighlighted = YES;
    return button;
}

- (void)setViewConstraint {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.enterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
        make.size.mas_equalTo(CGSizeMake(158, 33));
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
        make.size.mas_equalTo(CGSizeMake(68, 33));
    }];
    
    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
        make.size.mas_equalTo(CGSizeMake(88, 33));
    }];
    
    [self.startView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.left.mas_equalTo(self.bgView.mas_left).offset(8);
        make.size.mas_equalTo(CGSizeMake(99, 33));
    }];
}


@end



