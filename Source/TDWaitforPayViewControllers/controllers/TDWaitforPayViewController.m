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

#import "TDBuySuccessViewController.h"

#import "WXApi.h"
#import "WeChatPay.h"
#import "TDWaitforPayModel.h"
#import "weChatParamsItem.h"

#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "aliPayParamsItem.h"
#import "dataUrlItem.h"
#import "aliData.h"

#import <MJExtension/MJExtension.h>
#import "edX-Swift.h"

@interface TDWaitforPayViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) TDPaySheetView *sheetView;
@property (nonatomic,strong) UILabel *nullLabel;

@property (nonatomic,strong) NSMutableArray *ordersArray;
@property (nonatomic,strong) TDBaseToolModel *baseTool;

@property (nonatomic,assign) NSInteger returnWay;
@property (nonatomic,assign) BOOL isInstallWechat;
@property (nonatomic,assign) NSInteger payType; //1 微信，2 支付宝
@property (nonatomic,strong) NSString *payOrderID;
@property (nonatomic,strong) NSString *paySuccessID;

@property (nonatomic,strong) weChatParamsItem *weChatItem;
@property (nonatomic,strong) aliPayParamsItem *aliPayItem;

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
    
    self.titleViewLabel.text = TDLocalizeSelect(@"PREPARE_PAY", nil);
    
    self.baseTool = [[TDBaseToolModel alloc] init];
    self.returnWay = 0;
    self.isInstallWechat = [WXApi isWXAppInstalled];
    self.payType = self.isInstallWechat ? 1 : 2;
    
    [self setViewContaint];
    
    [self setLoadDataView];
    
    [self requestData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paySuccess) name:@"aliPaySuccess" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    [self tapGestureAction];
}

- (void)backButtonAction:(UIButton *)sender {
    
    if (self.whereFrom == 1 && self.returnWay == 1) {
        [self.navigationController popToViewController:self.navigationController.childViewControllers[1] animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 待支付订单
- (void)requestData {
    
    if (![self.baseTool networkingState]) {
        [self.loadIngView removeFromSuperview];
        return;
    }
    
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
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        [self.loadIngView removeFromSuperview];
        NSLog(@"error--%@",error);
    }];
}

#pragma mark - 取消按钮
- (void)cancelButtonAction:(UIButton *)sender {
    
    if (![self.baseTool networkingState]) {
        return;
    }
    
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

        } else {
            NSLog(@"取消失败 --- %@",responseObject[@"msg"]);
            [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"error--%@",error);
    }];

}

