//
//  TDLectureSubViewController.swift
//  edX
//
//  Created by Ben on 2017/7/12.
//  Copyright © 2017年 edX. All rights reserved.
//

import UIKit

class TDLectureSubViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
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
    private var whereFrom : Int
    private var username : String
    
    private let tableView = UITableView()
    private var loadingView : TDBaseView
    private let nonDataLabel = UILabel()
    private let dataArray = NSMutableArray()
    private var isForgound : Bool
    
    private let settingModel = VHStystemSetting.sharedSetting()
    
    init(environment: Environment, whereFrom: Int, username: String) {

        self.environment = environment
        self.whereFrom = whereFrom
        self.username = username
        self.isForgound = true

        self.loadingView = TDBaseView()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.whereFrom == 0 ? Strings.upcomingTitleText : Strings.finishedTitleText
        setViewConstaint()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(enterAppForground), name: "App_EnterForeground_Get_Code", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isForgound {
            self.loadingView = TDBaseView.init(loadingFrame: CGRectMake(0, 0, TDScreenWidth, TDScreenHeight))
            self.view.addSubview(self.loadingView)
            getData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.isForgound = false
    }
    
    func enterAppForground() {
        if self.whereFrom == 0 {
            refreshData()
        }
    }
    
    func refreshData() {
        getData()
    }
    
    func getData() {
        
        let baseTool = TDBaseToolModel()
        if !baseTool.networkingState() {
            return
        }
        
        let dic = NSMutableDictionary()
        dic.setValue(self.username, forKey: "username")
        dic.setValue((self.whereFrom + 1), forKey: "status")
        
        let url = "\(ELITEU_URL)/api/mobile/enterprise/v0.5/live/\(self.username)"
        let manager = AFHTTPSessionManager()
        manager.GET(url, parameters: dic, progress: nil, success: { (task, responseObject) in
            
            if self.dataArray.count != 0 {
                self.dataArray.removeAllObjects()
            }
            
            self.loadingView.hidden = true
            let responseDic : NSDictionary = responseObject as! NSDictionary
            
            let code = responseDic["code"]
            if code!.intValue == 200 {
                
                let dataArray: NSArray = responseDic["data"] as! NSArray
                if dataArray.count > 0 {
                    
                    for i in 0 ..< dataArray.count {
                        let model = TDLiveModel.mj_objectWithKeyValues(dataArray[i])
                        if (model != nil) {
                            self.dataArray.addObject(model)
                        }
                    }
                } else {
                    
                }
            } else {
                
            }
            
            self.tableView.mj_header.endRefreshing()
            
            self.nonDataLabel.hidden = self.dataArray.count != 0
            self.tableView.reloadData()
            
            }) { (task, error) in
                self.loadingView.hidden = true
                self.view.makeToast(Strings.networkConnetFail, duration: 1.08, position: CSToastPositionCenter)
        }
    }
    
    //MARK: tableView Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
        let model : TDLiveModel = self.dataArray[indexPath.section] as! TDLiveModel
        
        if indexPath.row == 0 {
        
            let cell = TDLiveMessageCell.init(style: .Default, reuseIdentifier: "TDLiveMessageCell")
            cell.selectionStyle = .None
            cell.whereFrom = self.whereFrom
            cell.model = model
            
            return cell
        } else {
            
            let cell = TDLiveBottomCell.init(style: .Default, reuseIdentifier: "TDLiveBottomCell")
            cell.selectionStyle = .None
            cell.whereFrom = self.whereFrom
            cell.model = model
            
            cell.enterButton.tag = indexPath.section
            cell.praticeButton.tag = indexPath.section
            cell.playButton.tag = indexPath.section

            cell.enterButton.addTarget(self, action: #selector(enterButtonAction(_:)), forControlEvents: .TouchUpInside)
            cell.praticeButton.addTarget(self, action: #selector(praticeButtonAction(_:)), forControlEvents: .TouchUpInside)
            cell.playButton.addTarget(self, action: #selector(playButtonAction(_:)), forControlEvents: .TouchUpInside)
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if  indexPath.row == 0 {
            return TDScreenWidth * 0.33 + 98
        } else {
            return 53
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func praticeButtonAction(sender: UIButton) { //习题
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        let model : TDLiveModel = self.dataArray[sender.tag] as! TDLiveModel
        let enrollDic : Dictionary = model.enroll
        if !enrollDic.isEmpty {
            
            let courseDic : NSDictionary = enrollDic["course"] as! NSDictionary
            let courseId : String = courseDic["id"] as! String
            showCourseware(courseId)
            
        } else {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
    }
    
    func enterButtonAction(sender: UIButton) { //进入讲座
        let model : TDLiveModel = self.dataArray[sender.tag] as! TDLiveModel
        loginVhLiveAccount(0, acount: model.third_user_id, activityID: model.vhall_webinar_id, detailStr: model.live_introduction)
    }
    
    func playButtonAction(sender: UIButton) { //视频回放
        let model : TDLiveModel = self.dataArray[sender.tag] as! TDLiveModel
        loginVhLiveAccount(1, acount: model.third_user_id, activityID: model.vhall_webinar_id, detailStr: model.live_introduction)
    }
    
    func loginVhLiveAccount(index: Int, acount: String, activityID: String, detailStr: String) {
        
        let baseTool = TDBaseToolModel()
        if !baseTool.networkingState() {
            return
        }
        
        self.settingModel.activityID = activityID
        self.settingModel.account = acount
        self.settingModel.password = "123456" //密码
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        VHallApi.loginWithAccount(settingModel.account, password: settingModel.password, success: {
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            index == 0 ? self.gotoWatchLiveVC(detailStr) : self.gotoWatchPlayBackVideo(detailStr)
            self.showMsg(Strings.enterSuccessful, delay: 1.08)
            
        }) { (error) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                self.showMsg(error.domain, delay: 1.08)
            })
        }
    }
    
    func showMsg(msg: String, delay: NSTimeInterval) {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = MBProgressHUDModeText
        hud.labelText = msg
        hud.margin = 10.0
        hud.removeFromSuperViewOnHide = true
        hud.hide(true, afterDelay: delay)
    }
    
    func gotoWatchLiveVC(detailStr: String) { //直播
        
        let watchVc = WatchLiveViewController()
        watchVc.roomId = settingModel.activityID //活动id
        watchVc.kValue = settingModel.kValue
        watchVc.bufferTimes = settingModel.bufferTimes
        watchVc.detailStr = detailStr
        
        self.presentViewController(watchVc, animated: true, completion: nil)
    }
    
    func gotoWatchPlayBackVideo(detailStr: String) { //回放
        
        let watchVC = WatchPlayBackViewController()
        watchVC.roomId = settingModel.activityID; //活动id
        watchVC.kValue = settingModel.kValue;
        watchVC.detailStr = detailStr
        self.presentViewController(watchVC, animated: true, completion: nil)
    }
    
    private func showCourseware(courseID: String) { //习题
        self.environment.router?.showCoursewareForCourseWithID(courseID, fromController: self)
    }

    func setViewConstaint() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .None
        self.tableView.tableFooterView = UIView.init()
        self.tableView.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        let header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(refreshData))
        header.lastUpdatedTimeLabel.hidden = true
        self.tableView.mj_header = header
        
        self.view.addSubview(self.tableView)
        
        self.tableView.snp_makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view)
        }
        
        self.nonDataLabel.font = UIFont.init(name: "OpenSans", size: 16)
        self.nonDataLabel.textColor = OEXStyles.sharedStyles().baseColor8()
        self.nonDataLabel.textAlignment = .Center
        self.nonDataLabel.text = Strings.noLiveLectureText
        self.tableView.addSubview(self.nonDataLabel)
        
        self.nonDataLabel.snp_makeConstraints { (make) in
            make.center.equalTo(self.tableView.center)
        }
        
        self.nonDataLabel.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
