//
//  CourseOutlineViewController.swift
//  edX
//
//  Created by Akiva Leffert on 4/30/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

import Foundation
import UIKit

///Controls the space between the ModeChange icon and the View on Web Icon for CourseOutlineViewController and CourseContentPageViewController. Changing this constant changes the spacing in both places.
public let barButtonFixedSpaceWidth : CGFloat = 20

public class CourseOutlineViewController :
    UIViewController,
    CourseBlockViewController,
    CourseOutlineTableControllerDelegate,
    CourseOutlineModeControllerDelegate,
    CourseContentPageViewControllerDelegate,
    CourseLastAccessedControllerDelegate,
    OpenOnWebControllerDelegate,
    PullRefreshControllerDelegate
{

    public struct Environment {
        private let analytics : OEXAnalytics?
        private let dataManager : DataManager
        private let networkManager : NetworkManager
        private let reachability : Reachability
        private weak var router : OEXRouter?
        private let styles : OEXStyles
        
        public init(analytics : OEXAnalytics?, dataManager : DataManager, networkManager : NetworkManager, reachability : Reachability, router : OEXRouter, styles : OEXStyles) {
            self.analytics = analytics
            self.dataManager = dataManager
            self.networkManager = networkManager
            self.reachability = reachability
            self.router = router
            self.styles = styles
        }
    }
    
    private var rootID : CourseBlockID?
    private var environment : Environment
    
    private let courseQuerier : CourseOutlineQuerier
    private let tableController : CourseOutlineTableController
    
    private let blockIDStream = BackedStream<CourseBlockID?>()
    private let headersLoader = BackedStream<CourseOutlineQuerier.BlockGroup>()
    private let rowsLoader = BackedStream<[CourseOutlineQuerier.BlockGroup]>()
    
    private let loadController : LoadStateViewController
    private let insetsController : ContentInsetsController
    private let modeController : CourseOutlineModeController
    private var lastAccessedController : CourseLastAccessedController
    
    
    /// Strictly a test variable used as a trigger flag. Not to be used out of the test scope
    private var t_hasTriggeredSetLastAccessed = false
    
    public var blockID : CourseBlockID? {
        return blockIDStream.value ?? nil
    }
    
    public var courseID : String {
        return courseQuerier.courseID
    }
    
    private lazy var webController : OpenOnWebController = OpenOnWebController(delegate: self)
    
    public init(environment: Environment, courseID : String, rootID : CourseBlockID?) {
        self.rootID = rootID
        self.environment = environment
        courseQuerier = environment.dataManager.courseDataManager.querierForCourseWithID(courseID)
        
        loadController = LoadStateViewController()
        insetsController = ContentInsetsController()
        
        modeController = environment.dataManager.courseDataManager.freshOutlineModeController()
        let outlineEnvironment = CourseOutlineTableController.Environment(dataManager : environment.dataManager)
        tableController = CourseOutlineTableController(environment : outlineEnvironment, courseID: courseID)
        
        lastAccessedController = CourseLastAccessedController(blockID: rootID , dataManager: environment.dataManager, networkManager: environment.networkManager, courseQuerier: courseQuerier)
        
        super.init(nibName: nil, bundle: nil)
        
        lastAccessedController.delegate = self
        modeController.delegate = self
        
        addChildViewController(tableController)
        tableController.didMoveToParentViewController(self)
        tableController.delegate = self
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        fixedSpace.width = barButtonFixedSpaceWidth
        navigationItem.rightBarButtonItems = [webController.barButtonItem,fixedSpace,modeController.barItem]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
        
        self.blockIDStream.backWithStream(Stream(value: rootID))
    }

    public required init?(coder aDecoder: NSCoder) {
        // required by the compiler because UIViewController implements NSCoding,
        // but we don't actually want to serialize these things
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = self.environment.styles.standardBackgroundColor()
        view.addSubview(tableController.view)
        
        loadController.setupInController(self, contentView:tableController.view)
        tableController.refreshController.setupInScrollView(tableController.tableView)
        tableController.refreshController.delegate = self
        
        insetsController.setupInController(self, scrollView : self.tableController.tableView)
        insetsController.supportOfflineMode(styles: environment.styles)
        insetsController.addSource(tableController.refreshController)
        
        self.view.setNeedsUpdateConstraints()
        
        addListeners()
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        lastAccessedController.loadLastAccessed(forMode: modeController.currentMode)
        lastAccessedController.saveLastAccessed()
        let stream = joinStreams(courseQuerier.rootID, courseQuerier.blockWithID(blockID))
        stream.extendLifetimeUntilFirstResult (success :
            { (rootID, block) in
                if self.blockID == rootID || self.blockID == nil {
                    self.environment.analytics?.trackScreenWithName(OEXAnalyticsScreenCourseOutline, courseID: self.courseID, value: nil)
                }
                else {
                    self.environment.analytics?.trackScreenWithName(OEXAnalyticsScreenSectionOutline, courseID: self.courseID, value: block.internalName)
                }
            },
            failure: {
                Logger.logError("ANALYTICS", "Unable to load block: \($0)")
            }
            
        )
    }
    
    override public func updateViewConstraints() {
        loadController.insets = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: self.bottomLayoutGuide.length, right : 0)
        
        tableController.view.snp_updateConstraints {make in
            make.edges.equalTo(self.view)
        }
        super.updateViewConstraints()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.insetsController.updateInsets()
    }
    
    private func setupNavigationItem(block : CourseBlock) {
        self.navigationItem.title = block.displayName
        self.webController.info = OpenOnWebController.Info(courseID : courseID, blockID : block.blockID, supported : block.displayType.isUnknown, URL: block.webURL)
    }
    
    public func viewControllerForCourseOutlineModeChange() -> UIViewController {
        return self
    }
    
    public func courseOutlineModeChanged(courseMode: CourseOutlineMode) {
        headersLoader.removeAllBackings()
        lastAccessedController.loadLastAccessed(forMode: courseMode)
        reload()
    }
    
    private func reload() {
        self.blockIDStream.backWithStream(Stream(value : self.blockID))
    }
    
    private func emptyState() -> LoadState {
        switch modeController.currentMode {
        case .Full:
            return LoadState.failed(NSError.oex_courseContentLoadError())
        case .Video:
            let style = loadController.messageStyle
            let message = style.apply(Strings.noVideosTryModeSwitcher)
            let iconText = self.modeController.currentIcon.attributedTextWithStyle(style, inline: true)
            let formattedMessage = message(iconText)
            let accessibilityMessage = Strings.noVideosTryModeSwitcher(modeSwitcher: Strings.courseModePickerDescription)
            return LoadState.empty(icon: Icon.CourseModeFull, attributedMessage : formattedMessage, accessibilityMessage : accessibilityMessage)
        }
    }
    
    private func showErrorIfNecessary(error : NSError) {
        if self.loadController.state.isInitial {
            self.loadController.state = LoadState.failed(error)
        }
    }
    
    private func loadedHeaders(headers : CourseOutlineQuerier.BlockGroup) {
        self.setupNavigationItem(headers.block)
        let children = headers.children.map {header in
            return self.courseQuerier.childrenOfBlockWithID(header.blockID, forMode: self.modeController.currentMode)
        }
        rowsLoader.backWithStream(joinStreams(children))
    }
    
    private func addListeners() {
        blockIDStream.listen(self,
            success: {[weak self] blockID in
                self?.backHeadersLoaderWithBlockID(blockID)
            },
            failure: {[weak self] error in
                self?.headersLoader.backWithStream(Stream(error: error))
        })
        
        headersLoader.listen(self,
            success: {[weak self] headers in
                self?.loadedHeaders(headers)
            },
            failure: {[weak self] error in
                self?.rowsLoader.backWithStream(Stream(error: error))
                self?.showErrorIfNecessary(error)
            }
        )
        
        rowsLoader.listen(self,
            success : {[weak self] groups in
                if let owner = self {
                    owner.tableController.groups = groups
                    owner.tableController.tableView.reloadData()
                    owner.loadController.state = groups.count == 0 ? owner.emptyState() : .Loaded
                }
            },
            failure : {[weak self] error in
                self?.showErrorIfNecessary(error)
            },
            finally: {[weak self] in
                self?.tableController.refreshController.endRefreshing()
            }
        )
    }
    
    private func backHeadersLoaderWithBlockID(blockID : CourseBlockID?) {
        self.headersLoader.backWithStream(courseQuerier.childrenOfBlockWithID(blockID, forMode: modeController.currentMode))
    }

    // MARK: Outline Table Delegate
    
    func outlineTableControllerChoseShowDownloads(controller: CourseOutlineTableController) {
        environment.router?.showDownloadsFromViewController(self)
    }
    
    private func canDownloadVideo() -> Bool {
        let hasWifi = environment.reachability.isReachableViaWiFi() ?? false
        let onlyOnWifi = environment.dataManager.interface?.shouldDownloadOnlyOnWifi ?? false
        return !onlyOnWifi || hasWifi
    }
    
    func outlineTableController(controller: CourseOutlineTableController, choseDownloadVideos videos: [OEXHelperVideoDownload], rootedAtBlock block:CourseBlock) {
        guard canDownloadVideo() else {
            self.loadController.showOverlayError(Strings.noWifiMessage)
            return
        }
        
        self.environment.dataManager.interface?.downloadVideos(videos)
        
        let courseID = self.courseID
        let analytics = environment.analytics
        
        courseQuerier.parentOfBlockWithID(block.blockID).listenOnce(self, success:
            { parentID in
                analytics?.trackSubSectionBulkVideoDownload(parentID, subsection: block.blockID, courseID: courseID, videoCount: videos.count)
            },
            failure: {error in
                Logger.logError("ANALYTICS", "Unable to find parent of block: \(block). Error: \(error.localizedDescription)")
            }
        )
    }
    
    func outlineTableController(controller: CourseOutlineTableController, choseDownloadVideoForBlock block: CourseBlock) {
        
        guard canDownloadVideo() else {
            self.loadController.showOverlayError(Strings.noWifiMessage)
            return
        }
        
        self.environment.dataManager.interface?.downloadVideosWithIDs([block.blockID], courseID: courseID)
        environment.analytics?.trackSingleVideoDownload(block.blockID, courseID: courseID, unitURL: block.webURL?.absoluteString)
    }
    
    func outlineTableController(controller: CourseOutlineTableController, choseBlock block: CourseBlock, withParentID parent : CourseBlockID) {
        self.environment.router?.showContainerForBlockWithID(block.blockID, type:block.displayType, parentID: parent, courseID: courseQuerier.courseID, fromController:self)
    }
    
    private func expandAccessStream(stream : Stream<CourseLastAccessed>) -> Stream<(CourseBlock, CourseLastAccessed)> {
        return stream.transform {[weak self] lastAccessed in
            return joinStreams(self?.courseQuerier.blockWithID(lastAccessed.moduleId) ?? Stream<CourseBlock>(), Stream(value: lastAccessed))
        }

    }
    
    //MARK: PullRefreshControllerDelegate
    public func refreshControllerActivated(controller: PullRefreshController) {
        courseQuerier.needsRefresh = true
        reload()
    }
    
    //MARK: CourseContentPageViewControllerDelegate
    public func courseContentPageViewController(controller: CourseContentPageViewController, enteredBlockWithID blockID: CourseBlockID, parentID: CourseBlockID) {
        self.blockIDStream.backWithStream(courseQuerier.parentOfBlockWithID(parentID))
        self.tableController.highlightedBlockID = blockID
    }
    
    //MARK: LastAccessedControllerDeleagte
    public func courseLastAccessedControllerDidFetchLastAccessedItem(item: CourseLastAccessed?) {
        if let lastAccessedItem = item {
            self.tableController.showLastAccessedWithItem(lastAccessedItem)
        }
        else {
            self.tableController.hideLastAccessed()
        }
        
    }
    
    public func presentationControllerForOpenOnWebController(controller: OpenOnWebController) -> UIViewController {
        return self
    }
}

extension CourseOutlineViewController {
    
    public func t_setup() -> Stream<Void> {
        return rowsLoader.map { _ in
        }
    }
    
    public func t_currentChildCount() -> Int {
        return tableController.groups.count
    }
    
    public func t_populateLastAccessedItem(item : CourseLastAccessed) -> Bool {
        self.tableController.showLastAccessedWithItem(item)
        return self.tableController.tableView.tableHeaderView != nil

    }
    
    public func t_didTriggerSetLastAccessed() -> Bool {
        return t_hasTriggeredSetLastAccessed
    }
    
}
