//
//  TDProfessorViewController.m
//  edX
//
//  Created by Elite Edu on 16/12/21.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "TDProfessorViewController.h"
#import <UIImageView+WebCache.h>
#import "NSObject+OEXReplaceNull.h"

@interface TDProfessorViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSString *introduce;//教授简介
@property (nonatomic,strong) NSString *achievement;//主要成就
@property (nonatomic,strong) NSString *education;//教育背景
@property (nonatomic,strong) NSString *otherAchievement;//其他成就
@property (nonatomic,strong) NSString *research;//研究领域
@property (nonatomic,strong) NSString *learning;//学术
@property (nonatomic,strong) NSString *project;//管理项目

@property (nonatomic,strong) NSString *imageUrl;//头像
@property (nonatomic,strong) NSString *name;//名字
@property (nonatomic,strong) NSString *college;//院校
@property (nonatomic,strong) NSString *major;//专业
@property (nonatomic,strong) NSString *degrees;//学位
@property (nonatomic,strong) NSString *motto;//铭言

@property (nonatomic,strong) TDBaseToolModel *baseTool;

@end

@implementation TDProfessorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = TDLocalizeSelect(@"PROFESSOR_DETAIL", nil);
    self.baseTool = [[TDBaseToolModel alloc] init];
    [self setLoadDataView];
    
    [self requrestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - UI
- (void)setUpView {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    self.tableView.tableHeaderView = [self setHeaderView];
}

#pragma mark - 数据
- (void)requrestData {
    if (![self.baseTool networkingState]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/v0.5/professor/?username=%@",ELITEU_URL,self.professorName];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success----->>> %@",responseObject);
        
        NSDictionary *responDic = (NSDictionary *)responseObject;
        id code = responDic[@"code"];
        
        if ([code intValue] == 200) {
            
            NSDictionary *dataDic = [responDic[@"data"] oex_replaceNullsWithEmptyStrings];
            
            self.imageUrl = dataDic[@"avatar_url"];//头像
            self.name = dataDic[@"professor_name"];//姓名
            self.college = dataDic[@"college"];//毕业院校
            self.major = dataDic[@"specialty"];//专业
            self.degrees = dataDic[@"degrees"];//学位
            self.motto = [dataDic[@"slogan"] stringByReplacingOccurrencesOfString:@"</br>" withString:@"\n"];//个性语句
            
            self.introduce = [[dataDic[@"introduction"] stringByReplacingOccurrencesOfString:@"<i>" withString:@""]stringByReplacingOccurrencesOfString:@"</i>" withString:@""];//1 教授简介
            self.achievement = [dataDic[@"main_achievements"] stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];//2 主要成就
            self.education = [dataDic[@"education_experience"] stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];//3 教育背景
            self.otherAchievement = [dataDic[@"other_achievements"] stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];//4 其他成就
            self.research = [dataDic[@"research_fields"] stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];//5 研究领域
            self.learning = [[dataDic[@"research_papers"] stringByReplacingOccurrencesOfString:@"<i>" withString:@""]stringByReplacingOccurrencesOfString:@"</i>" withString:@""];//6 学术刊物文章
            self.project = dataDic[@"project_experience"];//7 管理咨询项目
            
            [self setUpView];
            [self.tableView reloadData];
            
        } else if ([code intValue] == 406) {
            [self setNullDataView:@"所查询教授不存在"];
            [self.view makeToast:responDic[@"msg"] duration:1.08 position:CSToastPositionCenter];
            
        } else {
            NSLog(@"请求错误 ==== %@",responDic[@"msg"]);
            [self.view makeToast:TDLocalizeSelect(@"NO_SUPPORT_WECHAT", nil) duration:1.08 position:CSToastPositionCenter];
        }
        
        [self.loadIngView removeFromSuperview];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.loadIngView removeFromSuperview];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"error ---- %@",error);
        
    }];
}