#pragma mark - 弹框
- (void)payButtonAction:(UIButton *)sender {
    
    self.sheetView = [[TDPaySheetView alloc] init];
    self.sheetView.frame = CGRectMake(0, 0, TDWidth, TDHeight);
    
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.sheetView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction)];
    [self.sheetView.tapView addGestureRecognizer:tap];
    
    [self.sheetView.payMoneyView.createOrderButton addTarget:self action:@selector(createOrderButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetView.alipayView.bgButton addTarget:self action:@selector(alipayAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetView.wechatView.bgButton addTarget:self action:@selector(wechatAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    TDWaitforPayModel *model = self.ordersArray[sender.tag];
    self.payOrderID = model.order_id; //订单id
    self.sheetView.payMoneyView.moneyLabel.attributedText = [self setRealMoney:[NSString stringWithFormat:@"¥%.2f",[model.real_amount floatValue]]];//订单价格
    
    if ([model.give_coin floatValue] > 0) {
        
        NSString *coinStr = [TDLocalizeSelect(@"GIVE_COINS_NUMBER", nil) oex_formatWithParameters:@{@"count" : [NSString stringWithFormat:@"%.2f",[model.give_coin floatValue]]}];
        
        NSMutableAttributedString *str4 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",TDLocalizeSelect(@"PAY_TITLE", nil)] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:14],NSForegroundColorAttributeName : [UIColor whiteColor]}];
        NSMutableAttributedString *str5 = [self.baseTool setDetailString:coinStr withFont:11 withColorStr:colorHexStr3];
        [str4 appendAttributedString:str5];
        [self.sheetView.payMoneyView.createOrderButton setAttributedTitle:str4 forState:UIControlStateNormal];
    }

}

- (void)tapGestureAction { //收起弹框
    [self.sheetView removeFromSuperview];
}

- (void)createOrderButtonAction:(UIButton *)sender { //创建订单
    [self createOrderWithType:self.payType];
}

- (void)wechatAction:(UIButton *)sender { //微信
    [self choosePayType:YES];
}

- (void)alipayAction:(UIButton *)sender { //支付宝
    [self choosePayType:NO];
}

- (void)choosePayType:(BOOL)isWechat {
    self.sheetView.alipayView.selectButton.selected = !isWechat;
    self.sheetView.wechatView.selectButton.selected = isWechat;
    
    self.payType = isWechat ? 1 : 2;
}

#pragma mark - 创建订单
- (void)createOrderWithType:(NSInteger)type {//1 微信支付；2 支付宝支付 ;3 内购
    
    if (![self.baseTool networkingState]) {
        return;
    }
    
    [self.sheetView.payMoneyView.activityView startAnimating];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.username forKey:@"username"];
    [dic setValue:self.payOrderID forKey:@"order_id"];
    [dic setValue:@"enterprise" forKey:@"pay_source"];
    [dic setValue:@(type) forKey:@"pay_method"];

    NSString *url = [NSString stringWithFormat:@"%@/api/courses/v1/get_pay_course_info/",ELITEU_URL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            self.paySuccessID = responseDic[@"data"][@"order_id"];
            
            if (type == 1) {
                _weChatItem = [weChatParamsItem mj_objectWithKeyValues:responseObject[@"data"]];
                [self wechatPay];
                
            } else {
                _aliPayItem = [aliPayParamsItem mj_objectWithKeyValues:responseObject];
                [self aliPay];
            }
        } else {
            NSLog(@"创建订单 === 》  %@",responseDic[@"msg"]);
            [self.view makeToast:TDLocalizeSelect(@"PAY_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        }
        
        [self requestStopHandle];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self requestStopHandle];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_NOT_AVAILABLE_TITLE", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"error--%@",error);
    }];
}

- (void)requestStopHandle {
    [self tapGestureAction];
    [self.sheetView.payMoneyView.activityView stopAnimating];
}

#pragma mark - 调起微信支付
- (void)wechatPay {
    
    [[[WeChatPay alloc] init] submitPostWechatPay:self.weChatItem];
}

#pragma mark - 调起支付宝
- (NSString*)urlEncodedString:(NSString *)string
{
    NSString * encodedString = (__bridge_transfer  NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
    
    return encodedString;
}

- (void)aliPay{
    Order *order = [[Order alloc] init];
    order.partner = _aliPayItem.data.data_url.partner;
    order.sellerID = _aliPayItem.data.data_url.seller_id;
    order.outTradeNO = _aliPayItem.data.data_url.out_trade_no; //订单ID（由商家自行制定）
    NSLog(@"order.outTradeNO--%@",order.outTradeNO);
    order.subject = _aliPayItem.data.data_url.subject; //商品标题
    order.body = _aliPayItem.data.data_url.body; //商品描述
    order.totalFee = _aliPayItem.data.data_url.total_fee;//商品价格
    order.notifyURL =  _aliPayItem.data.data_url.notify_url; //回调URL
    order.service = _aliPayItem.data.data_url.service;
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    //    NSString *appScheme = @"alisdkdemo";
    NSString *appScheme = @"org.eliteu.mobile-enterprise";
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    //    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    //    NSString *signedString = [signer signString:orderSpec];
    
    NSString *base64String = _aliPayItem.data.data_url.sign;
    NSString *signedString = [self urlEncodedString:base64String];
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",orderSpec, signedString, @"RSA"];
        NSLog(@"orderString = %@",orderString);
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            //【callback处理支付结果】
            NSLog(@"A--reslut = %@",resultDic);
            
            NSString *resultStatus = resultDic[@"resultStatus"];
            
            NSString *strTitle = TDLocalizeSelect(@"PAY_RESULT", nil);
            NSString *str;
            switch ([resultStatus integerValue]) {
                case 6001:
                    str = TDLocalizeSelect(@"PAY_CANCEL", nil);
                    break;
                case 9000:
                    str = TDLocalizeSelect(@"PAY_SUCCESS", nil);
                    break;
                case 8000:
                    str = TDLocalizeSelect(@"IS_HANDLE", nil);
                    break;
                case 4000:
                    str = TDLocalizeSelect(@"PAY_FAIL", nil);
                    break;
                case 6002:
                    str = TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil);
                    break;
                    
                default:
                    break;
            }
            if ([resultStatus isEqualToString:@"9000"]) {
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"aliPaySuccess" object:nil]];
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:str delegate:self cancelButtonTitle:TDLocalizeSelect(@"OK", nil) otherButtonTitles:nil, nil];
                alert.tag = 9000;
                [alert show];
            }
        }];
    }
}

