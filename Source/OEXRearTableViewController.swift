//
//  OEXRearTableController.swift
//  edX
//
//  Created by Michael Katz on 9/21/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

import Foundation
import MessageUI

import edXCore

private enum OEXRearViewOptions: Int {
    case UserProfile, MyCourse, MyVideos, FindCourses, SkyDrive, UserCenter , MySettings, SubmitFeedback, Debug, Logout
}

private let versionButtonStyle = OEXTextStyle(weight:.Normal, size:.XXSmall, color: OEXStyles.sharedStyles().neutralWhite())

class OEXRearTableViewController : UITableViewController {

    // TODO replace this with a proper injection when we nuke the storyboard
    struct Environment {
        let analytics = OEXRouter.sharedRouter().environment.analytics
        let config = OEXRouter.sharedRouter().environment.config
        let interface = OEXRouter.sharedRouter().environment.interface
        let networkManager = OEXRouter.sharedRouter().environment.networkManager
        let session = OEXRouter.sharedRouter().environment.session
        let userProfileManager = OEXRouter.sharedRouter().environment.dataManager.userProfileManager
        weak var router = OEXRouter.sharedRouter()
    }
    
    @IBOutlet var coursesLabel: UILabel!
    @IBOutlet var videosLabel: UILabel!
    @IBOutlet var findCoursesLabel: UILabel!
    @IBOutlet weak var skyDriveLabel: UILabel!
    @IBOutlet var assistantLabel: UILabel!
    @IBOutlet var settingsLabel: UILabel!
    @IBOutlet var submitFeedbackLabel: UILabel!
    @IBOutlet var logoutButton: UIButton!
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userEmailLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var companyImage: UIImageView!
    @IBOutlet var userProfilePicture: UIImageView!
    @IBOutlet weak var appVersionButton: UIButton!
    @IBOutlet var userContentView: UIView!
    @IBOutlet weak var redImageView: UIImageView!
    
    lazy var environment = Environment()
    var profileFeed: Feed<UserProfile>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        LanguageChangeTool.initUserLanguage()
        TDNotificationCenter().addObserver(self, selector: #selector(LanguageChangeAction), name: "languageSelectedChange", object: nil)
        
        setupProfileLoader()
        updateUIWithUserInfo()
        
        self.view.backgroundColor = OEXStyles.sharedStyles().baseColor6()
        self.tableView.backgroundColor = OEXStyles.sharedStyles().baseColor6()
        
//        logoutButton.setBackgroundImage(UIImage(named: "bt_logout_active"), forState: .Highlighted)
        logoutButton.backgroundColor = OEXStyles.sharedStyles().baseColor7()
        logoutButton.layer.cornerRadius = 4.0
    
        LanguageChangeAction()
        
        setNaturalTextAlignment()
        setAccessibilityLabels()
        
        if !environment.config.profilesEnabled {
            //hide the profile image while not display the feature
            //there is still a little extra padding, but this will just be a temporary issue anyway
            userProfilePicture.hidden = true
            let widthConstraint = userProfilePicture.constraints.filter { $0.identifier == "profileWidth" }[0]
            let heightConstraint = userProfilePicture.constraints.filter { $0.identifier == "profileHeight" }[0]
            widthConstraint.constant = 0
            heightConstraint.constant = 85
        }

        //Listen to notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OEXRearTableViewController.dataAvailable(_:)), name: NOTIFICATION_URL_RESPONSE, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let profileCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: OEXRearViewOptions.UserProfile.rawValue, inSection: 0)) {
            profileCell.accessibilityLabel = TDLocalizeSelectSwift("ACCESSIBILITY.LEFT_DRAWER.PROFILE_LABEL").oex_formatWithParameters(["user_name" : environment.session.currentUser?.name ?? "", "user_email" : environment.session.currentUser?.email ?? ""])
            profileCell.accessibilityHint = TDLocalizeSelectSwift("ACCESSIBILITY.LEFT_DRAWER.PROFILE_HINT")
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.tableView.userInteractionEnabled = true
    }
    
