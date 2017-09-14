//
//  CoursesTableViewController.swift
//  edX
//
//  Created by Anna Callahan on 10/15/15.
//  Copyright © 2015 edX. All rights reserved.
//

import UIKit

class CourseCardCell : UITableViewCell {
    static let margin = StandardVerticalMargin
    
    private static let cellIdentifier = "CourseCardCell"
    private let courseView = CourseCardView(frame: CGRectZero)
    private var course : OEXCourse?
    private let courseCardBorderStyle = BorderStyle()
    
    override init(style : UITableViewCellStyle, reuseIdentifier : String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(courseView)
        
        courseView.snp_makeConstraints {make in
            make.top.equalTo(self.contentView).offset(CourseCardCell.margin)
            make.bottom.equalTo(self.contentView)
            make.leading.equalTo(self.contentView).offset(CourseCardCell.margin)
            make.trailing.equalTo(self.contentView).offset(-CourseCardCell.margin)
        }
        
        courseView.applyBorderStyle(courseCardBorderStyle)
        
        self.contentView.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        self.selectionStyle = .None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol CoursesTableViewControllerDelegate : class {
    func coursesTableChoseCourse(course : OEXCourse)
}

class CoursesTableViewController: UITableViewController {
    
    enum Context {
        case CourseCatalog
        case EnrollmentList
    }
    
    typealias Environment = protocol<NetworkManagerProvider>
    
    private let environment : Environment
    private let context: Context
    private let whereFrom: Int
    
    weak var delegate : CoursesTableViewControllerDelegate?
    var courses : [OEXCourse] = []
    let insetsController = ContentInsetsController()
    
    let noDataLabel = UILabel()
    
    init(environment : Environment, context: Context, whereFrom: Int) {
        self.context = context
        self.environment = environment
        self.whereFrom = whereFrom
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        self.tableView.accessibilityIdentifier = "courses-table-view"
        
        self.tableView.snp_makeConstraints {make in
            make.edges.equalTo(self.view)
        }
        
        self.noDataLabel.font = UIFont.init(name: "OpenSans", size: 16)
        self.noDataLabel.textAlignment = .Center
        self.noDataLabel.textColor = OEXStyles.sharedStyles().baseColor9()
        self.noDataLabel.text = TDLocalizeSelectSwift("NO_COURSE_AVAILABLE_TEXT")
        self.tableView.addSubview(self.noDataLabel)
        
        self.noDataLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.tableView)
            make.top.equalTo(self.tableView.snp_top).offset(TDScreenHeight / 2 - 60)
        }
        
        self.noDataLabel.hidden = true
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerClass(CourseCardCell.self, forCellReuseIdentifier: CourseCardCell.cellIdentifier)
        
        self.insetsController.addSource(
            ConstantInsetsSource(insets: UIEdgeInsets(top: 0, left: 0, bottom: StandardVerticalMargin, right: 0), affectsScrollIndicators: false)
        )
    }

    //MARK: tableview Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.whereFrom == 1 {
        self.noDataLabel.hidden = self.courses.count != 0
        }
        
        return self.courses.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let course = self.courses[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CourseCardCell.cellIdentifier, forIndexPath: indexPath) as! CourseCardCell
        cell.accessibilityLabel = cell.courseView.updateAcessibilityLabel()
        cell.accessibilityHint = TDLocalizeSelectSwift("ACCESSIBILITY_SHOWS_COURSE_CONTENT")
        
        cell.courseView.tapAction = {[weak self] card in
            self?.delegate?.coursesTableChoseCourse(course)
        }
        
        switch context {
        case .CourseCatalog:
            CourseCardViewModel.onCourseCatalog(course).apply(cell.courseView, networkManager: self.environment.networkManager,type: 2)
        case .EnrollmentList:
            CourseCardViewModel.onHome(course).apply(cell.courseView, networkManager: self.environment.networkManager,type: 3)
        }
        cell.course = course

        return cell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.insetsController.updateInsets()
    }
}
