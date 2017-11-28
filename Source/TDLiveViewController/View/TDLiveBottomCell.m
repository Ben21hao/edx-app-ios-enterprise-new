//
//  TDLiveBottomCell.m
//  edX
//
//  Created by Ben on 2017/6/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDLiveBottomCell.h"
#import "edX-Swift.h"

@interface TDLiveBottomCell ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIImageView *lineImage;

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) int timeNum;

@property (nonatomic,strong) TDBaseToolModel *toolModel;

@end

@implementation TDLiveBottomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.toolModel = [[TDBaseToolModel alloc] init];
        [self setviewConstraint];
    }
    return self;
}

#pragma mark - 处理数据
- (void)setWhereFrom:(NSInteger)whereFrom { //从哪来
    
    _whereFrom = whereFrom;
    
    [self hideButtonOrNot:whereFrom == 0];
}


- (void)hideButtonOrNot:(BOOL)hide {
    
    self.enterButton.hidden = !hide;
    self.playButton.hidden = hide;
    self.praticeButton.hidden = hide;
}

- (void)setModel:(TDLiveModel *)model {
    _model = model;
    
    [self detalWithTimeStr:model.live_start_at nowTime:model.now_time];
    
    if (self.whereFrom == 0) {
        return;
    }
    if (model.enroll != nil) {
        NSDictionary *enrollDic = model.enroll;
        if (enrollDic.count == 0) {
            [self remarkPlayButton];
        }
    } else {
        [self remarkPlayButton];
    }
}

- (void)remarkPlayButton {
    
    self.enterButton.hidden = YES;
    [self.enterButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(TDWidth / 2 - 18, 35));
    }];
    
    [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
        make.width.mas_equalTo((TDWidth / 2) - 26);
        make.height.mas_equalTo(35);
    }];
    
    [self.praticeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(35);
    }];
}

- (void)detalWithTimeStr:(NSString *)startTime nowTime:(NSString *)nowTime { //时间

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *startStr = [self.toolModel changeStypeForTime:startTime];
    NSDate *startDate = [formatter dateFromString:startStr];//预约开始时间
    
    NSString *nowStr = [self.toolModel changeStypeForTime:nowTime];
    NSDate *nowDate = [formatter dateFromString:nowStr];;//当前时间
    
    NSTimeInterval nowInterval = [nowDate timeIntervalSince1970]*1;//当前时间时间
    NSTimeInterval startInterval = [startDate timeIntervalSince1970]*1;//预约开始时间
    
    self.timeNum = startInterval - nowInterval;
    
    NSDate *date = [nowDate earlierDate:startDate];//较早的时间
    
    if ([date isEqualToDate:nowDate]) {//当前时间为较早时间
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(waitForTime) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
        self.enterButton.userInteractionEnabled = NO;
        
        [self timeResultShow];
        
    } else {//当前时间已过开始时间
        self.enterButton.userInteractionEnabled = YES;
        [self.enterButton setTitle:TDLocalizeSelect(@"ENTER_LIVE_BUTTON_TEXT", nil) forState:UIControlStateNormal];
    }
}

- (void)waitForTime {
    
    self.timeNum -= 1;
    [self timeResultShow];
    
    if (self.timeNum <= 0) {
        [self.timer invalidate];
        self.enterButton.userInteractionEnabled = YES;
        [self.enterButton setTitle:TDLocalizeSelect(@"ENTER_LIVE_BUTTON_TEXT", nil) forState:UIControlStateNormal];
    }
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

- (void)dealloc {
    [self.timer invalidate];
}

#pragma mark - UI
- (void)setviewConstraint {
    
    self.bgView = [[UIView alloc] init];
    [self.contentView addSubview:self.bgView];
    
    self.enterButton = [self setButtonStyle];
    [self.bgView addSubview:self.enterButton];
    
    self.playButton = [self setButtonStyle];
    [self.bgView addSubview:self.playButton];
    
    self.praticeButton = [self setButtonStyle];
    [self.bgView addSubview:self.praticeButton];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.enterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(TDWidth / 2 - 26, 35));
    }];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.left.mas_equalTo(self.bgView.mas_left).offset(18);
        make.width.mas_equalTo((TDWidth / 2) - 26);
        make.height.mas_equalTo(35);
    }];
    
    [self.praticeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
        make.left.mas_equalTo(self.playButton.mas_right).offset(18);
        make.height.mas_equalTo(35);
    }];
    
    TDBaseToolModel *toolModel = [[TDBaseToolModel alloc] init];
    self.lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, 2)];
    self.lineImage.image = [toolModel drawLineByImageView:self.lineImage withColor:colorHexStr7];
    [self.bgView addSubview:self.lineImage];
    
    [self.enterButton setTitle:TDLocalizeSelect(@"ENTER_LIVE_BUTTON_TEXT", nil) forState:UIControlStateNormal];
    [self.praticeButton setTitle:TDLocalizeSelect(@"EXERCISSES_BUTTON_TEXT", nil) forState:UIControlStateNormal];
    [self.playButton setTitle:TDLocalizeSelect(@"PLAY_BACK_BUTTON_TEXT", nil) forState:UIControlStateNormal];
}

- (UIButton *)setButtonStyle {
    
    UIButton *button = [[UIButton alloc] init];
    button.showsTouchWhenHighlighted = YES;
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 4.0;
    button.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    button.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return button;
}

@end
