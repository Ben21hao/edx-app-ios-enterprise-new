//
//  OfflineSupportViewController.swift
//  edX
//
//  Created by Saeed Bashir on 7/15/16.
//  Copyright © 2016 edX. All rights reserved.
//

import Foundation

/// Convenient class for supporting an offline snackbar at the bottom of the controller
/// Override reloadViewData function

public class OfflineSupportViewController: UIViewController {
    typealias Env = protocol<ReachabilityProvider>
    private let environment : Env
    let titleViewLabel = UILabel.init(frame: CGRectMake(0, 0, TDScreenWidth - 198, 44))
    init(env: Env) {
        self.environment = env
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupObservers()
        setTitleLabelNaviBar()
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        showOfflineSnackBarIfNecessary()
    }
    
    func setTitleLabelNaviBar() {
        
        self.titleViewLabel.textAlignment = .Center
        self.titleViewLabel.font = UIFont.init(name: "OpenSans", size: 18.0)
        self.titleViewLabel.textColor = UIColor.whiteColor()
        self.navigationItem.titleView = self.titleViewLabel
    }
    
    private func setupObservers() {
        NSNotificationCenter.defaultCenter().oex_addObserver(self, name: kReachabilityChangedNotification) { (notification, observer, _) -> Void in
            observer.showOfflineSnackBarIfNecessary()
        }
    }
    
    private func showOfflineSnackBarIfNecessary() {
        if !environment.reachability.isReachable() {
            showOfflineSnackBar(Strings.offline, selector: #selector(reloadViewData))
        }
    }
    
    /// This function reload view data when internet is available and user hit reload
    /// Subclass must override this function
    func reloadViewData() {
        preconditionFailure("This method must be overridden by the subclass")
    }
}
