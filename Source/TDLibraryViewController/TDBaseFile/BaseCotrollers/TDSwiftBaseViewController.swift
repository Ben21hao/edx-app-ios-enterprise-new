//
//  TDSwiftBaseViewController.swift
//  edX
//
//  Created by Elite Edu on 17/4/14.
//  Copyright © 2017年 edX. All rights reserved.
//

import UIKit

public class TDSwiftBaseViewController: UIViewController,UIGestureRecognizerDelegate {
    
    let titleViewLabel = UILabel.init(frame: CGRectMake(0, 0, 198, 44))
    let leftButton = UIButton.init(frame: CGRectMake(0, 0, 48, 48))
    let rightButton = UIButton.init()
    let loadIngView = UIView.init()
    let nullView = UIView.init()

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleLabelNaviBar()
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        
        setTitleLabelNaviBar()
        setLeftNavigationBar()
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func setTitleLabelNaviBar() {
        self.titleViewLabel.textAlignment = .Center
        self.titleViewLabel.font = UIFont.init(name: "OpenSans", size: 18.0)
        self.titleViewLabel.textColor = UIColor.whiteColor()
        self.navigationItem.titleView = self.titleViewLabel
    }
    
    func setLeftNavigationBar() {
        self.leftButton.setImage(UIImage.init(named: "backImagee"), forState: .Normal)
        self.leftButton.showsTouchWhenHighlighted = true
        self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -23, 0, 23)
        
        self.navigationController?.interactivePopGestureRecognizer?.enabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.leftButton.addTarget(self, action: #selector(leftButtonAction), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: self.leftButton)
    }
    
    func leftButtonAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setRightNavigationBar(str : String) {
        self.rightButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.rightButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, -16)
        self.rightButton.titleLabel?.font = UIFont.init(name: "OpenSans", size: 16.0)
        self.rightButton.titleLabel?.textAlignment = .Right
        self.rightButton.showsTouchWhenHighlighted = true
        self.rightButton.setTitle(str, forState: .Normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.rightButton)
    }
    
    func setLoadDataView() {
        self.loadIngView.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        self.view.addSubview(self.loadIngView)
        self.loadIngView.snp_makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view)
        }
        
        let loadLabel = UILabel.init()
        loadLabel.textColor = OEXStyles.sharedStyles().baseColor1()
        loadLabel.font = UIFont.init(name: "FontAwesome", size: 25)
        loadLabel.text = "\u{f110}"
        self.loadIngView.addSubview(loadLabel)
        
        loadLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.loadIngView)
            make.centerY.equalTo(self.loadIngView).offset(-28)
        }
        
        let animate = CAKeyframeAnimation.init()
        animate.keyPath = "transform.rotation"
        
        let timeArr = NSMutableArray()
        let directArr = NSMutableArray()
        for i in 0...8 {
            let time = Double(i) / 8.0
            let num = NSNumber.init(double: time)
            timeArr.addObject(num)
            
            let direct = time * 2.0 * M_PI
            let dNum = NSNumber.init(double: direct)
            directArr.addObject(dNum)
        }
        
        animate.keyTimes = NSArray.init(array: timeArr) as? [NSNumber]
        animate.values = NSArray.init(array: directArr) as [AnyObject]
        
        animate.repeatCount = 88
        animate.duration = 0.6
        animate.additive = true
        animate.calculationMode = kCAAnimationDiscrete
        animate.beginTime = self.view.layer.convertTime(0, toLayer: self.view.layer)
        loadLabel.layer.addAnimation(animate, forKey: nil)
        self.view.bringSubviewToFront(self.loadIngView)
        
        
    }
    
    func setNullDataView(nullStr: String) {
        self.nullView.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        self.view.addSubview(self.nullView)
        
        let nullLable = UILabel.init()
        nullLable.font = UIFont.init(name: "OpenSans", size: 16)
        nullLable.textColor = OEXStyles.sharedStyles().baseColor8()
        nullLable.textAlignment = .Center
        nullLable.text = title
        self.nullView.addSubview(nullLable)
        
        self.nullView.snp_makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(self.view)
        }
        
        nullLable.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.nullView.snp_centerX)
            make.centerY.equalTo(self.nullView.snp_centerY)
        }
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