#pragma mark - tableview Delegate 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    switch (section) {
        case 0:
            return self.introduce.length == 0 ? 0 : 1;
            break;
        case 1:
             return self.achievement.length == 0 ? 0 : 1;
            break;
        case 2:
             return self.education.length == 0 ? 0 : 1;
            break;
        case 3:
             return self.otherAchievement.length == 0 ? 0 : 1;
            break;
        case 4:
             return self.research.length == 0 ? 0 : 1;
            break;
        case 5:
             return self.learning.length == 0 ? 0 : 1;
            break;
        case 6:
             return self.project.length == 0 ? 0 : 1;
            break;
        default:
            break;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"professorCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"professorCell"];
    }
    cell.userInteractionEnabled = NO;
    cell.textLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    cell.textLabel.numberOfLines = 0;
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.attributedText = [self setDetailTextAttribute:[NSString stringWithFormat:@"%@\n",TDLocalizeSelect(@"PROFESSOR_INTRODUCE", nil)] withDetail:[NSString stringWithFormat:@"%@", self.introduce]];
            break;
        case 1:
            cell.textLabel.attributedText = [self setDetailTextAttribute:[NSString stringWithFormat:@"%@\n",TDLocalizeSelect(@"MAIN_ACHIECEMENT", nil)] withDetail:[NSString stringWithFormat:@"%@", self.achievement]];
            break;
        case 2:
            cell.textLabel.attributedText = [self setDetailTextAttribute:[NSString stringWithFormat:@"%@\n",TDLocalizeSelect(@"EDUCATIONNAL_BACKGROUND", nil)] withDetail:[NSString stringWithFormat:@"%@", self.education]];
            break;
        case 3:
            cell.textLabel.attributedText = [self setDetailTextAttribute:[NSString stringWithFormat:@"%@\n",TDLocalizeSelect(@"OTHERS_ACHIEVEMENT", nil)] withDetail:[NSString stringWithFormat:@"%@", self.otherAchievement]];
            break;
        case 4:
            cell.textLabel.attributedText = [self setDetailTextAttribute:[NSString stringWithFormat:@"%@\n",TDLocalizeSelect(@"RESEARCH_FIELD", nil)] withDetail:[NSString stringWithFormat:@"%@", self.research]];
            break;
        case 5:
            cell.textLabel.attributedText = [self setDetailTextAttribute:[NSString stringWithFormat:@"%@\n",TDLocalizeSelect(@"ACADEMIC_ESSAYS", nil)] withDetail:[NSString stringWithFormat:@"%@", self.learning]];
            break;
        case 6:
            cell.textLabel.attributedText = [self setDetailTextAttribute:[NSString stringWithFormat:@"%@\n",TDLocalizeSelect(@"MANAGEREMENT_CONSULTING", nil)] withDetail:[NSString stringWithFormat:@"%@", self.project]];
            break;
            
        default:
            break;
    }
    
    NSLog(@"%@ ++++++++ %ld",cell.textLabel.text,(long)indexPath.section);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
            
        case 0:
            return [self contentSize:self.introduce].height + 48;
            break;
        case 1:
            return [self contentSize:self.achievement].height + 48;
            break;
        case 2:
            return [self contentSize:self.education].height + 48;
            break;
        case 3:
            return [self contentSize:self.otherAchievement].height + 48;
            break;
        case 4:
            return [self contentSize:self.research].height + 48;
            break;
        case 5:
            return [self contentSize:self.learning].height + 48;
            break;
        case 6:
            return [self contentSize:self.project].height + 48;
            break;
    }
    return 48;
}

#pragma mark - 计算文本高度
- (CGSize)contentSize:(NSString *)detailText {
    
    NSMutableParagraphStyle *paragraphStyle = [self setDetailTextPagraph:4.0];
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:14],
                                  NSParagraphStyleAttributeName : paragraphStyle
                                  };
    
