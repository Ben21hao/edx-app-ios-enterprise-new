//
//  TDUserCenterViewController.swift
//  edX
//
//  Created by Elite Edu on 17/4/14.
//  Copyright © 2017年 edX. All rights reserved.
//

import UIKit

class TDUserCenterViewController: OfflineSupportViewController,UITableViewDelegate,UserProfilePresenterDelegate {
    typealias Environment = protocol<
        OEXAnalyticsProvider,
        OEXConfigProvider,
        NetworkManagerProvider,
        OEXRouterProvider,
        ReachabilityProvider,
        DataManagerProvider,
        OEXInterfaceProvider
    >
    
    private let environment : Environment
    private let editable: Bool
    let session = OEXRouter.sharedRouter().environment.session
    
    private let tableView = UITableView.init()
    private let loadController = LoadStateViewController()
    private let contentView = TDUserCenterView(frame: CGRectZero)
    
    private let presenter : UserProfilePresenter
    convenience init(environment : protocol<UserProfileNetworkPresenter.Environment, Environment>, username : String, editable: Bool) {
        
        let presenter = UserProfileNetworkPresenter(environment: environment, username: username)
        self.init(environment: environment, presenter: presenter, editable: editable)
        presenter.delegate = self
    }
    
    init(environment: Environment, presenter: UserProfilePresenter, editable: Bool) {
        self.editable = editable
        self.environment = environment
        self.presenter = presenter
        super.init(env: environment)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        LanguageChangeTool.initUserLanguage()
        TDNotificationCenter().addObserver(self, selector: #selector(languageChangeAction), name: "languageSelectedChange", object: nil)
        
        setUpViewConstraint()        
        addProfileListener()//数据请求
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.titleViewLabel.text = TDLocalizeSelectSwift("USER_CENTER")
        
        environment.analytics.trackScreenWithName(OEXAnalyticsScreenProfileView)
        presenter.refresh()
    }
    
    override func reloadViewData() {
        presenter.refresh()
    }
    
    private func addProfileListener() {
        let editable = self.editable
        let networkManager = environment.networkManager
        
        presenter.profileStream.listen(self, success: { [weak self] profile in
            
            // TODO: Refactor UserProfileView to take a dumb model so we don't need to pass it a network manager
            self?.contentView.populateFields(profile, editable: editable, networkManager: networkManager)
            self?.loadController.state = .Loaded
            
            }, failure : { [weak self] error in
                self?.loadController.state = LoadState.failed(error, message: TDLocalizeSelectSwift("PROFILE.UNABLE_TO_GET"))
            })
    }
    
    func languageChangeAction() {
        self.titleViewLabel.text = TDLocalizeSelectSwift("USER_CENTER")
        self.tableView.reloadData()
    }
    
    //MARK: UI
    func setUpViewConstraint() {
        
        self.contentView.clickHeaderImageHandle = { () in
            self.gotoAuthenVc()
        }
        self.contentView.tableView.delegate = self
        self.view.addSubview(self.contentView)
        
        self.contentView.snp_makeConstraints {make in
            make.left.right.bottom.top.equalTo(self.view)
        }
    }
    
    func gotoAuthenVc() {//身份验证
        if contentView.statusCode == 400  { // 400 未认证
            let photoViewController = TDTakePictureViewController()
            photoViewController.username = session.currentUser?.username
            self.navigationController?.pushViewController(photoViewController, animated: true)
            
        } else if contentView.statusCode == 200 || contentView.statusCode == 202 { //200 提交成功，202 认证失败
            let messageShowController = TDInformationDetailViewController()
            messageShowController.username = session.currentUser?.username
            self.navigationController?.pushViewController(messageShowController, animated: true)
            
        } else if contentView.statusCode == 201 { //已认证
            let successViewController = TDAuthenSuccessViewController()
            self.navigationController?.pushViewController(successViewController, animated: true)
        }
    }
    
    func gotoCouponVc() { //优惠券

        let userCouponVC = TDCouponViewController()
        userCouponVC.username = session.currentUser?.username //传当前用户名
        self.navigationController?.pushViewController(userCouponVC, animated: true)
    }
    
    func gotoRechargeCoinVc() { //充值宝典
        let rechargeVc = TDRechargeViewController()
        rechargeVc.username = session.currentUser?.username //传当前用户名
        rechargeVc.whereFrom = 0
        self.navigationController?.pushViewController(rechargeVc, animated: true)
    }
    
    func gotoWaiForPayVc() { //待支付订单
        
        let userCouponVC1 = TDWaitforPayViewController()
        userCouponVC1.username = session.currentUser?.username  //传当前用户名
        self.navigationController?.pushViewController(userCouponVC1, animated: true)
    }

    func gotoAssistantServiceVc() {
        let assistantVc = TDAssistantServiceViewController()
        assistantVc.username = session.currentUser?.username
        assistantVc.company_id = session.currentUser?.company_id
        self.navigationController?.pushViewController(assistantVc, animated: true)
    }
    
    func gotoLiveView() {
//        let liviewVc = TDLiveViewController() //oc写的
//        liviewVc.username = session.currentUser?.username
//        self.navigationController?.pushViewController(liviewVc, animated: true)
        
        let username = session.currentUser?.username
        let liveView = TDLectureLiveViewController.init(environment: self.environment, username: username!) //swift写的控制器
        self.navigationController?.pushViewController(liveView, animated: true)
    }
    
    //MARK: tableview Delegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 98
        }
        if indexPath.section == 1 && indexPath.row == 1 {
            return 0
        }
//        else if indexPath.section == 2 && indexPath.row == 0 {
//            return 0
//        }
        return 75
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 8
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            if editable {
                self.environment.router?.showProfileEditorFromController(self)
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                gotoRechargeCoinVc()
            case 1:
                gotoCouponVc()
            default:
                gotoWaiForPayVc()
            }
        } else {
            if indexPath.row == 0 {
                gotoLiveView()
            } else {
                gotoAssistantServiceVc()
            }
        }
    }
    
    //MARK: UserProfilePresenterDelegate
    func presenter(presenter: UserProfilePresenter, choseShareURL url: NSURL) {
        let message = TDLocalizeSelectSwift("ACCOMPLISHMENTS.SHARE_TEXT").oex_formatWithParameters(["platform_name" : self.environment.config.platformName()])
        let controller = UIActivityViewController(
            activityItems: [message, url],
            applicationActivities: nil
        )
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