    func LanguageChangeAction() {
        
        //        let environmentName = self.environment.config.environmentName()
        //        let appVersion = NSBundle.mainBundle().oex_buildVersionString()
        //        appVersionButton.setAttributedTitle(versionButtonStyle.attributedStringWithText(Strings.versionDisplay(number: appVersion, environment: environmentName)), forState:.Normal)

        let baseTool = TDBaseToolModel()
        let versionStr = baseTool.getAppVersionNum(1)
        appVersionButton.setTitle(versionStr , forState: .Normal)
        appVersionButton.accessibilityTraits = UIAccessibilityTraitStaticText

        coursesLabel.text = TDLocalizeSelectSwift("MY_COURSES")
        videosLabel.text = TDLocalizeSelectSwift("MY_VIDEOS")
        findCoursesLabel.text = TDLocalizeSelectSwift("FIND_COURSES")
        skyDriveLabel.text = TDLocalizeSelectSwift("ENTERPRISE_SKYDRIVE")
        assistantLabel.text = TDLocalizeSelectSwift("USER_CENTER")
        settingsLabel.text = TDLocalizeSelectSwift("MY_SETTINGS")
        submitFeedbackLabel.text = TDLocalizeSelectSwift("SUBMIT_FEEDBACK.OPTION_TITLE")
        logoutButton.setTitle(TDLocalizeSelectSwift("LOGOUT"), forState: .Normal)
        loginButton.setTitle(TDLocalizeSelectSwift("SIGN_IN"), forState: .Normal)
        redImageView.hidden = true
    }
    