//    NSString *str = [detaiText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//去掉两边空格
    NSString *text = [detailText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//去掉回车和空格
    
    CGSize contentSize = [text boundingRectWithSize:CGSizeMake(TDWidth - 48, MAXFLOAT)
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              attributes:attributes
                                                 context:nil].size;
    return contentSize;
}

#pragma mark - 文本attribute
- (NSMutableAttributedString *)setDetailTextAttribute:(NSString *)title withDetail:(NSString *)detail {
    
    NSMutableParagraphStyle *paragraph1 = [self setDetailTextPagraph:8.0];
    NSMutableParagraphStyle *paragraph2 = [self setDetailTextPagraph:4.0];
    
//    NSString *str = [detail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//去掉两边空格
    NSString *text = [detail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//去掉回车和空格
    
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:title
                                                                             attributes:@{
                                                                                          NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:16] ,
                                                                                          NSForegroundColorAttributeName : [UIColor colorWithHexString:@"000000"],
                                                                                          NSParagraphStyleAttributeName : paragraph1
                                                                                          }];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:text
                                                                             attributes:@{
                                                                                          NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:14] ,
                                                                                          NSForegroundColorAttributeName : [UIColor colorWithHexString:colorHexStr10],
                                                                                          NSParagraphStyleAttributeName : paragraph2
                                                                                          }];
    [str1 appendAttributedString:str2];
    
    return str1;
}

- (NSMutableParagraphStyle *)setDetailTextPagraph:(float)lineSpace {//段落设置
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc]init] ;
    paragraph.alignment = NSTextAlignmentLeft;
    paragraph.lineSpacing = lineSpace;
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    
    return paragraph;
}

#pragma mark - 头部视图
- (UIView *)setHeaderView {
    
    NSString *mottoStr = [self.motto stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    CGFloat height = mottoStr.length > 0 ? 288 : 218;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, height)];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, height)];
     bgView.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    [headerView addSubview:bgView];
    
    UIImageView *headerImage = [[UIImageView alloc] init];
    headerImage.layer.masksToBounds = YES;
    headerImage.layer.cornerRadius = 58.0;
    headerImage.layer.borderColor = [UIColor whiteColor].CGColor;
    headerImage.layer.borderWidth = 1;
    [headerView addSubview:headerImage];
    
    UILabel *nameLabel = [self setLabel];
    [headerView addSubview:nameLabel];
    
    [headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(headerView.mas_top).offset(28);
        make.centerX.mas_equalTo(headerView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(116, 116));
    }];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(headerImage.mas_bottom).offset(8);
        make.left.mas_equalTo(headerView.mas_left).offset(13);
        make.right.mas_equalTo(headerView.mas_right).offset(-13);
    }];
    
    //设置头像
    NSString *imageStr = [self.baseTool dealwithImageStr:[NSString stringWithFormat:@"%@%@",ELITEU_URL,self.imageUrl]];
    [headerImage sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"default_big"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
    nameLabel.text = [NSString stringWithFormat:@"%@\n%@ %@ %@",self.name,self.college,self.major,self.degrees];
    
    if (mottoStr.length > 0) {
        UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 203, TDWidth, 2)];
        [headerView addSubview:lineImage];
        
        UILabel *mottoLabel = [self setLabel];
        [headerView addSubview:mottoLabel];
        
        [mottoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lineImage.mas_bottom).offset(0);
            make.left.mas_equalTo(headerView.mas_left).offset(13);
            make.right.mas_equalTo(headerView.mas_right).offset(-13);
            make.bottom.mas_equalTo(headerView.mas_bottom).offset(0);
        }];
        
        lineImage.image = [self.baseTool drawLineByImageView:lineImage withColor:colorHexStr13];
        mottoLabel.text = [NSString stringWithFormat:@"%@",self.motto];
    }
    
    return headerView;
}

- (UILabel *)setLabel {
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"OpenSans" size:13];
    label.textColor = [UIColor whiteColor];
    label.numberOfLines  = 0;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
