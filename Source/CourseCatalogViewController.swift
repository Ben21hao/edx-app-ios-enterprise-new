//
//  CourseCatalogViewController.swift
//  edX
//
//  Created by Akiva Leffert on 11/30/15.
//  Copyright © 2015 edX. All rights reserved.
//

import UIKit

class CourseCatalogViewController: UIViewController, CoursesTableViewControllerDelegate {
    typealias Environment = protocol<NetworkManagerProvider, OEXRouterProvider, OEXSessionProvider, OEXConfigProvider, OEXAnalyticsProvider>
    
    private let environment : Environment
    private let tableController : CoursesTableViewController
    private let loadController = LoadStateViewController()
    private let insetsController = ContentInsetsController()
    let titleViewLabel = UILabel.init(frame: CGRectMake(0, 0, TDScreenWidth - 198, 44))
    
    init(environment : Environment) {
        self.environment = environment
        self.tableController = CoursesTableViewController(environment: environment, context: .CourseCatalog)
        super.init(nibName: nil, bundle: nil)
        
//        self.navigationItem.title = Strings.findCourses
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var paginationController : PaginationController<OEXCourse> = {
//        let username = self.environment.session.currentUser?.username ?? ""
//        precondition(username != "", "Shouldn't be showing course catalog without a logged in user")
//        let organizationCode =  self.environment.config.organizationCode()
//        
//        let paginator = WrappedPaginator(networkManager: self.environment.networkManager) { page in
//            return CourseCatalogAPI.getCourseCatalog(username, page: page, organizationCode: organizationCode)
//        }
//        return PaginationController(paginator: paginator, tableView: self.tableController.tableView)
        
        var username = self.environment.session.currentUser?.username ?? ""
        var company_id = self.environment.session.currentUser?.company_id ?? ""
        if username == ""{
            username = ""
            let paginator = WrappedPaginator(networkManager: self.environment.networkManager) { page in
                return CourseCatalogAPI.getCourseCatalog(username, company_id:company_id, page: page)//获取所有课程
            }
            return PaginationController(paginator: paginator, tableView: self.tableController.tableView)
            
        } else{
            precondition(username != "", "Shouldn't be showing course catalog without a logged in user")
            
            let paginator = WrappedPaginator(networkManager: self.environment.networkManager) { page in
                return CourseCatalogAPI.getCourseCatalog(username, company_id:company_id, page: page)
            }
            return PaginationController(paginator: paginator, tableView: self.tableController.tableView)
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.accessibilityIdentifier = "course-catalog-screen";
        self.view.backgroundColor = OEXStyles.sharedStyles().standardBackgroundColor()
        
        setTitleLabelNaviBar()
        addChildView()
        loadCourseData()
        
        insetsController.setupInController(self, scrollView: tableController.tableView)
        insetsController.addSource(
            // add a little padding to the bottom since we have a big space between
            // each course card
            ConstantInsetsSource(insets: UIEdgeInsets(top: 0, left: 0, bottom: StandardVerticalMargin, right: 0), affectsScrollIndicators: false)
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        environment.analytics.trackScreenWithName(OEXAnalyticsScreenFindCourses)
    }
    
    func addChildView() {
        
        addChildViewController(tableController)
        tableController.didMoveToParentViewController(self)
        self.loadController.setupInController(self, contentView: tableController.view)
        
        self.view.addSubview(tableController.view)
        tableController.view.snp_makeConstraints {make in
            make.edges.equalTo(self.view)
        }
        tableController.delegate = self
    }
    
    func loadCourseData() {
        paginationController.stream.listen(self, success:
            {[weak self] courses in
                self?.loadController.state = .Loaded
                self?.tableController.courses = courses
                self?.tableController.tableView.reloadData()
            }, failure: {[weak self] error in
                self?.loadController.state = LoadState.failed(error)
            }
        )
        paginationController.loadMore()
    }
    
    func setTitleLabelNaviBar() {
        self.titleViewLabel.textAlignment = .Center
        self.titleViewLabel.font = UIFont.init(name: "OpenSans", size: 18.0)
        self.titleViewLabel.textColor = UIColor.whiteColor()
        self.titleViewLabel.text = Strings.findCourses
        self.navigationItem.titleView = self.titleViewLabel
    }
    
    func coursesTableChoseCourse(course: OEXCourse) {
        if (course.course_id != nil) {
            self.environment.router?.showCourseCatalogDetail(course, fromController:self)
        }  else {
            return
        }
        
    }
}

// Testing only
extension CourseCatalogViewController {
    
    var t_loaded : Stream<()> {
        return self.paginationController.stream.map {_ in
            return
        }
    }

}
