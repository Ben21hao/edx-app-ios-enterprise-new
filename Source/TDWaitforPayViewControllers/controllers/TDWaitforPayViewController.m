//
//  TDWaitforPayViewController.m
//  edX
//
//  Created by Ben on 2017/6/29.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDWaitforPayViewController.h"
#import "TDWaitforPayTopCell.h"
#import "TDNewWaitfoPayCell.h"
#import "TDWaitforPayBottomCell.h"
#import "TDPaySheetView.h"

#import "TDWaitforPayModel.h"
#import <MJExtension/MJExtension.h>

@interface TDWaitforPayViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) TDPaySheetView *sheetView;

@property (nonatomic,strong) NSMutableArray *ordersArray;
@property (nonatomic,strong) TDBaseToolModel *baseTool;

@property (nonatomic,assign) NSInteger returnWay;

@end

@implementation TDWaitforPayViewController

- (NSMutableArray *)ordersArray {
    if (!_ordersArray) {
        _ordersArray = [[NSMutableArray alloc] init];
    }
    return _ordersArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = NSLocalizedString(@"PREPARE_PAY", nil);
    self.baseTool = [[TDBaseToolModel alloc] init];
    
    [self setViewContaint];
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - 待支付订单
- (void)requestData {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.username forKey:@"username"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/courses/v1/get_wait_order_list/",ELITEU_URL];
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            NSArray *dataArray = (NSArray *)responseObject[@"data"];
            if (dataArray.count > 0) {
                for (int i = 0; i < dataArray.count; i ++) {
                    NSDictionary *dataDic = dataArray[i];
                    TDWaitforPayModel *model = [TDWaitforPayModel mj_objectWithKeyValues:dataDic];
                    
                    if (model) {
                        NSArray *orderArray = dataDic[@"order_items"];
                        if (orderArray.count > 0) {
                            
                            NSMutableArray *subArray = [[NSMutableArray alloc] init];
                            
                            for (int j = 0; j < orderArray.count; j ++) {
                                NSDictionary *orderDic = orderArray[j];
                                TDWaitfoPayOrderModel *orderModel = [TDWaitfoPayOrderModel mj_objectWithKeyValues:orderDic];
                                if (orderModel) {
                                    [subArray addObject:orderModel];
                                }
                            }
                            model.order_items = subArray;
                        }
                        
                        [self.ordersArray addObject:model];
                    }
                }
            }
            
        } else {
            
        }

        [self.tableView reloadData];
        
        [self.loadIngView removeFromSuperview];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view makeToast:NSLocalizedString(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        [self.loadIngView removeFromSuperview];
        NSLog(@"error--%@",error);
    }];
}

#pragma mark - 取消按钮
- (void)cancelButtonAction:(UIButton *)sender {
    
    TDWaitforPayModel *model = self.ordersArray[sender.tag];
    NSString *orderID = model.order_id;
    
    NSArray *courseArray = model.order_items;
    for (int i = 0; i < courseArray.count; i ++) {
        TDWaitfoPayOrderModel *orderModel = courseArray[i];
        
        if ([orderModel.course_id isEqualToString:self.courseId]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Course_Status_Handle" object:nil];
            self.returnWay = 1;
        }
    }
    
    //会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"username"] = _username;
    params[@"order_id"] = orderID;
    NSString *url = [NSString stringWithFormat:@"%@/api/courses/v1/cancel_wait_order/",ELITEU_URL];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *code = responseObject[@"code"];
        if ([code intValue] == 200){
            
            [self.ordersArray removeObjectAtIndex:sender.tag];
            [self.tableView reloadData];
            if (self.ordersArray.count == 0) {
//                [self setNullDataBgView];
            }
            
        } else {
            NSLog(@"取消失败 --- %@",responseObject[@"msg"]);
            [self.view makeToast:NSLocalizedString(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view makeToast:NSLocalizedString(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"error--%@",error);
    }];

}

#pragma mark - 支付按钮
- (void)payButtonAction:(UIButton *)sender {
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    
    self.sheetView = [[TDPaySheetView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight)];
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight)];
//    view.backgroundColor = [UIColor redColor];
    [window addSubview:self.sheetView];
}

