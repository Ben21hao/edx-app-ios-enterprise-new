//
//  TDCourseCatalogDetailView.swift
//  edX
//
//  Created by Ben on 2017/5/3.
//  Copyright © 2017年 edX. All rights reserved.
//

import UIKit

class TDCourseCatalogDetailView: UIView,UITableViewDataSource {

    typealias Environment = protocol<OEXAnalyticsProvider, DataManagerProvider, NetworkManagerProvider, OEXRouterProvider>
    
    private let environment : Environment
    
    internal let tableView = UITableView()
    internal let courseCardView = CourseCardView()
    internal let playButton = UIButton()
    
    internal var playButtonHandle : (() -> ())?
    internal var submitButtonHandle : (() -> ())?
    internal var showAllTextHandle : ((Bool) -> ())?
    var showAllText = false
    var submitTitle : String?
    
    var courseModel = OEXCourse()

    private var _loaded = Sink<()>()
    var loaded : Stream<()> {
        return _loaded
    }
    
    init(frame: CGRect, environment: Environment) {
        self.environment = environment
        
        super.init(frame: frame)
        
        self.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        setViewConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: 加载课程详情信息函数
    func applyCourse(course : OEXCourse) {
        
        CourseCardViewModel.onCourseCatalog(course).apply(courseCardView, networkManager: self.environment.networkManager,type:1)//头部图片
        self.playButton.hidden = course.intro_video_3rd_url!.isEmpty ?? true
        
        self.courseModel = course
        self.tableView.reloadData()
    }
    
    //MARK: 全文 - 收起
    func moreButtonAction(sender: UIButton) {
        
        self.showAllText = !self.showAllText
        
        if (self.showAllTextHandle != nil) {
            self.showAllTextHandle?(self.showAllText)
        }
    }
    
    func submitButtonAction() { //提交
        if (self.submitButtonHandle != nil) {
            self.submitButtonHandle!()
        }
    }
    
    func playButtonAction() {
        if self.playButtonHandle != nil {
            self.playButtonHandle?()
        }
    }

    
    //MARK: tableview Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
           return 3
        } else {
            return 5
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = TDCourseIntroduceCell.init(style: .Default, reuseIdentifier: "TDCourseIntroduceCell")
                cell.selectionStyle = .None
                
                cell.moreButton.tag = 8
                if self.showAllText == true {
                    cell.introduceLabel.text = "\(self.courseModel.short_description!)\n\(self.courseModel.moreDescription!)"
                    cell.moreButton.setTitle(Strings.stopUp, forState: .Normal)
                } else {
                    cell.introduceLabel.text = self.courseModel.short_description
                    cell.moreButton.setTitle(Strings.allText, forState: .Normal)
                }
                
                cell.moreButton.addTarget(self, action: #selector(moreButtonAction(_:)), forControlEvents: .TouchUpInside)
            
                if self.courseModel.moreDescription?.characters.count == 0 && self.courseModel.short_description?.characters.count == 0 {
                    cell.moreButton.hidden = true
                }
                
                return cell
                
            } else if indexPath.row == 1 {
                let cell = TDCourseMessageCell.init(style: .Default, reuseIdentifier: "TDCourseMessageCell")
                cell.selectionStyle = .None
                
                cell.timeLabel.text = self.courseModel.effort?.stringByAppendingString(Strings.studyHour)
                if ((self.courseModel.effort?.containsString("约")) != nil) {
                    let timeStr = NSMutableString.init(string: self.courseModel.effort!)
                    let time = timeStr.stringByReplacingOccurrencesOfString("约", withString:"\(Strings.aboutTime) ")
                    cell.timeLabel.text = String(time.stringByAppendingString(" \(Strings.studyHour)"))
                }
                
                if self.courseModel.listen_count != nil {
                    let timeStr : String = self.courseModel.listen_count!.stringValue
                    cell.numberLabel.text = "\(timeStr) \(Strings.numberStudent)"
                } else {
                    cell.numberLabel.text = "0\(Strings.numberStudent)"
                }
                
                return cell
                
            } else {
                let cell = TDCourseButtonsCell.init(style: .Default, reuseIdentifier: "TDCourseButtonsCell")
                cell.selectionStyle = .None
                
                switch self.courseModel.submitType {
                case 0:
                    cell.submitButton.setTitle(Strings.CourseDetail.viewCourse, forState: .Normal)
                case 1:
                    if self.courseModel.is_eliteu_course == true {
                        cell.submitButton.setTitle(Strings.CourseDetail.enrollNow, forState: .Normal)
                    } else {
                        cell.submitButton.setAttributedTitle(setSubmitTitle(), forState: .Normal)
                    }
                case 2:
                    cell.submitButton.setTitle(Strings.viewPrepareOrder, forState: .Normal)
                default:
                    cell.submitButton.setTitle(Strings.willBeginCourse, forState: .Normal)
                }
                
                cell.submitButton.addTarget(self, action: #selector(submitButtonAction), forControlEvents: .TouchUpInside)
                return cell
            }
            
        } else {
            let cell = TDCourseDataCell.init(style: .Default, reuseIdentifier: "TDCourseDataCell")
            cell.selectionStyle = .None
            cell.accessoryType = .DisclosureIndicator
            
            switch indexPath.row {
            case 0:
                cell.leftLabel.text = "\u{f19c}"
                cell.titleLabel.text = Strings.mainProfessor
            case 1:
                cell.leftLabel.text = "\u{f0ca}"
                cell.titleLabel.text = Strings.courseOutline
            case 2:
                cell.leftLabel.text = "\u{f040}"
                cell.titleLabel.text = Strings.studentComment
            case 3:
                cell.leftLabel.text = "\u{f0c0}"
                cell.titleLabel.text = Strings.classTitle
            default:
                cell.leftLabel.text = "\u{f0c0}"
                cell.titleLabel.text = "助教"
            }
            return cell
        }
    }
    
    func setSubmitTitle() -> NSAttributedString {
        
        let baseTool = TDBaseToolModel.init()
        let priceStr = baseTool.setDetailString("\(Strings.CourseDetail.enrollNow)￥\(String(format: "%.2f",(self.courseModel.course_price?.doubleValue)!))", withFont: 16, withColorStr: "#ffffff")
         return priceStr //马上加入
    }
    
    //MARK: UI
    func setViewConstraint() {
        
        let headerView = UIView.init(frame: CGRectMake(0, 0, TDScreenWidth, (TDScreenWidth - 36) / 1.7 + 21))
        headerView.addSubview(courseCardView)
        
        courseCardView.snp_makeConstraints { (make) in
            make.left.equalTo(headerView.snp_left).offset(18)
            make.right.equalTo(headerView.snp_right).offset(-18)
            make.top.equalTo(headerView.snp_top).offset(16)
            make.height.equalTo((TDScreenWidth - 36) / 1.77)
        }
        
        playButton.setImage(Icon.CourseVideoPlay.imageWithFontSize(60), forState: .Normal)
        playButton.tintColor = OEXStyles.sharedStyles().neutralWhite()
        playButton.layer.shadowOpacity = 0.5
        playButton.layer.shadowRadius = 3
        playButton.layer.shadowOffset = CGSizeZero
        playButton.addTarget(self, action: #selector(playButtonAction), forControlEvents: .TouchUpInside)
        courseCardView.addCenteredOverlay(playButton)
        
        tableView.dataSource = self
        tableView.separatorStyle = .None
        self.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self)
        }
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = headerView
        
        headerView.backgroundColor = UIColor.whiteColor()
        tableView.backgroundColor = OEXStyles.sharedStyles().baseColor5()
    }
}