#pragma mark - 支付成功
- (void)paySuccess {
    TDBuySuccessViewController *buySuccessVC = [[TDBuySuccessViewController alloc] init];
    buySuccessVC.orderId = self.paySuccessID;
    NSLog(@"success %@ ====== %@",buySuccessVC.orderId,self.payOrderID);
    
    [self.navigationItem setTitle:@""];
    [self.navigationController pushViewController:buySuccessVC animated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"aliPaySuccess" object:nil];
}


#pragma mark - tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    self.nullLabel.hidden = self.ordersArray.count != 0;
    return self.ordersArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TDWaitforPayModel *model = self.ordersArray[section];
    return model.order_items.count + 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TDWaitforPayModel *model = self.ordersArray[indexPath.section];
    if (indexPath.row == 0) { //单号
        TDWaitforPayTopCell *cell = [[TDWaitforPayTopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDWaitforPayTopCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.orderLabel.text = [NSString stringWithFormat:@"%@%@",TDLocalizeSelect(@"ORDER_NUM", nil),model.order_id];
        cell.cancelButton.tag = indexPath.section;
        [cell.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
        
    } else if (indexPath.row == model.order_items.count + 1) { //赠送信息
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TDMessageCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDMessageCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
        cell.textLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
        cell.textLabel.attributedText = [self setMessageStr:model.cost_coin];
        return cell;
        
    } else if (indexPath.row == model.order_items.count + 2) {//合计
        TDWaitforPayBottomCell *cell = [[TDWaitforPayBottomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDWaitforPayBottomCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.moneyLabel.attributedText = [self setRealMoney:[NSString stringWithFormat:@"￥%.2f",[model.real_amount floatValue]]];
        cell.payButton.tag = indexPath.section;
        [cell.payButton addTarget:self action:@selector(payButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
        
    } else { //
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
    //    NSMutableAttributedString *str1 = [self.baseTool setString:[NSString stringWithFormat:@"%@:-¥%.2f",TDLocalizeSelect(@"COUPON_ACTIVITY", nil),[order.activate_price floatValue]] withFont:12 type:1];
    //    NSMutableAttributedString *str2 = [self.baseTool setString:[NSString stringWithFormat:@"  %@:-¥%.2f",TDLocalizeSelect(@"COUPON_PAPER", nil),[order.coupon_amount floatValue]] withFont:12 type:1];
    //    NSMutableAttributedString *str3 = [self.baseTool setString:[NSString stringWithFormat:@"  %@:-¥%.2f",TDLocalizeSelect(@"COINS_VALUE", nil),[order.cost_coin floatValue] / 10.0] withFont:12 type:1];
    //    [str1 appendAttributedString:str2];
    //    [str1 appendAttributedString:str3];
    
    NSMutableAttributedString *str = [self.baseTool setString:[NSString stringWithFormat:@"%@ : -¥%.2f",TDLocalizeSelect(@"COINS_VALUE", nil),[cost_coin floatValue] / 10.0] withFont:14 type:1];
    return str;
}

- (NSMutableAttributedString *)setRealMoney:(NSString *)moneyStr {
    
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:TDLocalizeSelect(@"IN_TOTAL_PRICE", nil) attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:colorHexStr9]}];
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
    
    
    self.nullLabel = [[UILabel alloc] init];
    self.nullLabel.text = TDLocalizeSelect(@"NO_COURSE_ORDER", nil);
    self.nullLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
    self.nullLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    [self.tableView addSubview:self.nullLabel];
    
    [self.nullLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.tableView);
        make.centerY.mas_equalTo(self.tableView).offset(-18);
    }];
    
    self.nullLabel.hidden = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