#pragma mark - tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.ordersArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TDWaitforPayModel *model = self.ordersArray[section];
    return model.order_items.count + 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TDWaitforPayModel *model = self.ordersArray[indexPath.section];
    if (indexPath.row == 0) {
        TDWaitforPayTopCell *cell = [[TDWaitforPayTopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDWaitforPayTopCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.orderLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"ORDER_NUM", nil),model.order_id];
        cell.cancelButton.tag = indexPath.section;
        [cell.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
        
    } else if (indexPath.row == model.order_items.count + 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TDMessageCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDMessageCell"];
        }
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
        cell.textLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
        cell.textLabel.attributedText = [self setMessageStr:model.cost_coin];
        return cell;
        
    } else if (indexPath.row == model.order_items.count + 2) {
        TDWaitforPayBottomCell *cell = [[TDWaitforPayBottomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDWaitforPayBottomCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.moneyLabel.attributedText = [self setRealMoney:[NSString stringWithFormat:@"￥%.2f",[model.real_amount floatValue]]];
        cell.payButton.tag = indexPath.section;
        [cell.payButton addTarget:self action:@selector(payButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
        
    } else {
        TDWaitfoPayOrderModel *orderModel = model.order_items[indexPath.row - 1];
        TDNewWaitfoPayCell *cell = [[TDNewWaitfoPayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDWaitforPayCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.model = orderModel;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TDWaitforPayModel *model = self.ordersArray[indexPath.section];
    
    if (indexPath.row == 0) {
        return 48;
        
    } else if (indexPath.row == model.order_items.count + 1) {
        return 48;
        
    } else if (indexPath.row == model.order_items.count + 2) {
        return 58;
    }
    return 120;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self setHeaderViewForSection];
}

- (UIView *)setHeaderViewForSection {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    return view;
}

- (NSMutableAttributedString *)setMessageStr:(NSString *)cost_coin {
    //    NSMutableAttributedString *str1 = [self.baseTool setString:[NSString stringWithFormat:@"%@:-¥%.2f",NSLocalizedString(@"COUPON_ACTIVITY", nil),[order.activate_price floatValue]] withFont:12 type:1];
    //    NSMutableAttributedString *str2 = [self.baseTool setString:[NSString stringWithFormat:@"  %@:-¥%.2f",NSLocalizedString(@"COUPON_PAPER", nil),[order.coupon_amount floatValue]] withFont:12 type:1];
    //    NSMutableAttributedString *str3 = [self.baseTool setString:[NSString stringWithFormat:@"  %@:-¥%.2f",NSLocalizedString(@"COINS_VALUE", nil),[order.cost_coin floatValue] / 10.0] withFont:12 type:1];
    //    [str1 appendAttributedString:str2];
    //    [str1 appendAttributedString:str3];
    
    NSMutableAttributedString *str = [self.baseTool setString:[NSString stringWithFormat:@"%@ : -¥%.2f",NSLocalizedString(@"COINS_VALUE", nil),[cost_coin floatValue] / 10.0] withFont:14 type:1];
    return str;
}

- (NSMutableAttributedString *)setRealMoney:(NSString *)moneyStr {
    
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"IN_TOTAL_PRICE", nil) attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:colorHexStr9]}];
    NSMutableAttributedString *str2 = [self.baseTool setDetailString:moneyStr withFont:14 withColorStr:@"#fa7f2b"];
    [str1 appendAttributedString:str2];
    return str1;
}

#pragma mark - UI
- (void)setViewContaint {
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    self.tableView.separatorColor = [UIColor colorWithHexString:colorHexStr6];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
