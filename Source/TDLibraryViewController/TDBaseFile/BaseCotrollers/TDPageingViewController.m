//
//  TDPageingViewController.m
//  edX
//
//  Created by Elite Edu on 2017/11/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDPageingViewController.h"

#define TITLEVIEW_HEIGHT 45
#define TITLTE_BUTTON_WIDTH TDWidth / self.childViewControllers.count
#define TITLTE_LINE_LENGTH 88

@interface TDPageingViewController () <UIScrollViewDelegate,UIGestureRecognizerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIScrollView *titleView;

@property (nonatomic,strong) UIView *selectView;
@property (nonatomic,strong) UIView *sepView; //分割线
@property (nonatomic,assign) CGFloat spaceLength;

@end

@implementation TDPageingViewController

- (NSMutableArray *)titleButtons{
    if (_titleButtons == nil) {
        _titleButtons = [NSMutableArray array];
    }
    return _titleButtons;
}

- (NSMutableArray<UIViewController *> *)childVcArray {
    if (_childVcArray == nil) {
        _childVcArray = [[NSMutableArray alloc] init];
    }
    return _childVcArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setViewConstraint];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - 导航栏左边按钮
- (void)setLeftNavigationBar {
    
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    [self.leftButton setImage:[UIImage imageNamed:@"backImagee"] forState:UIControlStateNormal];
    self.leftButton.showsTouchWhenHighlighted = YES;
    self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -23, 0, 23);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    [self.leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    
}

- (void)leftButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 导航栏右边按钮
- (void)setRightNavigationBar {
    
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 68, 48)];
    [self.rightButton setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    self.rightButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, -16);
    self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 13, 0, -13);
    self.rightButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:16.0];
    self.rightButton.titleLabel.textAlignment = NSTextAlignmentRight;
    self.rightButton.showsTouchWhenHighlighted = YES;
    [self.rightButton addTarget:self action:@selector(rightButtonAciton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
}

- (void)rightButtonAciton:(UIButton *)sender {

}

#pragma mark - 头部view
- (void)setSubTitleConstraint {
    [self setSepView];    //添加分割线
    [self setUpSubtitleButton]; //设置标题
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.titleView = [[UIScrollView alloc] init];
    self.titleView.backgroundColor = [UIColor colorWithHexString:colorHexStr13];
    self.titleView.frame = CGRectMake(0, 0, TDWidth, 45);
    [self.view addSubview:self.titleView];
    
    self.contentView = [[TDBaseScrollView alloc] init];
    self.contentView.frame = CGRectMake(0, TITLEVIEW_HEIGHT, TDWidth, TDHeight - TITLEVIEW_HEIGHT - 60);
    self.contentView.pagingEnabled = YES;
    self.contentView.delegate = self;
    self.contentView.bounces = NO;
    self.contentView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self.view addSubview:self.contentView];
}

#pragma mark - 设置按钮标题
- (void)setUpSubtitleButton {
    
    NSInteger count = self.childVcArray.count;
    CGFloat x = 0;
    CGFloat h = 46;
    CGFloat btnW = TDWidth / count;
    
    for (int i = 0; i < count; i++) {
        UIViewController *vc = self.childVcArray[i];
        
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = i;
        x = i * btnW;
        btn.frame = CGRectMake(x, 0, btnW, h);
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[UIColor colorWithHexString:colorHexStr9] forState:UIControlStateNormal];
        [btn setTitle:vc.title forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:btn];
        
        [self.titleButtons addObject:btn];
        
        if (i == 0) {//默认选中第0个按钮
            [self btnClick:btn];
        }
    }
    self.contentView.contentSize = CGSizeMake(count * TDWidth, 0);
    self.contentView.pagingEnabled = YES;
}

//添加分割线
- (void)setSepView {
    
    self.spaceLength = (TITLTE_BUTTON_WIDTH - TITLTE_LINE_LENGTH) / 2;
    
    CGFloat y = CGRectGetMaxY(self.titleView.frame);
    self.sepView = [[UIView alloc] init];
    self.sepView.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
    self.sepView.frame = CGRectMake(0, y, TDWidth, 1);
    [self.view addSubview:self.sepView];
    
    self.selectView = [[UIView alloc] init];
    self.selectView.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.selectView.frame = CGRectMake(self.spaceLength, 0, TITLTE_LINE_LENGTH, 2);
    [self.sepView addSubview:self.selectView];
}

#pragma mark - 选中
- (void)btnClick:(UIButton *)sender {
    
    [self dealWithButton:sender];
    
    CGFloat x = sender.tag * TDWidth; //滚动到对应位置
    self.contentView.contentOffset = CGPointMake(x, 0);
}

- (void)dealWithButton:(UIButton *)sender { //处理头部view
    [self selectButton:sender]; //让选中的标题颜色变蓝色
    [self setUpChildViewController:sender.tag];//把对应的子控制器添加上去
}

#pragma mark - 选中按钮
- (void)selectButton:(UIButton *)sender {
    
    for (int i = 0 ; i < self.titleButtons.count; i ++) {
        UIButton *button = self.titleButtons[i];
        NSString *colorStr = i == sender.tag ? colorHexStr1 : colorHexStr9;
        [button setTitleColor:[UIColor colorWithHexString:colorStr] forState:UIControlStateNormal];
    }
    [self setSelectViewFrame:TITLTE_BUTTON_WIDTH * sender.tag];
}

- (void)setSelectViewFrame:(CGFloat)x {
    WS(weakSelf);
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.selectView.frame = CGRectMake(x + self.spaceLength, 0, TITLTE_LINE_LENGTH, 2); //处理指示线的位置
    }];
}

/* 添加对应的子控制器 */
- (void)setUpChildViewController:(NSInteger)index {
    
    UIViewController *vc = self.childVcArray[index];
    if (vc.view.superview) {
        return;
    }
    CGFloat x = index * TDWidth;
    vc.view.frame = CGRectMake(x, 0, TDWidth, self.contentView.bounds.size.height);
    [self.contentView addSubview:vc.view];
}

#pragma mark - UIViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger page = scrollView.contentOffset.x / TDWidth;
    UIButton *seleButton = self.titleButtons[page];
    
    [self dealWithButton:seleButton];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self setSelectViewFrame:scrollView.contentOffset.x / self.childViewControllers.count];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (otherGestureRecognizer.state == UIGestureRecognizerStateBegan && self.contentView.contentOffset.x == 0) {
        return YES;
    }
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
