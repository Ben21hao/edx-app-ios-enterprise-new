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

struct StandardCourseDashboardItem : CourseDashboardItem {
    let identifier = CourseDashboardCell.identifier
    let height:CGFloat = 85.0

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

struct CertificateDashboardItem: CourseDashboardItem {
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

public class CourseDashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    public typealias Environment = protocol<OEXAnalyticsProvider, OEXConfigProvider, DataManagerProvider, NetworkManagerProvider, OEXRouterProvider, OEXInterfaceProvider, OEXRouterProvider>
    
    private let spacerHeight: CGFloat = OEXStyles.dividerSize()

    private let environment: Environment
    private let course: OEXCourse?
    
    private let tableView: UITableView = UITableView()
    private let stackView: TZStackView = TZStackView()
    private let containerView: UIScrollView = UIScrollView()
    
    private var cellItems: [CourseDashboardItem] = []
    
    private let loadController = LoadStateViewController()
    
    private lazy var progressController : ProgressController = {
        ProgressController(owner: self, router: self.environment.router, dataInterface: self.environment.interface)
    }()
    
    public init(environment: Environment, course: OEXCourse?) {
        self.environment = environment
        self.course = course
        
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.title = course?.name
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        // required by the compiler because UIViewController implements NSCoding,
        // but we don't actually want to serialize these things
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = OEXStyles.sharedStyles().neutralXLight()
        
        self.navigationItem.rightBarButtonItem = self.progressController.navigationItem()
        
        self.view.addSubview(containerView)
        self.containerView.addSubview(stackView)
        tableView.scrollEnabled = false
        
        // Set up tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(tableView)
        
        stackView.snp_makeConstraints { make -> Void in
            make.top.equalTo(containerView)
            make.trailing.equalTo(containerView)
            make.leading.equalTo(containerView)
        }
        stackView.alignment = .Fill
        
        containerView.snp_makeConstraints {make in
            make.edges.equalTo(view)
        }
        
        let courseView = CourseCardView(frame: CGRectZero)
        if let course = self.course {
            CourseCardViewModel.onDashboard(course).apply(courseView, networkManager: self.environment.networkManager)
        }
        addShareButton(courseView)

        // Register tableViewCell
        tableView.registerClass(CourseDashboardCell.self, forCellReuseIdentifier: CourseDashboardCell.identifier)
        tableView.registerClass(CourseCertificateCell.self, forCellReuseIdentifier: CourseCertificateCell.identifier)
        
        prepareTableViewData()
        
        stackView.axis = .Vertical
        
        let spacer = UIView()
        stackView.addArrangedSubview(courseView)
        stackView.addArrangedSubview(spacer)
        stackView.addArrangedSubview(tableView)
        
        spacer.snp_makeConstraints {make in
            make.height.equalTo(spacerHeight)
            make.width.equalTo(self.containerView)
        }
        
        verifyAccess()
        
        self.progressController.hideProgessView()
    }

    private func addShareButton(courseView: UIView) {
        if let urlString = course?.course_about, url = NSURL(string: urlString) where environment.config.shouldEnableCourseSharing() {
            let shareButton = UIButton(type: .Custom)
            shareButton.setImage(UIImage(named: "share"), forState: .Normal)
            shareButton.oex_addAction({ [weak self] _ in
                let platformName = self?.environment.config.platformName() ?? ""
                let post = Strings.shareACourse(platformName: platformName)
                let controller = shareTextAndALink(post, url: url, analyticsCallback: { analyticsType in
                    self?.environment.analytics.trackCourseShared(self!.course!.course_id!, url: urlString, socialTarget: analyticsType)
                })
                self?.presentViewController(controller, animated: true, completion: nil)
                }, forEvents: .TouchUpInside)
            courseView.addSubview(shareButton)
            shareButton.snp_makeConstraints(closure: { (make) -> Void in
                make.trailing.equalTo(courseView).inset(10)
                make.bottom.equalTo(courseView).inset(10)
                make.height.equalTo(26)
                make.width.equalTo(20)
            })
        }
    }

