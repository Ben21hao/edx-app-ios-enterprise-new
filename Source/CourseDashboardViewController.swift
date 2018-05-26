//
//  CourseDashboardViewController.swift
//  edX
//
//  Created by Ehmad Zubair Chughtai on 11/05/2015.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit

protocol CourseDashboardItem {
    var identifier: String { get }
    var action:(() -> Void) { get }
    var height: CGFloat { get }

    func decorateCell(cell: UITableViewCell)
}

struct StandardCourseDashboardItem : CourseDashboardItem { //标准 cell 的item
    let identifier = CourseDashboardCell.identifier
    let height:CGFloat = 83.0

    let title: String
    let detail: String
    let icon : Icon
    let action:(() -> Void)
    

    typealias CellType = CourseDashboardCell
    func decorateCell(cell: UITableViewCell) {
        guard let dashboardCell = cell as? CourseDashboardCell else { return }
        dashboardCell.useItem(self)
    }
}

struct CertificateDashboardItem: CourseDashboardItem { //证书 cell 的item
    let identifier = CourseCertificateCell.identifier
    let height: CGFloat = 116.0

    let certificateImage: UIImage
    let certificateUrl: String
    let action:(() -> Void)

    func decorateCell(cell: UITableViewCell) {
        guard let certificateCell = cell as? CourseCertificateCell else { return }
        certificateCell.useItem(self)
    }
}

public class CourseDashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate {
    
    public typealias Environment = protocol<OEXAnalyticsProvider, OEXConfigProvider, DataManagerProvider, NetworkManagerProvider, OEXRouterProvider, OEXInterfaceProvider>
    
    private let spacerHeight: CGFloat = OEXStyles.dividerSize()

    private let environment: Environment
    private let courseID: String
    private var whereFrom = 0
    private var enrollment: UserCourseEnrollment?
    private let courseCard = CourseCardView(frame: CGRectZero)
    
    private let tableView: UITableView = UITableView()
    private let stackView: TZStackView = TZStackView()
    private let containerView: UIScrollView = UIScrollView()
    private let shareButton = UIButton(type: .System)
    
    private var cellItems: [CourseDashboardItem] = []
    
    private let loadController = LoadStateViewController()
    private let courseStream = BackedStream<UserCourseEnrollment>()
    
    private var titleLabel : UILabel? //自定义标题
    private lazy var progressController : ProgressController = {
        ProgressController(owner: self, router: self.environment.router, dataInterface: self.environment.interface)
    }()
    
