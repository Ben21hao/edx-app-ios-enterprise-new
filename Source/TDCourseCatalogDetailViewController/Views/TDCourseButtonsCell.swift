//
//  TDCourseButtonsCell.swift
//  edX
//
//  Created by Ben on 2017/5/5.
//  Copyright © 2017年 edX. All rights reserved.
//

import UIKit

class TDCourseButtonsCell: UITableViewCell {
    let bgView = UIView()
    let submitButton = UIButton()
    let discountLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.whiteColor()
        configView()
        setViewConstraint()
    }
    
    func configView() {
        bgView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(bgView)
        
        submitButton.backgroundColor = OEXStyles.sharedStyles().baseColor1()
        submitButton.layer.cornerRadius = 4.0
        submitButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        submitButton.titleLabel?.font = UIFont.init(name: "OpenSans", size: 16)
        bgView.addSubview(submitButton)
        
        discountLabel.font = UIFont.init(name: "OpenSans", size: 12)
        discountLabel.textColor = OEXStyles.sharedStyles().baseColor4()
        discountLabel.numberOfLines = 0
        discountLabel.textAlignment = .Center
        bgView.addSubview(discountLabel)
    }
    
    func setViewConstraint() {
        bgView.snp_makeConstraints { (make) in
            make.left.right.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView).offset(1)
        }

        submitButton.snp_makeConstraints { (make) in
            make.left.equalTo(bgView.snp_left).offset(18)
            make.right.equalTo(bgView.snp_right).offset(-18)
            make.top.equalTo(bgView.snp_top).offset(8)
            make.height.equalTo(44)
        }
        
        discountLabel.snp_makeConstraints { (make) in
            make.left.equalTo(bgView.snp_left).offset(18)
            make.right.equalTo(bgView.snp_right).offset(-18)
            make.top.equalTo(submitButton.snp_bottom).offset(8)
            make.bottom.equalTo(bgView.snp_bottom).offset(-8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
