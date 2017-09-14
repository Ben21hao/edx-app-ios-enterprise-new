//
//  TDLectureLiveViewController.swift
//  edX
//
//  Created by Ben on 2017/7/12.
//  Copyright © 2017年 edX. All rights reserved.
//

import UIKit

class TDLectureLiveViewController: TDSwiftBaseViewController, UIScrollViewDelegate {

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
    private let username : String
    
    private let titleView = UIScrollView()
    private let contentView = TDBaseScrollView()
    private let sepView = UIView()
    private let sliV = UIView()
    
    private let titleButtons = NSMutableArray()
    private let toolModel = TDBaseToolModel()
    
    let viewHeight : CGFloat = 45.0

    init(environment: Environment, username: String) {
        
        self.environment = environment
        self.username = username
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleViewLabel.text = TDLocalizeSelectSwift("LIVE_TITLE_TEXT")
        
        setViewConstraint()
        addAllChildrenView()
    }

    //MARK: UI
    func setViewConstraint() {
        self.view.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        
        self.titleView.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        self.titleView.frame = CGRectMake(0, 0, TDScreenWidth, viewHeight)
        self.view.addSubview(self.titleView)
        
        self.contentView.pagingEnabled = true
        self.contentView.bounces = false
        self.contentView.frame = CGRectMake(0, viewHeight, TDScreenWidth, TDScreenHeight - viewHeight - 60)
        self.contentView.delegate = self
        self.contentView.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        self.view.addSubview(self.contentView)
    }
    
    //MARK: 加入子控制器
    func addAllChildrenView() {
        
        for i in 0 ..< 2  {
            let subVc = TDLectureSubViewController.init(environment: self.environment, whereFrom: i, username: self.username)
            subVc.view.backgroundColor = OEXStyles.sharedStyles().baseColor5()
            self.addChildViewController(subVc)
        }
        
        setUpSubtitle() //设置标题
        setSepView() //添加分割线
        setSliView(0) //设置指示view
    }
    
    //MARK: 设置按钮标题
    func setUpSubtitle() {
        
        let count = self.childViewControllers.count
        var x : CGFloat = 0
        let h : CGFloat = 46
        let btnW = TDScreenWidth / CGFloat(count)
        
        for i in 0 ..< count {
            
            let subVc = self.childViewControllers[i]
            let btn = UIButton.init()
            btn.tag = i
            x = CGFloat(i) * btnW
            btn.frame = CGRectMake(x, 0, btnW, h)
            btn.titleLabel?.font = UIFont.init(name: "OpenSans", size: 16)
            btn.setTitleColor(OEXStyles.sharedStyles().baseColor9(), forState: .Normal)
            btn.setTitle(subVc.title, forState: .Normal)
            btn.addTarget(self, action: #selector(btnClick(_:)), forControlEvents: .TouchUpInside)
            self.titleView.addSubview(btn)
            
            self.titleButtons.addObject(btn)
            
            if i == 0 {
                btnClick(btn)
            }
        }
        
        self.contentView.contentSize = CGSizeMake(CGFloat(count) * TDScreenWidth, 0)
        self.contentView.pagingEnabled = true
    }
    
    //MARK: 添加分割线
    func setSepView() {
        
        let y = CGRectGetMaxY(self.titleView.frame)
        
        self.sepView.backgroundColor = UIColor.init(hexString: "#E6E9ED")
        self.sepView.frame = CGRectMake(0, y, TDScreenWidth, 1)
        self.view.addSubview(self.sepView)
        
        self.sliV.backgroundColor = OEXStyles.sharedStyles().baseColor1()
        self.sliV.frame = CGRectMake(0, y, TDScreenWidth / 2, 2)
        self.view.addSubview(self.sliV)
    }
    
    //MARK: 设置指示view
    func setSliView(index: Int) {
        let y = CGRectGetMaxY(self.titleView.frame)
        self.sliV.frame = CGRectMake(CGFloat(index) * (TDScreenWidth / 2), y, TDScreenWidth / 2, 2)
    }
    
    //MARK: 选中按钮
    func selectButton(sender: UIButton) {
        
        for i in 0 ..< self.titleButtons.count {
            
            let button : UIButton = self.titleButtons[i] as! UIButton
            button.setTitleColor(i == sender.tag ? OEXStyles.sharedStyles().baseColor1() : OEXStyles.sharedStyles().baseColor9(), forState: .Normal)
        }
        setSliView(sender.tag)
    }
    
    //MARK: 选中
    func btnClick(sender: UIButton) {
        
        selectButton(sender)
        setUpChildViewController(sender.tag)
        
        let x : CGFloat = CGFloat(sender.tag) * TDScreenWidth
        self.contentView.contentOffset = CGPointMake(x, 0)
        
    }

    //MARK: 添加对应的子控制器
    func setUpChildViewController(index: Int) {
        
//        selView(index)
        
        let vc : UIViewController = self.childViewControllers[index]
        if (vc.view.superview != nil) {
            return
        }
        
        let x : CGFloat = CGFloat(index) * TDScreenWidth
        vc.view.frame = CGRectMake(x, 0, TDScreenWidth, self.contentView.bounds.size.height)
        self.contentView.addSubview(vc.view)
    }
    
    //MARK: UIViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let page : Int = Int(scrollView.contentOffset.x / TDScreenWidth)
        let selButton : UIButton = self.titleButtons[page] as! UIButton
        selectButton(selButton)
        setUpChildViewController(page)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if otherGestureRecognizer.state == .Began && self.contentView.contentOffset.x == 0 {
            return true
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