    private func verifyAccess() {
        loadController.setupInController(self, contentView: containerView)

        guard let course = course else {
            loadController.state = LoadState.failed()
            return
        }
        
        if let access = course.courseware_access where !access.has_access {
            loadController.state = LoadState.failed(OEXCoursewareAccessError(coursewareAccess: access, displayInfo: course.start_display_info), icon: Icon.UnknownError)
        }
        else {
            loadController.state = .Loaded
        }

    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        environment.analytics.trackScreenWithName(OEXAnalyticsScreenCourseDashboard, courseID: self.course?.course_id, value: nil)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    public func prepareTableViewData() {
        if let certificateUrl = getCertificateUrl() {
            let item = CertificateDashboardItem(certificateImage: UIImage(named: "courseCertificate")!, certificateUrl: certificateUrl, action: {
                let url = NSURL(string: certificateUrl)!
                self.environment.router?.showCertificate(url, title: self.course?.name, fromController: self)
            })
            cellItems.append(item)
        }

        var item = StandardCourseDashboardItem(title: Strings.courseDashboardCourseware, detail: Strings.courseDashboardCourseDetail, icon : .Courseware) {[weak self] () -> Void in
            self?.showCourseware()
        }
        cellItems.append(item)
        
        if let courseID = course?.course_id where shouldShowDiscussions() {
            item = StandardCourseDashboardItem(title: Strings.courseDashboardDiscussion, detail: Strings.courseDashboardDiscussionDetail, icon: .Discussions) {[weak self] () -> Void in
                self?.showDiscussionsForCourseID(courseID)
            }
            cellItems.append(item)
        }
        
        item = StandardCourseDashboardItem(title: Strings.courseDashboardHandouts, detail: Strings.courseDashboardHandoutsDetail, icon: .Handouts) {[weak self] () -> Void in
            self?.showHandouts()
        }
        cellItems.append(item)
        
        item = StandardCourseDashboardItem(title: Strings.courseDashboardAnnouncements, detail: Strings.courseDashboardAnnouncementsDetail, icon: .Announcements) {[weak self] () -> Void in
            self?.showAnnouncements()
        }
        cellItems.append(item)
    }
    
    
    private func shouldShowDiscussions() -> Bool {
        let canShowDiscussions = self.environment.config.shouldEnableDiscussions() ?? false
        let courseHasDiscussions = course?.hasDiscussionsEnabled ?? false
        return canShowDiscussions && courseHasDiscussions
    }

    private func getCertificateUrl() -> String? {
        guard let courseID = course?.course_id where environment.config.shouldEnableCertificates() else { return nil }
        return environment.dataManager.enrollmentManager.enrolledCourseWithID(courseID)?.certificateUrl
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
    
    private func showCourseware() {
        if let course = self.course, courseID = course.course_id {
            self.environment.router?.showCoursewareForCourseWithID(courseID, fromController: self)
        }
    }
    
    private func showDiscussionsForCourseID(courseID: String) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
        self.environment.router?.showDiscussionTopicsFromController(self, courseID: courseID)
    }
    
    private func showHandouts() {
        if let course = self.course, courseID = course.course_id {
            self.environment.router?.showHandoutsFromController(self, courseID: courseID)
        }
    }
    
    private func showAnnouncements() {
        if let course_id = course?.course_id {
            self.environment.router?.showAnnouncementsForCourseWithID(course_id)
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.snp_updateConstraints{ make in

            make.height.equalTo(tableView.contentSize.height)//CGFloat(cellItems.count) * cellHeight)
        }
        containerView.contentSize = stackView.bounds.size
    }
}

// MARK: Testing
extension CourseDashboardViewController {
    
    internal func t_canVisitDiscussions() -> Bool {
        return self.cellItems.firstIndexMatching({ (item: CourseDashboardItem) in return (item is StandardCourseDashboardItem) && (item as! StandardCourseDashboardItem).icon == .Discussions }) != nil
    }

    internal func t_canVisitCertificate() -> Bool {
        return self.cellItems.firstIndexMatching({ (item: CourseDashboardItem) in return (item is CertificateDashboardItem)}) != nil
    }
    
    internal var t_state : LoadState {
        return self.loadController.state
    }
    
}

