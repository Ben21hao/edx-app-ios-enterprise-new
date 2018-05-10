//
//  TDUserCeterCell.swift
//  edX
//
//  Created by Elite Edu on 17/4/14.
//  Copyright © 2017年 edX. All rights reserved.
//

import UIKit

class TDUserCeterCell: UITableViewCell {
    
    let bgView = UIView()
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let messageLabel = UILabel()
    let redImageView = UIImageView()
    

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        configView()
        setViewConstraint()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configView() {
        
        bgView.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        self.contentView.addSubview(bgView)
        
        bgView.addSubview(iconImageView)
        
        titleLabel.textColor = OEXStyles.sharedStyles().baseColor10()
        titleLabel.font = UIFont.init(name: "OpenSans", size: 14)
        bgView.addSubview(titleLabel)
        
        messageLabel.textColor = OEXStyles.sharedStyles().baseColor8()
        messageLabel.font = UIFont.init(name: "OpenSans", size: 12)
        bgView.addSubview(messageLabel)
        
        redImageView.image = UIImage(named: "redcolor_oval")
        redImageView.layer.masksToBounds = true
        redImageView.layer.cornerRadius = 3
        bgView.addSubview(redImageView)
        
        redImageView.hidden = true
    }
    
    func setViewConstraint() {
        bgView.snp_makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.contentView)
        }
        
        iconImageView.snp_makeConstraints { (make) in
            make.left.equalTo(bgView.snp_left).offset(18)
            make.centerY.equalTo(bgView)
        }
        
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(bgView.snp_left).offset(75)
            make.bottom.equalTo(bgView.snp_centerY).offset(-3)
        }
        
        messageLabel.snp_makeConstraints { (make) in
            make.left.equalTo(bgView.snp_left).offset(75)
            make.top.equalTo(bgView.snp_centerY).offset(3)
        }
        
        redImageView.snp_makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp_right).offset(8)
            make.centerY.equalTo(titleLabel.snp_centerY)
            make.size.equalTo(CGSizeMake(6, 6))
        }
    }
    


}