    public init(environment: Environment, courseID: String, whereFrom: Int ,enrollment: UserCourseEnrollment?) {
        self.environment = environment
        self.courseID = courseID
        self.whereFrom = whereFrom
        self.enrollment = enrollment;
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        // required by the compiler because UIViewController implements NSCoding,
        // but we don't actually want to serialize these things
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationButtonStyle()
        self.setViewConstraint()
        
        /* 数据 */
        if self.whereFrom == 1 { //试听课程
            self.loadedCourseWithEnrollment(self.enrollment!)
            loadController.state = .Loaded
            
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("Come_From_Course_Detail")
            
            courseStream.backWithStream(environment.dataManager.enrollmentManager.streamForCourseWithID(courseID)) //couseID获取数据
            courseStream.listen(self) {[weak self] in
                self?.resultLoaded($0)
            }
        }
        
        NSNotificationCenter.defaultCenter().oex_addObserver(self, name: EnrollmentShared.successNotification) { (notification, observer, _) -> Void in
            if let message = notification.object as? String {
                observer.showOverlayMessage(message)
            }
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        environment.analytics.trackScreenWithName(OEXAnalyticsScreenCourseDashboard, courseID: courseID, value: nil)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tableView.snp_updateConstraints{ make in
            make.height.equalTo(tableView.contentSize.height)
        }
        containerView.contentSize = stackView.bounds.size
    }

    //MARK: UI
    func setViewConstraint() {
        
        self.view.backgroundColor = OEXStyles.sharedStyles().baseColor5()
    
        containerView.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        self.view.addSubview(containerView)
        
        containerView.snp_makeConstraints {make in
            make.edges.equalTo(self.view)
        }
        
        tableView.scrollEnabled = false
        tableView.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(CourseDashboardCell.self, forCellReuseIdentifier: CourseDashboardCell.identifier)
        tableView.registerClass(CourseCertificateCell.self, forCellReuseIdentifier: CourseCertificateCell.identifier)
        self.view.addSubview(tableView)
        
        stackView.addArrangedSubview(courseCard)
        stackView.addArrangedSubview(tableView)
        self.containerView.addSubview(stackView)
        
        stackView.snp_makeConstraints { make -> Void in
            make.top.equalTo(containerView)
            make.trailing.equalTo(containerView)
            make.leading.equalTo(containerView)
        }
        stackView.alignment = .Fill
        
//        addShareButton(courseCard) //隐藏分享按钮
        
        stackView.axis = .Vertical
        
        let spacer = UIView()
        stackView.addArrangedSubview(spacer)
        
        spacer.snp_makeConstraints {make in
            make.height.equalTo(spacerHeight)
            make.width.equalTo(self.containerView)
        }
        
        loadController.setupInController(self, contentView: containerView)
    }
    
    func setNavigationButtonStyle() {
        
        self.titleLabel = UILabel(frame:CGRect(x:0, y:0, width:40, height:40))
        self.titleLabel?.font = UIFont(name:"OpenSans",size:18.0)
        self.titleLabel?.textColor = UIColor.whiteColor()
        self.navigationItem.titleView = self.titleLabel
        
        let leftButton = UIButton.init(frame: CGRectMake(0, 0, 48, 48))
        leftButton.setImage(UIImage.init(named: "backImagee"), forState: .Normal)
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -23, 0, 23)
        
        self.navigationController?.interactivePopGestureRecognizer?.enabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        leftButton.addTarget(self, action: #selector(leftBarItemAction), forControlEvents: .TouchUpInside)
        let leftBarItem = UIBarButtonItem.init(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarItem
        
        //隐藏下载进度条
//        self.progressController.hideProgessView()
//        self.navigationItem.rightBarButtonItem = self.progressController.navigationItem()
    }
    
    func leftBarItemAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    private func resultLoaded(result : Result<UserCourseEnrollment>) {
        switch result {
        case let .Success(enrollment):
            self.loadedCourseWithEnrollment(enrollment)
            
        case let .Failure(error):
            if !courseStream.active {
                // enrollment list is cached locally, so if the stream is still active we may yet load the course
                // don't show failure until the stream is done
                self.loadController.state = LoadState.failed(error)
            }
        }
    }
    
    private func loadedCourseWithEnrollment(enrollment: UserCourseEnrollment) {
        
        self.titleLabel?.text = enrollment.course.name
        
        CourseCardViewModel.onDashboard(enrollment.course).apply(courseCard, networkManager: self.environment.networkManager,type:4)
        verifyAccessForCourse(enrollment.course)
        prepareTableViewData(enrollment)
        self.tableView.reloadData()
        
        //分享按钮
        shareButton.hidden = enrollment.course.course_about == nil || !environment.config.courseSharingEnabled
        shareButton.oex_removeAllActions()
        shareButton.oex_addAction({[weak self] _ in
            self?.shareCourse(enrollment.course)
            }, forEvents: .TouchUpInside)
    }
    
    //share sheet
    private func shareCourse(course: OEXCourse) { //分享课程
        
        if let urlString = course.course_about, url = NSURL(string: urlString) {
            let analytics = environment.analytics
            let courseID = self.courseID
            let controller = shareHashtaggedTextAndALink({ hashtagOrPlatform in
                
                Strings.shareACourse(platformName: hashtagOrPlatform)
                
                }, url: url, analyticsCallback: { analyticsType in
                    
                    analytics.trackCourseShared(courseID, url: urlString, socialTarget: analyticsType)
            })
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    private func addShareButton(courseView: CourseCardView) {
        
        if environment.config.courseSharingEnabled {
            shareButton.setImage(UIImage(named: "share"), forState: .Normal)
            shareButton.tintColor = OEXStyles.sharedStyles().neutralDark()
            
            courseView.titleAccessoryView = shareButton
            shareButton.snp_makeConstraints(closure: { (make) -> Void in
                make.height.equalTo(26)
                make.width.equalTo(20)
            })
        }
    }
    
    private func verifyAccessForCourse(course: OEXCourse) {
        if let access = course.courseware_access where !access.has_access {
            loadController.state = LoadState.failed(OEXCoursewareAccessError(coursewareAccess: access, displayInfo: course.start_display_info), icon: Icon.UnknownError)
        } else {
            loadController.state = .Loaded
        }
    }
    
    public func prepareTableViewData(enrollment: UserCourseEnrollment) {
        cellItems = []
        
        /* 证书 */
//        if let certificateUrl = getCertificateUrl(enrollment) {
//            let item = CertificateDashboardItem(certificateImage: UIImage(named: "courseCertificate")!, certificateUrl: certificateUrl, action: {
//                let url = NSURL(string: certificateUrl)!
//                self.environment.router?.showCertificate(url, title: enrollment.course.name, fromController: self)
//            })
//            cellItems.append(item)
//        }
        
        /*课件*/
        var item = StandardCourseDashboardItem(title: TDLocalizeSelectSwift("COURSE_DASHBOARD_COURSEWARE"), detail: TDLocalizeSelectSwift("COURSE_DASHBOARD_COURSE_DETAIL"), icon : .Courseware) {[weak self] () -> Void in
            self?.showCourseware()
        }
        cellItems.append(item)
        
        /*讨论*/
        if shouldShowDiscussions(enrollment.course) {
            let courseID = self.courseID
            item = StandardCourseDashboardItem(title: TDLocalizeSelectSwift("COURSE_DASHBOARD_DISCUSSION"), detail: TDLocalizeSelectSwift("COURSE_DASHBOARD_DISCUSSION_DETAIL"), icon: .Discussions) {[weak self] () -> Void in
                self?.showDiscussionsForCourseID(courseID)
            }
            cellItems.append(item)
        }
        
        /*资料*/
        item = StandardCourseDashboardItem(title: TDLocalizeSelectSwift("COURSE_DASHBOARD_HANDOUTS"), detail: TDLocalizeSelectSwift("COURSE_DASHBOARD_HANDOUTS_DETAIL"), icon: .Handouts) {[weak self] () -> Void in
            self?.showHandouts()
        }
        cellItems.append(item)
        
        /*公告*/
        item = StandardCourseDashboardItem(title: TDLocalizeSelectSwift("COURSE_DASHBOARD_ANNOUNCEMENTS"), detail: TDLocalizeSelectSwift("COURSE_DASHBOARD_ANNOUNCEMENTS_DETAIL"), icon: .Announcements) {[weak self] () -> Void in
            self?.showAnnouncements()
        }
        cellItems.append(item)
        
        if enrollment.course.is_public_course == true {
            /*班级*/
            item = StandardCourseDashboardItem(title: TDLocalizeSelectSwift("CLASS_TITLE"), detail: TDLocalizeSelectSwift("ENTET_CLASS"), icon: .Group) {[weak self] () -> Void in
                self?.showQRViewController()
            }
            cellItems.append(item)
        }
        
        /*成绩*/
        item = StandardCourseDashboardItem(title: "成绩", detail: "查看本课程的成绩", icon: .Handouts) {[weak self] () -> Void in
            self?.showScoreViewController()
        }
        cellItems.append(item)
    }
    
    
    private func shouldShowDiscussions(course: OEXCourse) -> Bool {
        let canShowDiscussions = self.environment.config.discussionsEnabled ?? false
        let courseHasDiscussions = course.hasDiscussionsEnabled ?? false
        return canShowDiscussions && courseHasDiscussions
    }
    
    private func getCertificateUrl(enrollment: UserCourseEnrollment) -> String? {
        guard environment.config.discussionsEnabled else { return nil }
        return enrollment.certificateUrl
    }
    
    
    // MARK: - TableView Data and Delegate
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellItems.count
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let dashboardItem = cellItems[indexPath.row]
        return dashboardItem.height
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dashboardItem = cellItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(dashboardItem.identifier, forIndexPath: indexPath)
        dashboardItem.decorateCell(cell)
        
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dashboardItem = cellItems[indexPath.row]
        dashboardItem.action()
    }
    
    //MARK: 跳转
    private func showCourseware() { //课件
        self.environment.router?.showCoursewareForCourseWithID(courseID, fromController: self)
    }
    
    private func showDiscussionsForCourseID(courseID: String) { //讨论
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
        self.environment.router?.showDiscussionTopicsFromController(self, courseID: courseID)
    }
    
    private func showHandouts() { //资料
        let enroll = self.whereFrom == 1 ? self.enrollment : nil
        self.environment.router?.showHandoutsFromController(self, courseID: courseID, whereFrom: self.whereFrom, enrollment: enroll)
    }
    
    private func showAnnouncements() { //公告
        self.environment.router?.showAnnouncementsForCourseWithID(courseID)
    }
    
    private func showQRViewController() { //班级
        let vc = QRViewController();
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showScoreViewController() {
        let vc = TDScoreViewController()
        vc.username = OEXRouter.sharedRouter().environment.session.currentUser?.username
        vc.course_id = courseID
        vc.courseTitle = self.titleLabel?.text
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}

// MARK: Testing
extension CourseDashboardViewController {
    
    func t_canVisitDiscussions() -> Bool {
        return self.cellItems.firstIndexMatching({ (item: CourseDashboardItem) in return (item is StandardCourseDashboardItem) && (item as! StandardCourseDashboardItem).icon == .Discussions }) != nil
    }

    func t_canVisitCertificate() -> Bool {
        return self.cellItems.firstIndexMatching({ (item: CourseDashboardItem) in return (item is CertificateDashboardItem)}) != nil
    }
    
    var t_state : LoadState {
        return self.loadController.state
    }
    
    var t_loaded : Stream<()> {
        return self.courseStream.map {_ in () }
    }
    
}

