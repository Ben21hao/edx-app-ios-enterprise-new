//
//  ServerChangedChecker.swift
//  edX
//
//  Created by Akiva Leffert on 2/26/16.
//  Copyright © 2016 edX. All rights reserved.
//

import Foundation


@objc class ServerChangedChecker : NSObject {
    private let defaultsKey = "OEXLastUsedAPIHostURL"

    private var lastUsedAPIHostURL : NSURL? {
        get {
            return NSUserDefaults.standardUserDefaults().URLForKey(defaultsKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setURL(newValue, forKey: defaultsKey)
        }
    }

    func logoutIfServerChanged(config config: OEXConfig, logoutAction : Void -> Void) {
        
        if let lastURL = lastUsedAPIHostURL, currentURL = config.apiHostURL() where lastURL != currentURL { //新的url和本地的不一样，执行退出登录
            logoutAction()
            OEXFileUtility.nukeUserData()
        }
        lastUsedAPIHostURL = config.apiHostURL()
    }

    func logoutIfServerChanged() {
        logoutIfServerChanged(config: OEXConfig(appBundleData: ())) {
            OEXSession().closeAndClearSession()
        }
    }
}