    private func setupProfileLoader() {
        
        guard environment.config.profilesEnabled else { return }
        profileFeed = self.environment.userProfileManager.feedForCurrentUser()
        
        profileFeed?.output.listen(self,  success: { profile in
            self.userProfilePicture.remoteImage = profile.image(self.environment.networkManager)
            
            self.companyImage.contentMode = .ScaleAspectFit
            if profile.logoUrl != nil {
                
                if profile.logoUrl?.characters.count == 0 {
                    self.companyImage.image = UIImage.init(named: "E_Logo_Enterprise")
                }
                else {
                    SDImageCache.sharedImageCache().cleanDisk()
                    let apiHostUrl = OEXConfig.sharedConfig().apiHostURL()
                    var companyImageStr = (apiHostUrl?.absoluteString)! +  profile.logoUrl!
                    companyImageStr = companyImageStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.init(charactersInString: "`#%^{}\"[]|\\<> ").invertedSet)! //处理图片链接中的中文和空格
                    
                    let url = NSURL.init(string: companyImageStr)
                    self.companyImage.sd_setImageWithURL(url, placeholderImage: UIImage.init(named: "logobg"))
                }
            }
            else {
                self.companyImage.image = UIImage.init(named: "E_Logo_Enterprise")
            }
            
            if (profile.nickname != nil) == true {//如果昵称不为空,显示昵称
                self.userNameLabel.text = profile.nickname
            }
            if (profile.nickname == nil) == true {//如果昵称为空,显示用户名
                if profile.name != profile.username {
                    self.userNameLabel.text = profile.name
                }
                else {
                    self.userNameLabel.text = TDLocalizeSelectSwift("NO_NAME")
                }
            }
            
            let baseTool = TDBaseToolModel.init()
            if profile.phone != nil {//如果手机号不为空,显示手机号
                self.userEmailLabel.text = baseTool.setPhoneStyle(profile.phone)
            }
            
            if profile.phone == nil{//如果手机为空,显示邮箱
                self.userEmailLabel.text = baseTool.setEmailStyle(profile.email)
            }
            
            if profile.is_receiver == true {
                self.redImageView.hidden = profile.unreplied_count == 0 && profile.unsolved_msg_count == 0
            }
            else{
                self.redImageView.hidden = profile.unsolved_msg_count == 0;
            }
            
            }, failure : { _ in
                Logger.logError("Profiles", "Unable to fetch profile")
        })
    }
    
    private func updateUIWithUserInfo() {
//        if let currentUser = environment.session.currentUser {
//            userNameLabel.text = currentUser.name
//            userEmailLabel.text = currentUser.email
//        }
        
        let currentUser = environment.session.currentUser
        if  (currentUser != nil){  //登录状态
            
            if (currentUser!.nick_name != nil) == true { //如果昵称不为空,显示昵称
                userNameLabel.text = currentUser!.nick_name
            }
            if (currentUser!.nick_name == nil) == true {//如果昵称为空,显示用户名
                if currentUser?.name != currentUser?.username {
                    userNameLabel.text = currentUser!.name
                } else {
                    userNameLabel.text = TDLocalizeSelectSwift("NO_NAME")
                }
            }
            
            let baseTool = TDBaseToolModel.init()
            if currentUser!.mobile != nil { //如果手机号不为空,显示手机号
                userEmailLabel.text = baseTool.setPhoneStyle(currentUser!.mobile)
            }
            if currentUser!.mobile == nil{ //如果手机为空,显示邮箱
                userEmailLabel.text = baseTool.setEmailStyle(currentUser!.email)
            }
            
            setButtonHiddenOrNo(true)
        } else {
            setButtonHiddenOrNo(false)
        }
         profileFeed?.refresh()
    }
    
    func setButtonHiddenOrNo(isHidden: Bool) {
        
        loginButton.layer.cornerRadius = 5.0
        loginButton.backgroundColor = OEXStyles.sharedStyles().baseColor2()
        
        loginButton.hidden = true
        userNameLabel.hidden = true
        userEmailLabel.hidden = true
        userProfilePicture.hidden = true

        logoutButton.hidden = true
        appVersionButton.hidden = true
        
        //        loginButton.hidden = isHidden
        //        userNameLabel.hidden = !isHidden
        //        userEmailLabel.hidden = !isHidden
        //        logoutButton.hidden = !isHidden
    }
    
    private func setNaturalTextAlignment() {
        coursesLabel.textAlignment = .Natural
        videosLabel.textAlignment = .Natural
        findCoursesLabel.textAlignment = .Natural
        skyDriveLabel.textAlignment = .Natural
        settingsLabel.textAlignment = .Natural
        submitFeedbackLabel.textAlignment = .Natural
        userNameLabel.textAlignment = .Natural
        userNameLabel.adjustsFontSizeToFitWidth = true
        userEmailLabel.textAlignment = .Natural
    }
    
    private func setAccessibilityLabels() {
        userNameLabel.accessibilityLabel = userNameLabel.text
        userEmailLabel.accessibilityLabel = userEmailLabel.text
        coursesLabel.accessibilityLabel = coursesLabel.text
        videosLabel.accessibilityLabel = videosLabel.text
        findCoursesLabel.accessibilityLabel = findCoursesLabel.text
        skyDriveLabel.accessibilityLabel = skyDriveLabel.text
        settingsLabel.accessibilityLabel = settingsLabel.text
        submitFeedbackLabel.accessibilityLabel = submitFeedbackLabel.text
        logoutButton.accessibilityLabel = logoutButton.titleLabel!.text
//        userProfilePicture.accessibilityLabel = TDLocalizeSelectSwift("ACCESSIBILITY_USER_AVATAR")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return OEXStyles.sharedStyles().standardStatusBarStyle()
    }
    
    override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if let separatorImage = cell.contentView.viewWithTag(10) {
            separatorImage.hidden = true
        }
    }
    
    override func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if let separatorImage = cell.contentView.viewWithTag(10) {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                separatorImage.hidden = false
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let option = OEXRearViewOptions(rawValue: indexPath.row) {
            
            switch option {
//            case .UserProfile:
//                guard environment.config.profilesEnabled else { break }
//                guard let currentUserName = environment.session.currentUser?.username else { return }
//                environment.router?.showProfileForUsername(username: currentUserName)
            case .MyCourse:
                tableView.userInteractionEnabled = false
                environment.router?.showMyCourses()
                
            case .MyVideos:
                tableView.userInteractionEnabled = false
                environment.router?.showMyVideos()
                
            case .FindCourses:
                tableView.userInteractionEnabled = false
                environment.router?.showCourseCatalog(nil)
                environment.analytics.trackUserFindsCourses()
                
            case .SkyDrive:
                tableView.userInteractionEnabled = false
                environment.router?.showEnterpriseSkydrive()
                
            case .UserCenter:
                guard environment.config.profilesEnabled else { break }
                guard let currentUserName = environment.session.currentUser?.username else { return }
                tableView.userInteractionEnabled = false
                environment.router?.showProfileForUsername(username: currentUserName)
                
            case .MySettings:
                tableView.userInteractionEnabled = false
                environment.router?.showMySettings()
                
            case .SubmitFeedback:
                launchEmailComposer()
                
            case .Debug:
                environment.router?.showDebugPane()
            case .Logout:
                break
            default:
                break
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let logoutHeight : CGFloat = TDScreenWidth * 5/6 * 0.53
        if indexPath.row == OEXRearViewOptions.Debug.rawValue && !environment.config.shouldShowDebug() {
            return 0
        }
        else if indexPath.row == OEXRearViewOptions.SubmitFeedback.rawValue {
            return 0
        }
        else if indexPath.row == OEXRearViewOptions.FindCourses.rawValue && !environment.config.courseEnrollmentConfig.isCourseDiscoveryEnabled() {
            return 0
        }
        else if indexPath.row == OEXRearViewOptions.Logout.rawValue {
            
            let screenHeight = UIScreen.mainScreen().bounds.height
            let tableviewHeight : CGFloat = 300 + logoutHeight
            return screenHeight - tableviewHeight
        }
        else if indexPath.row == OEXRearViewOptions.UserProfile.rawValue {
            remarkCompayConstraint()
            return logoutHeight
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    func remarkCompayConstraint() {
        self.tableView.backgroundColor = OEXStyles.sharedStyles().baseColor6()
        self.userContentView.backgroundColor = OEXStyles.sharedStyles().baseColor6()
        
        self.companyImage.snp_remakeConstraints { (make) in
            make.left.lessThanOrEqualTo(self.userContentView.snp_left).offset(48)
            make.right.greaterThanOrEqualTo(self.userContentView.snp_right).offset(-48)
            make.top.lessThanOrEqualTo(self.userContentView.snp_top).offset(48)
            make.bottom.greaterThanOrEqualTo(self.userContentView.snp_bottom).offset(-48)
        }
    }
    
    
    @IBAction func loginButtonClicked(sender: UIButton) {
        logoutAction()
    }
    
    @IBAction func logoutClicked(sender: UIButton) {
        logoutAction()
    }
    
    func logoutAction() {
//        OEXFileUtility.nukeUserPIIData()
        self.environment.router?.logoutAction()
    }
    
    func dataAvailable(notification: NSNotification) {
        let successString = notification.userInfo![NOTIFICATION_KEY_STATUS] as? String;
        let URLString = notification.userInfo![NOTIFICATION_KEY_URL] as? String;
        
        if successString == NOTIFICATION_VALUE_URL_STATUS_SUCCESS && URLString == environment.interface?.URLStringForType(URL_USER_DETAILS) {
            updateUIWithUserInfo()
        }
    }
}

extension OEXRearTableViewController : MFMailComposeViewControllerDelegate {

    func launchEmailComposer() {
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertView(title: TDLocalizeSelectSwift("EMAIL_ACCOUNT_NOT_SET_UP_TITLE"),
                message: TDLocalizeSelectSwift("EMAIL_ACCOUNT_NOT_SET_UP_MESSAGE"),
                delegate: nil,
                cancelButtonTitle: TDLocalizeSelectSwift("OK"))
            alert.show()
        } else {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.navigationBar.tintColor = OEXStyles.sharedStyles().navigationItemTintColor()
            mail.setSubject(TDLocalizeSelectSwift("SUBMIT_FEEDBACK.MESSAGE_SUBJECT"))

            mail.setMessageBody(EmailTemplates.supportEmailMessageTemplate(), isHTML: false)
            if let fbAddress = environment.config.feedbackEmailAddress() {
                mail.setToRecipients([fbAddress])
            }
            presentViewController(mail, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
