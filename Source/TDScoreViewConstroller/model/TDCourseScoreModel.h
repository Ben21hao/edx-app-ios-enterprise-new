//
//  TDCourseScoreModel.h
//  edX
//
//  Created by Elite Edu on 2018/5/25.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

//@interface TDSectionScoreModel : NSObject
//
//@property (nonatomic,strong) NSString *attempted;//该问题是否提交
//@property (nonatomic,strong) NSString *problem_display_name;//题型
//@property (nonatomic,strong) NSString *possible;//这题的总分
//@property (nonatomic,strong) NSString *earned;//当前提交的后的得分
//@property (nonatomic,assign) BOOL isUnit; //是否是子章节
//@end

@interface TDUnitScoreModel : NSObject

@property (nonatomic,strong) NSString *subsection_display_name;//子章节名称
@property (nonatomic,strong) NSArray *problem_score_list;//子章节的测试得分列表

@property (nonatomic,strong) NSString *attempted;//该问题是否提交
@property (nonatomic,strong) NSString *problem_display_name;//题型
@property (nonatomic,strong) NSString *possible;//这题的总分
@property (nonatomic,strong) NSString *earned;//当前提交的后的得分
@property (nonatomic,assign) BOOL isUnit; //是否是子章节


@end

@interface TDChapterScoreModel : NSObject

@property (nonatomic,strong) NSString *section_display_name;//章节名称
@property (nonatomic,strong) NSArray <TDUnitScoreModel *> *subsection;//章节的子章节列表

@end

@interface TDCourseScoreModel : NSObject

@property (nonatomic,strong) NSString *all_attempted;//题目是否全部提交
@property (nonatomic,strong) NSString *course_status;//1: 通过课程，已完成 2：课程进行中 3，未完成课程
@property (nonatomic,strong) NSString *course_passed_grade;//课程通过成绩 0.6 = 60%
@property (nonatomic,strong) NSString *current_grade;//当前成绩 0.01 = 1%
@property (nonatomic,strong) NSString *course_problem_public;//判断是否发布了习题
@property (nonatomic,strong) NSArray <TDChapterScoreModel *> *courseware_summary; //课程的信息


@end
