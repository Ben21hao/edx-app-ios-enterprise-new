//
//  TDOnlineCell.m
//  edX
//
//  Created by Ben on 2017/7/28.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDOnlineCell.h"
#import "edX-Swift.h"

@interface TDOnlineCell ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UILabel *lblShow;
@property (nonatomic,strong) UILabel *lblState;

@end

@implementation TDOnlineCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)setModel:(VHallOnlineStateModel *)model {
    _model = model;

    [self showDataView:model];
}

- (void)showDataView:(VHallOnlineStateModel *)model {

    NSString *event = @"";
    if([_model.event isEqualToString:@"online"]) {
        event = NSLocalizedString(@"ENTER_TEXT", nil);
    }else if([_model.event isEqualToString:@"offline"]){
        event = NSLocalizedString(@"LEAVE_TEXT", nil);
    }
    
    NSString *role = @"";
    if([_model.role isEqualToString:@"host"]) {
        role = NSLocalizedString(@"HOST_TEXT", nil);
    }else if([_model.role isEqualToString:@"guest"]) {
        role = NSLocalizedString(@"GUEST_TEXT", nil);
    }else if([_model.role isEqualToString:@"assistant"]) {
        role = NSLocalizedString(@"ASSISTANT_TEXT", nil);
    }else if([_model.role isEqualToString:@"user"]) {
        role = NSLocalizedString(@"VIEWER_TEXT", nil);
    }
    
    self.lblShow.text = [NSString stringWithFormat:@"%@[%@] %@%@%@", model.user_name, role, event, NSLocalizedString(@"ROOM_TEXT", nil),model.room];
    self.lblState.text = [Strings onlineCountTextWithCount:model.concurrent_user number:model.attend_count time:model.time];

}

#pragma mark - UI
- (void)configView {
    
    self.bgView = [[UIView alloc] init];
    [self.contentView addSubview:self.bgView];
    
    self.lblShow = [self setLabelStyle:@"#DC143C" font:16];
    [self.bgView addSubview:self.lblShow];
    
    self.lblState = [self setLabelStyle:colorHexStr10 font:10];
    [self.bgView addSubview:self.lblState];
}

- (void)setViewConstraint {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.lblShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
        make.top.mas_equalTo(self.bgView).offset(8);
        make.height.mas_equalTo(28);
    }];
    
    [self.lblState mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
        make.top.mas_equalTo(self.lblShow.mas_bottom).offset(0);
        make.bottom.mas_equalTo(self.bgView.mas_bottom);
    }];
}

- (UILabel *)setLabelStyle:(NSString *)colorStr font:(NSInteger)font {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"OpenSans" size:font];
    label.textColor = [UIColor colorWithHexString:colorStr];
    return label;
}


@end
