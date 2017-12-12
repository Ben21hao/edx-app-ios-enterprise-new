//
//  CourseUnknownBlockViewController.swift
//  edX
//
//  Created by Ehmad Zubair Chughtai on 20/05/2015.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit

class CourseUnknownBlockViewController: UIViewController, CourseBlockViewController {
    
    typealias Environment = protocol<DataManagerProvider>
    
    let environment : Environment

    let blockID : CourseBlockID?
    let courseID : String
    let messageView : IconMessageView
    
    let fileWebVC = TDFileWebViewController()
    
    var loader : Stream<NSURL?>?
    init(blockID : CourseBlockID?, courseID : String, environment : Environment) {
        self.blockID = blockID
        self.courseID = courseID
        self.environment = environment
        
        messageView = IconMessageView(icon: Icon.CourseUnknownContent, message: TDLocalizeSelectSwift("COURSE_CONTENT_UNKNOWN"))
        
        super.init(nibName: nil, bundle: nil)
        
        
        messageView.buttonInfo = MessageButtonInfo(title : TDLocalizeSelectSwift("OPEN_IN_BROWSER"))
            {
            [weak self] in
            self?.loader?.listen(self!, success : {URL -> Void in
                if let URL = URL {
                    UIApplication.sharedApplication().openURL(URL)
                }
            }, failure : {_ in
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = OEXStyles.sharedStyles().standardBackgroundColor()
        self.view.addSubview(messageView)
        
        self.fileWebVC.couse_id = self.courseID
        self.fileWebVC.block_id = self.blockID
        self.fileWebVC.setViewData()
        self.view.addSubview(fileWebVC.view);
    }

    
    override func updateViewConstraints() {
        
        if  self.isVerticallyCompact() {
            applyLandscapeConstraints()
        }
        else{
            applyPortraitConstraints()
        }
        
        super.updateViewConstraints()
    }
    
    private func applyPortraitConstraints() {
        messageView.snp_remakeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
    }
    
    private func applyLandscapeConstraints() {
        messageView.snp_remakeConstraints { (make) -> Void in
            make.edges.equalTo(view)
            let barHeight = navigationController?.toolbar.frame.size.height ?? 0.0
            make.bottom.equalTo(view.snp_bottom).offset(-barHeight)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if loader?.value == nil {
            loader = environment.dataManager.courseDataManager.querierForCourseWithID(self.courseID).blockWithID(self.blockID).map {
                return $0.webURL
            }.firstSuccess()
        }
    }
    
}

extension UIViewController {
    func isVerticallyCompact() -> Bool {
        return self.traitCollection.verticalSizeClass == .Compact
    }
    
    func currentOrientation() -> UIInterfaceOrientation {
        return UIApplication.sharedApplication().statusBarOrientation
    }
}
