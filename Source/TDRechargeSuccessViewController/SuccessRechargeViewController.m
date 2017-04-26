//
//  SuccessRechargeViewController.m
//  edX
//
//  Created by Elite Edu on 16/9/21.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "SuccessRechargeViewController.h"
#import "SuccessRechargeModel.h"
#import <MJExtension/MJExtension.h>

@interface SuccessRechargeViewController () <UIGestureRecognizerDelegate>

@property (nonatomic,strong) SuccessRechargeModel *successModel;

@end

@implementation SuccessRechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requerestData];
    
    self.titleViewLabel.text = NSLocalizedString(@"RECHARGE_SUCCESS", nil);
    self.titleLabel.text = NSLocalizedString(@"RECHARGE_SUCCESS", nil);
    self.messageLabel.text = NSLocalizedString(@"RECHARGE_MESSAGE", nil);
    self.rechargeTitle.text = NSLocalizedString(@"RECHARGE_MONEY", nil);
    self.coinsTitle.text = NSLocalizedString(@"RECHARGE_BAODIAN", nil);
    self.totaltitle.text = NSLocalizedString(@"AVALIABLE_BAODIAN", nil);
    
    self.leftButton.hidden = YES;
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    [backButton setImage:[UIImage imageNamed:@"backImagee"] forState:UIControlStateNormal];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -23, 0, 23);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [self setRechargeBack]; //设置充值返回的结果
}

#pragma mark - 初始化数据
- (void)setRechargeBack {
    
    SuccessRechargeModel *successModel = [[SuccessRechargeModel alloc] init];
    successModel.amount = self.firstL;
    successModel.total_coin = self.secondL;
    successModel.remain_coin = self.total;
    [self setData:successModel];
}

#pragma mark - 请求数据
- (void)requerestData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.orderId forKey:@"coin_record_id"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/v0.5/finance/coin_record_status/",ELITEU_URL];
    
    WS(weakSelf);
    [manager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *responDic = (NSDictionary *)responseObject;
        id code = responDic[@"code"];
        if ([code intValue] == 200) {
            NSDictionary *dataDic = responDic[@"data"];
            weakSelf.successModel = [SuccessRechargeModel mj_objectWithKeyValues:dataDic];
            [weakSelf setData:weakSelf.successModel];
            
        } else {
//            [self.view makeToast:responDic[@"msg"] duration:1.08 position:CSToastPositionCenter];
            NSLog(@"error -- %@",responDic[@"msg"]);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error -- %@",error);
    }];
    
}

#pragma mark - 数据
- (void)setData:(SuccessRechargeModel *)successModel {
    
    TDBaseToolModel *baseTool = [[TDBaseToolModel alloc] init];
    self.rechargeL.attributedText = [baseTool setDetailString:[NSString stringWithFormat:@"￥%.2f",[successModel.amount floatValue]] withFont:14 withColorStr:colorHexStr8];
    self.rechargeCanonsL.attributedText = [baseTool setDetailString:[NSString stringWithFormat:@"%.2f%@",[successModel.total_coin floatValue],NSLocalizedString(@"COINS_VALUE", nil)] withFont:14 withColorStr:colorHexStr8];
    self.totalCanonsL.attributedText = [baseTool setDetailString:[NSString stringWithFormat:@"%.2f%@",[successModel.remain_coin floatValue],NSLocalizedString(@"COINS_VALUE", nil)] withFont:14 withColorStr:colorHexStr8];
}

- (void)backButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
